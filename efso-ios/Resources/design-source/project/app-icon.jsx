// app-icon.jsx — efso app icon directions
// 6 explorations, each on a 1024x1024 grid (App Store master), shown also at iOS sizes.

const I_E = window.EFSO_TOKENS;

// ── Direction 01 · "ef." — wordmark only, editorial bold ──
function IconWordmark({ size = 1024 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.225,
      background: '#0E0A14',
      position: 'relative', overflow: 'hidden',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {/* subtle radial mood */}
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(60% 50% at 50% 38%, rgba(201,168,255,0.20) 0%, transparent 60%)`,
      }} />
      <div style={{
        fontFamily: '"Fraunces", serif', fontStyle: 'italic', fontWeight: 500,
        fontSize: size * 0.62, color: '#F4EFE6', lineHeight: 1, letterSpacing: '-0.06em',
        position: 'relative',
      }}>
        ef<span style={{ color: '#C9A8FF' }}>.</span>
      </div>
    </div>
  );
}

// ── Direction 02 · monogram "e" with chrome ring ──
function IconMonogramRing({ size = 1024 }) {
  const ringWidth = size * 0.045;
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.225,
      background: '#0E0A14',
      position: 'relative', overflow: 'hidden',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {/* concentric chrome ring */}
      <div style={{
        position: 'absolute',
        width: size * 0.78, height: size * 0.78, borderRadius: '50%',
        background: 'linear-gradient(135deg, #C9A8FF 0%, #FFC8E1 28%, #E8FF6B 52%, #9DD9FF 78%, #C9A8FF 100%)',
        padding: ringWidth,
      }}>
        <div style={{
          width: '100%', height: '100%', borderRadius: '50%', background: '#0E0A14',
        }} />
      </div>
      {/* inner halo */}
      <div style={{
        position: 'absolute', width: size * 0.62, height: size * 0.62, borderRadius: '50%',
        background: `radial-gradient(circle, rgba(201,168,255,0.25) 0%, transparent 70%)`,
      }} />
      <div style={{
        fontFamily: '"Fraunces", serif', fontStyle: 'italic', fontWeight: 500,
        fontSize: size * 0.55, color: '#F4EFE6', lineHeight: 1, letterSpacing: '-0.05em',
        position: 'relative', transform: `translateY(${size * 0.02}px)`,
      }}>e</div>
    </div>
  );
}

// ── Direction 03 · speech-bubble glyph (deformed) ──
function IconBubble({ size = 1024 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.225,
      background: 'linear-gradient(160deg, #1C1530 0%, #0E0A14 70%)',
      position: 'relative', overflow: 'hidden',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <svg width={size * 0.74} height={size * 0.74} viewBox="0 0 100 100" style={{ overflow: 'visible' }}>
        <defs>
          <linearGradient id="holoStroke3" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#C9A8FF" />
            <stop offset="35%" stopColor="#FFC8E1" />
            <stop offset="60%" stopColor="#E8FF6B" />
            <stop offset="100%" stopColor="#9DD9FF" />
          </linearGradient>
        </defs>
        {/* asymmetric bubble with tail tucked into the lowercase "e" */}
        <path
          d="M 50 8
             C 73 8, 90 22, 90 45
             C 90 64, 76 78, 56 80
             L 38 92
             L 40 78
             C 22 74, 10 60, 10 45
             C 10 22, 27 8, 50 8 Z"
          fill="#15101F"
          stroke="url(#holoStroke3)"
          strokeWidth="1.2"
        />
        {/* tiny lowercase e inside */}
        <text
          x="50" y="56"
          fontFamily="Fraunces, serif" fontStyle="italic" fontWeight="500"
          fontSize="38" fill="#F4EFE6" textAnchor="middle"
          letterSpacing="-0.05em"
        >e</text>
      </svg>
    </div>
  );
}

// ── Direction 04 · pull-quote / em-dash mark ──
function IconQuote({ size = 1024 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.225,
      background: '#F4EFE6',
      position: 'relative', overflow: 'hidden',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {/* large italic quote mark */}
      <div style={{
        fontFamily: '"Fraunces", serif', fontStyle: 'italic', fontWeight: 600,
        fontSize: size * 0.95, color: '#0E0A14', lineHeight: 0.9,
        position: 'absolute', top: size * 0.05, left: size * 0.12,
        letterSpacing: '-0.08em',
      }}>"</div>
      {/* small efso wordmark, bottom right */}
      <div style={{
        position: 'absolute', bottom: size * 0.14, right: size * 0.14,
        fontFamily: '"Fraunces", serif', fontStyle: 'italic', fontWeight: 500,
        fontSize: size * 0.16, color: '#7B5BD9', letterSpacing: '-0.04em',
      }}>efso</div>
      {/* subtle holo strip at bottom */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        height: size * 0.012,
        background: 'linear-gradient(110deg, #C9A8FF 0%, #FFC8E1 28%, #E8FF6B 52%, #9DD9FF 78%, #C9A8FF 100%)',
      }} />
    </div>
  );
}

// ── Direction 05 · chrome droplet / cipher mark ──
function IconCipher({ size = 1024 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.225,
      background: 'radial-gradient(120% 90% at 50% 30%, #1C1530 0%, #0E0A14 70%)',
      position: 'relative', overflow: 'hidden',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <svg width={size * 0.7} height={size * 0.7} viewBox="0 0 100 100" style={{ overflow: 'visible' }}>
        <defs>
          <linearGradient id="chromeFill" x1="0.3" y1="0" x2="0.7" y2="1">
            <stop offset="0%" stopColor="#FFFFFF" stopOpacity="0.95" />
            <stop offset="35%" stopColor="#C9A8FF" />
            <stop offset="65%" stopColor="#7B5BD9" />
            <stop offset="100%" stopColor="#1C1530" />
          </linearGradient>
          <radialGradient id="hi" cx="0.4" cy="0.3" r="0.25">
            <stop offset="0%" stopColor="#FFFFFF" stopOpacity="0.9" />
            <stop offset="100%" stopColor="#FFFFFF" stopOpacity="0" />
          </radialGradient>
        </defs>
        {/* abstract "e" loop — single chrome ribbon */}
        <path
          d="M 78 50
             C 78 28, 60 14, 42 18
             C 22 22, 14 42, 22 60
             C 30 78, 54 84, 72 72"
          fill="none"
          stroke="url(#chromeFill)"
          strokeWidth="14"
          strokeLinecap="round"
        />
        {/* highlight */}
        <ellipse cx="36" cy="34" rx="14" ry="6" fill="url(#hi)" />
      </svg>
    </div>
  );
}

// ── Direction 06 · "e." minimal — Cal-AI-clean ──
function IconMinimal({ size = 1024 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.225,
      background: 'linear-gradient(160deg, #C9A8FF 0%, #7B5BD9 100%)',
      position: 'relative', overflow: 'hidden',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {/* subtle inner shadow vignette */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 'inherit',
        boxShadow: `inset 0 ${size * 0.08}px ${size * 0.16}px rgba(255,255,255,0.18), inset 0 -${size * 0.08}px ${size * 0.16}px rgba(0,0,0,0.18)`,
      }} />
      <div style={{
        fontFamily: '"Fraunces", serif', fontStyle: 'italic', fontWeight: 500,
        fontSize: size * 0.7, color: '#0E0A14', lineHeight: 1,
        letterSpacing: '-0.06em', position: 'relative',
      }}>
        e<span style={{ color: '#F4EFE6' }}>.</span>
      </div>
    </div>
  );
}

// ── Showcase wrapper: one direction at multiple sizes ──
function IconRow({ name, kind, Component, hero, blurb }) {
  const I_E2 = window.EFSO_TOKENS;
  const sizes = [180, 120, 76, 40]; // iPhone home, iPad, iOS settings, notification
  return (
    <div style={{
      width: 1280, padding: '32px 40px',
      background: '#fbf9f3',
      borderRadius: 8, border: '1px solid rgba(0,0,0,0.06)',
      display: 'grid', gridTemplateColumns: '320px 1fr', gap: 40,
      fontFamily: '"Geist", system-ui, sans-serif', color: '#2a251f',
    }}>
      {/* left — meta */}
      <div>
        <div style={{ fontFamily: '"Geist Mono", monospace', fontSize: 10, letterSpacing: '0.18em', textTransform: 'uppercase', opacity: 0.55 }}>{kind}</div>
        <div style={{
          fontFamily: '"Fraunces", serif', fontStyle: 'italic', fontWeight: 500,
          fontSize: 36, lineHeight: 1, marginTop: 8, letterSpacing: '-0.025em',
        }}>{name}</div>
        <div style={{ marginTop: 14, fontSize: 13.5, lineHeight: 1.55, color: '#5a5048' }}>
          {blurb}
        </div>
      </div>
      {/* right — hero + size ladder */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
        {/* hero 360 */}
        <div style={{
          display: 'flex', gap: 32, alignItems: 'flex-end',
          padding: 28, borderRadius: 12,
          background: '#0E0A14',
        }}>
          <div style={{
            transform: 'scale(0.351)',
            transformOrigin: 'top left',
            width: 1024 * 0.351, height: 1024 * 0.351,
            position: 'relative',
          }}>
            <div style={{ position: 'absolute', top: 0, left: 0, transform: 'scale(1)', transformOrigin: 'top left', filter: 'drop-shadow(0 24px 60px rgba(0,0,0,0.5))' }}>
              <Component size={1024} />
            </div>
          </div>
          <div style={{ paddingBottom: 8, color: '#F4EFE6' }}>
            <div style={{ fontFamily: '"Geist Mono", monospace', fontSize: 10, letterSpacing: '0.18em', opacity: 0.55, textTransform: 'uppercase' }}>app store</div>
            <div style={{ fontFamily: '"Fraunces", serif', fontStyle: 'italic', fontSize: 30, marginTop: 6, lineHeight: 1, letterSpacing: '-0.025em' }}>1024 × 1024</div>
            <div style={{ marginTop: 16, fontFamily: '"Geist Mono", monospace', fontSize: 10, letterSpacing: '0.18em', opacity: 0.55, textTransform: 'uppercase' }}>direction</div>
            <div style={{ fontSize: 14, marginTop: 4, color: '#F4EFE6', maxWidth: 320, lineHeight: 1.45, fontFamily: '"Geist", sans-serif' }}>{hero}</div>
          </div>
        </div>

        {/* size ladder */}
        <div style={{
          padding: '20px 24px', borderRadius: 12, background: '#fff',
          border: '1px solid rgba(0,0,0,0.08)',
          display: 'flex', alignItems: 'flex-end', gap: 36,
        }}>
          {sizes.map(s => (
            <div key={s} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10 }}>
              <Component size={s} />
              <div style={{ fontFamily: '"Geist Mono", monospace', fontSize: 9, letterSpacing: '0.16em', textTransform: 'uppercase', opacity: 0.5 }}>{s}px</div>
            </div>
          ))}
          {/* on home grid mock */}
          <div style={{
            marginLeft: 8, padding: 18, background: '#1c1c1e',
            borderRadius: 22,
            display: 'grid', gridTemplateColumns: 'repeat(4, 60px)', gap: 14,
            position: 'relative',
          }}>
            {[0,1,2,3,4,5,6,7].map(i => (
              <div key={i} style={{
                width: 60, height: 60, borderRadius: 13,
                background: i === 5 ? 'transparent' : `hsl(${i*40}, 30%, ${50 + (i%2)*8}%)`,
                opacity: i === 5 ? 1 : 0.5,
              }}>
                {i === 5 && <Component size={60} />}
              </div>
            ))}
            <div style={{
              position: 'absolute', bottom: -22, left: 0, right: 0,
              textAlign: 'center', fontFamily: '"Geist Mono", monospace', fontSize: 9,
              letterSpacing: '0.16em', textTransform: 'uppercase', opacity: 0.5, color: '#5a5048',
            }}>on home screen</div>
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  IconWordmark, IconMonogramRing, IconBubble, IconQuote, IconCipher, IconMinimal,
  IconRow,
});
