-- ════════════════════════════════════════════════════════════
-- gıcık — initial schema
-- ════════════════════════════════════════════════════════════
-- profiles, conversations, prompt_versions, usage_daily, security_events
-- all tables RLS-on, all writes scoped to auth.uid()

-- ──────────────────────────────────────────────────────────
-- prompt_versions (created first — referenced by conversations)
-- ──────────────────────────────────────────────────────────
CREATE TABLE public.prompt_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    name TEXT NOT NULL,
    version INT NOT NULL,
    layer TEXT NOT NULL CHECK (layer IN ('L0', 'L1', 'L2', 'L3', 'L4', 'tone', 'stage1')),
    mode TEXT,   -- L1 için: cevap, acilis, bio, hayalet, davet
    tone TEXT,   -- tone layer için: flortoz, esprili, direkt, sicak, gizemli

    content TEXT NOT NULL,
    notes TEXT,

    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    rollout_percentage INT NOT NULL DEFAULT 0 CHECK (rollout_percentage BETWEEN 0 AND 100),

    UNIQUE(layer, mode, tone, version)
);

CREATE INDEX idx_prompt_versions_active ON public.prompt_versions(layer, mode, tone)
    WHERE is_active = TRUE;

-- prompt_versions: read for all authenticated users (no PII), write only via service role.
ALTER TABLE public.prompt_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated read prompt versions"
    ON public.prompt_versions
    FOR SELECT
    TO authenticated
    USING (true);

-- ──────────────────────────────────────────────────────────
-- profiles (Supabase auth.users'a ek profil)
-- ──────────────────────────────────────────────────────────
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Demographic (onboarding)
    gender TEXT CHECK (gender IN ('male', 'female', 'unspecified')),
    age_bracket TEXT CHECK (age_bracket IN ('18-24', '25-34', '35-44', '45+')),
    intent TEXT CHECK (intent IN ('relationship', 'casual', 'fun', 'taken')),

    -- Calibration result
    archetype_primary TEXT,
    archetype_secondary TEXT,
    calibration_data JSONB,
    calibration_completed_at TIMESTAMPTZ,
    calibration_version INT NOT NULL DEFAULT 1,

    -- App state
    notifications_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    ai_consent_given BOOLEAN NOT NULL DEFAULT FALSE,
    ai_consent_at TIMESTAMPTZ,

    -- Stats
    total_generations INT NOT NULL DEFAULT 0,
    last_active_at TIMESTAMPTZ
);

CREATE INDEX idx_profiles_archetype ON public.profiles(archetype_primary);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own profile"
    ON public.profiles
    FOR ALL
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- updated_at trigger
CREATE OR REPLACE FUNCTION public.tg_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_set_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.tg_set_updated_at();

-- Auto-create profile on auth signup
CREATE OR REPLACE FUNCTION public.tg_handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id) VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.tg_handle_new_user();

-- ──────────────────────────────────────────────────────────
-- conversations (her generation kaydı, 30 gün retention)
-- ──────────────────────────────────────────────────────────
CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Input
    mode TEXT NOT NULL CHECK (mode IN ('cevap', 'acilis', 'bio', 'hayalet', 'davet')),
    tone TEXT NOT NULL CHECK (tone IN ('flortoz', 'esprili', 'direkt', 'sicak', 'gizemli')),
    screenshot_storage_path TEXT,

    -- Stage 1 (parse) result
    parse_result JSONB,
    parse_model TEXT,
    parse_cost_usd DECIMAL(10, 6),
    parse_duration_ms INT,

    -- Stage 2 (generate) result
    generation_result JSONB,
    generation_model TEXT,
    generation_cost_usd DECIMAL(10, 6),
    generation_duration_ms INT,

    -- Feedback
    selected_reply_index INT CHECK (selected_reply_index BETWEEN 0 AND 2),
    user_feedback TEXT CHECK (user_feedback IN ('positive', 'negative')),
    feedback_text TEXT,

    -- Versioning
    prompt_version_id UUID REFERENCES public.prompt_versions(id)
);

CREATE INDEX idx_conversations_user_created ON public.conversations(user_id, created_at DESC);
CREATE INDEX idx_conversations_mode_tone ON public.conversations(mode, tone, created_at DESC);

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own conversations"
    ON public.conversations
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ──────────────────────────────────────────────────────────
-- usage_daily (free tier limit tracking)
-- ──────────────────────────────────────────────────────────
CREATE TABLE public.usage_daily (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    generation_count INT NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, date)
);

ALTER TABLE public.usage_daily ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own usage"
    ON public.usage_daily
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);
-- Writes only via service role / edge function (no client INSERT/UPDATE).

-- helper: increment usage
CREATE OR REPLACE FUNCTION public.fn_increment_usage(p_user_id UUID)
RETURNS INT AS $$
DECLARE
    new_count INT;
BEGIN
    INSERT INTO public.usage_daily (user_id, date, generation_count)
    VALUES (p_user_id, CURRENT_DATE, 1)
    ON CONFLICT (user_id, date)
    DO UPDATE SET generation_count = usage_daily.generation_count + 1
    RETURNING generation_count INTO new_count;
    RETURN new_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ──────────────────────────────────────────────────────────
-- security_events (prompt injection / toxic / age concern logs)
-- ──────────────────────────────────────────────────────────
CREATE TABLE public.security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('prompt_injection', 'toxic_request', 'age_concern', 'rate_limit_abuse')),
    detected_pattern TEXT,
    raw_input_hash TEXT,  -- sha256, never raw input
    action_taken TEXT NOT NULL CHECK (action_taken IN ('blocked', 'sanitized', 'flagged', 'allowed_with_warning'))
);

CREATE INDEX idx_security_events_user_time ON public.security_events(user_id, created_at DESC);

ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;
-- No client access. Service role only.

-- ──────────────────────────────────────────────────────────
-- subscription_state (RevenueCat → Supabase webhook sync)
-- ──────────────────────────────────────────────────────────
CREATE TABLE public.subscription_state (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    entitlement TEXT,                         -- "premium" | NULL
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    will_renew BOOLEAN NOT NULL DEFAULT FALSE,
    period_type TEXT,                         -- "trial" | "intro" | "normal"
    product_identifier TEXT,                  -- gicik_weekly | gicik_yearly
    purchase_date TIMESTAMPTZ,
    expiration_date TIMESTAMPTZ,

    revenuecat_customer_id TEXT
);

ALTER TABLE public.subscription_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own subscription"
    ON public.subscription_state
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);
-- Writes only via webhook (service role).

CREATE TRIGGER subscription_state_set_updated_at
    BEFORE UPDATE ON public.subscription_state
    FOR EACH ROW
    EXECUTE FUNCTION public.tg_set_updated_at();
