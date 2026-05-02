-- Add LLM cost tracking to usage_daily
-- CLAUDE.md mandate: per-user $0.50/day cost ceiling

ALTER TABLE public.usage_daily
    ADD COLUMN llm_cost_usd DECIMAL(10,6) NOT NULL DEFAULT 0;

-- Replace fn_increment_usage to also accumulate cost
CREATE OR REPLACE FUNCTION public.fn_increment_usage(p_user_id UUID, p_cost_usd DECIMAL DEFAULT 0)
RETURNS INT AS $$
DECLARE
    new_count INT;
BEGIN
    INSERT INTO public.usage_daily (user_id, date, generation_count, llm_cost_usd)
    VALUES (p_user_id, CURRENT_DATE, 1, p_cost_usd)
    ON CONFLICT (user_id, date)
    DO UPDATE SET
        generation_count = usage_daily.generation_count + 1,
        llm_cost_usd = usage_daily.llm_cost_usd + EXCLUDED.llm_cost_usd
    RETURNING generation_count INTO new_count;
    RETURN new_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
