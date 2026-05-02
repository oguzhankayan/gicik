// screens.jsx — efso refined-y2k iOS screens
// Each screen is a presentational component sized 390x844 to slot in IOSDevice (390 wide).
// Visual system declared in tokens object; voice samples from CLAUDE.md.

const E = {
  // background — deep charcoal-purple, less "neon dark", more "ink"
  bg0: '#0E0A14',
  bg1: '#15101F',
  bg2: '#1C1530',
  ink: '#F4EFE6', // off-white, warm
  inkDim: 'rgba(244,239,230,0.62)',
  inkFaint: 'rgba(244,239,230,0.35)',
  inkGhost: 'rgba(244,239,230,0.14)',
  // single living accent — a chrome-violet that shifts to lilac
  accent: '#C9A8FF',
  accentDeep: '#7B5BD9',
  accentGlow: 'rgba(201,168,255,0.35)',
  // sparing contrast pop — only one
  pop: '#E8FF6B', // electric chartreuse, used like a highlighter
  // chrome / holographic stops, used as a stroke gradient ONLY
  holo: 'linear-gradient(110deg, #C9A8FF 0%, #FFC8E1 28%, #E8FF6B 52%, #9DD9FF 78%, #C9A8FF 100%)',
  border: 'rgba(244,239,230,0.10)',
  borderStrong: 'rgba(244,239,230,0.18)',
  // type
  display: '"Fraunces", "Times New Roman", serif',  // editorial serif — refined Y2K display
  body: '"Geist", "Inter", -apple-system, system-ui, sans-serif',
  mono: '"Geist Mono", "JetBrains Mono", ui-monospace, monospace',
};

// ─── Building blocks ────────────────────────────────────────

function Wordmark({ size = 28, color = E.ink, letterSpacing = -0.04 }) {
  // logo — lowercase efso, display serif italic. The "f" descender ties into the "s" loop.
  return (
    <span style={{
      fontFamily: E.display,
      fontStyle: 'italic',
      fontWeight: 500,
      fontSize: size,
      letterSpacing: `${letterSpacing}em`,
      color,
      lineHeight: 1,
    }}>efso</span>
  );
}

function HoloRule({ height = 1, opacity = 0.7, style = {} }) {
  return (
    <div style={{
      height, width: '100%', background: E.holo, opacity, ...style,
    }} />
  );
}

function HoloBorder({ children, radius = 16, padding = 1, style = {} }) {
  // 1px holographic gradient stroke, refined version of original Y2K spec.
  return (
    <div style={{
      borderRadius: radius, background: E.holo, padding,
      ...style,
    }}>
      <div style={{
        borderRadius: radius - padding, background: E.bg1,
        height: '100%', width: '100%',
      }}>
        {children}
      </div>
    </div>
  );
}

function Tag({ children, color = E.inkDim, dot = false }) {
  return (
    <span style={{
      fontFamily: E.mono, fontSize: 10, fontWeight: 500,
      letterSpacing: '0.14em', textTransform: 'uppercase',
      color, display: 'inline-flex', alignItems: 'center', gap: 6,
    }}>
      {dot && <span style={{ width: 5, height: 5, borderRadius: 99, background: E.pop, boxShadow: `0 0 8px ${E.pop}` }} />}
      {children}
    </span>
  );
}

// Real archetype icons — drop-in custom illustrations from the iOS asset catalog.
// Keys match repo: dryroaster, observer, softie, chaos, strategist, romantic.
const ARCH_META = {
  dryroaster:  { emoji: '🥀', label: 'EFSO',    title: 'kuru ironist',     desc: 'duyguyu söylemiyorsun, etrafından dolanıyorsun. bu zayıflık değil — silah.' },
  observer:    { emoji: '🪨', label: 'AĞIR',    title: 'gözlemci',         desc: 'önce dinliyorsun. herkesin söylemediği şeyi söylüyorsun.' },
  softie:      { emoji: '🍬', label: 'TATLI',   title: 'kenarlı tatlı',    desc: 'sıcak yaklaşıyorsun. ama hat çekiyorsun, fark edilmeden.' },
  chaos:       { emoji: '🔥', label: 'ALEV',    title: 'kaos ajanı',       desc: 'beklenmedik açıdan giriyorsun. konuşma seninle yön değiştirir.' },
  strategist:  { emoji: '✨', label: 'HAVALI',  title: 'stratejist',       desc: 'her cümlenin bir hamlesi var. kazanmak değil — kontrol.' },
  romantic:    { emoji: '🎀', label: 'NAZLI',   title: 'romantik karamsar', desc: 'inanıyorsun ama temkinlisin. yumuşak ama saf değil.' },
};

function ArchetypeIcon({ kind = 'dryroaster', size = 96, glow = true }) {
  const src = `assets/arch-${kind}.png`;
  return (
    <div style={{
      width: size, height: size, position: 'relative',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {glow && (
        <div style={{
          position: 'absolute', inset: '8%', borderRadius: '50%',
          background: 'radial-gradient(closest-side, rgba(201,168,255,0.35), transparent 70%)',
          filter: 'blur(10px)',
        }} />
      )}
      <img src={src} alt={kind} style={{
        width: '100%', height: '100%', objectFit: 'contain',
        position: 'relative', zIndex: 1,
        filter: 'drop-shadow(0 8px 24px rgba(123,91,217,0.35))',
      }} />
    </div>
  );
}

function StatusBar({ time = '9:41', dark = true }) {
  const c = dark ? E.ink : '#000';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '18px 28px 8px', height: 54, boxSizing: 'border-box',
      fontFamily: E.body, fontWeight: 600, fontSize: 15, color: c,
    }}>
      <span>{time}</span>
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <svg width="17" height="11" viewBox="0 0 17 11">
          <rect x="0" y="6.5" width="3" height="4.5" rx="0.6" fill={c}/>
          <rect x="4.5" y="4.5" width="3" height="6.5" rx="0.6" fill={c}/>
          <rect x="9" y="2" width="3" height="9" rx="0.6" fill={c}/>
          <rect x="13.5" y="0" width="3" height="11" rx="0.6" fill={c}/>
        </svg>
        <svg width="25" height="12" viewBox="0 0 25 12">
          <rect x="0.5" y="0.5" width="21" height="11" rx="3" stroke={c} strokeOpacity="0.35" fill="none"/>
          <rect x="2" y="2" width="18" height="8" rx="1.5" fill={c}/>
        </svg>
      </div>
    </div>
  );
}

function HomeIndicator({ dark = true }) {
  return (
    <div style={{
      position: 'absolute', bottom: 8, left: 0, right: 0,
      display: 'flex', justifyContent: 'center',
    }}>
      <div style={{ width: 134, height: 5, borderRadius: 99, background: dark ? 'rgba(244,239,230,0.4)' : 'rgba(0,0,0,0.4)' }} />
    </div>
  );
}

// ─── 01 · Splash ────────────────────────────────────────────
function ScreenSplash() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(120% 60% at 50% 35%, rgba(123,91,217,0.22) 0%, transparent 60%), ${E.bg0}`,
      position: 'relative', display: 'flex', flexDirection: 'column',
    }}>
      <StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
        {/* concentric chrome ring */}
        <div style={{
          width: 220, height: 220, borderRadius: 999, position: 'absolute',
          background: E.holo, opacity: 0.85,
          filter: 'blur(0.4px)',
          maskImage: 'radial-gradient(closest-side, transparent 70%, black 71%, black 73%, transparent 74%)',
          WebkitMaskImage: 'radial-gradient(closest-side, transparent 70%, black 71%, black 73%, transparent 74%)',
        }} />
        <div style={{
          width: 320, height: 320, borderRadius: 999, position: 'absolute',
          background: E.holo, opacity: 0.4,
          maskImage: 'radial-gradient(closest-side, transparent 70%, black 71%, black 71.5%, transparent 72%)',
          WebkitMaskImage: 'radial-gradient(closest-side, transparent 70%, black 71%, black 71.5%, transparent 72%)',
        }} />
        <div style={{ position: 'relative', zIndex: 2, textAlign: 'center' }}>
          <Wordmark size={84} />
        </div>
      </div>
      <div style={{ padding: '0 28px 60px', textAlign: 'center' }}>
        <div style={{
          fontFamily: E.body, fontSize: 13, color: E.inkDim, lineHeight: 1.5,
          letterSpacing: '-0.01em',
        }}>
          ne diyeceğini değil,<br/>ne dediğini gör.
        </div>
        <div style={{ marginTop: 22 }}>
          <Tag color={E.inkFaint}>v 2.0 · refined</Tag>
        </div>
      </div>
      <HomeIndicator />
    </div>
  );
}

// ─── 02 · Calibration result (archetype reveal) ─────────────
function ScreenCalibrationResult() {
  return (
    <div style={{
      width: '100%', height: '100%', background: E.bg0, position: 'relative',
      display: 'flex', flexDirection: 'column',
    }}>
      <StatusBar />
      {/* radial wash, sits behind content */}
      <div style={{
        position: 'absolute', inset: 0, opacity: 0.6,
        background: 'radial-gradient(80% 50% at 50% 30%, rgba(201,168,255,0.18) 0%, transparent 70%)',
        pointerEvents: 'none',
      }} />
      <div style={{
        padding: '12px 28px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <Tag color={E.inkFaint}>09 / 09 · kalibrasyon</Tag>
        <Wordmark size={18} color={E.inkDim} />
      </div>

      <div style={{ padding: '36px 28px 0', position: 'relative', zIndex: 2 }}>
        <Tag dot color={E.ink}>arketip belirlendi</Tag>
        <div style={{
          fontFamily: E.display, fontStyle: 'italic', fontWeight: 400,
          fontSize: 56, lineHeight: 0.95, color: E.ink, marginTop: 16,
          letterSpacing: '-0.03em',
        }}>
          dryroaster.
        </div>
        <div style={{
          fontFamily: E.mono, fontSize: 11, color: E.accent, marginTop: 10,
          letterSpacing: '0.16em', textTransform: 'uppercase',
        }}>
          🥀 efso · kuru ironist
        </div>
      </div>

      <div style={{ padding: '20px 28px 0', position: 'relative', zIndex: 2, display: 'flex', justifyContent: 'center' }}>
        <ArchetypeIcon kind="dryroaster" size={220} />
      </div>

      <div style={{ flex: 1 }} />

      {/* description card */}
      <div style={{ padding: '0 20px 16px', position: 'relative', zIndex: 2 }}>
        <div style={{
          background: E.bg1, borderRadius: 24, padding: '20px 22px',
          border: `1px solid ${E.border}`,
        }}>
          <div style={{
            fontFamily: E.display, fontStyle: 'italic',
            fontSize: 17, lineHeight: 1.4, color: E.ink, letterSpacing: '-0.01em',
          }}>
            "duyguyu söylemiyorsun, etrafından dolanıyorsun. bu zayıflık değil — silah."
          </div>
          <div style={{
            marginTop: 14, display: 'flex', gap: 8, flexWrap: 'wrap',
          }}>
            {['kestirme', 'ironi · 78%', 'mesafe · yüksek', 'ısınma · az'].map(t => (
              <span key={t} style={{
                fontFamily: E.mono, fontSize: 10, color: E.inkDim,
                padding: '5px 9px', borderRadius: 99,
                border: `1px solid ${E.border}`, letterSpacing: '0.1em',
                textTransform: 'lowercase',
              }}>{t}</span>
            ))}
          </div>
        </div>
      </div>

      {/* CTA */}
      <div style={{ padding: '0 20px 28px', position: 'relative', zIndex: 2 }}>
        <button style={{
          width: '100%', height: 56, borderRadius: 18, border: 'none',
          background: E.ink, color: E.bg0,
          fontFamily: E.body, fontWeight: 600, fontSize: 16,
          letterSpacing: '-0.01em', cursor: 'pointer',
        }}>devam et →</button>
        <div style={{
          textAlign: 'center', marginTop: 12,
          fontFamily: E.mono, fontSize: 10, color: E.inkFaint, letterSpacing: '0.1em',
        }}>kalibrasyonu istediğin zaman yenileyebilirsin</div>
      </div>
      <HomeIndicator />
    </div>
  );
}

// ─── 03 · Home / mode select ────────────────────────────────
function ScreenHome() {
  const modes = [
    { key: 'cevap',   t: 'cevap',   d: 'screenshot ver, üç ton üç cevap.', kbd: '01' },
    { key: 'acilis',  t: 'açılış',  d: 'profilden ilk mesaj.',             kbd: '02' },
    { key: 'tonla',   t: 'tonla',   d: 'taslağını seçtiğin tona çevir.',   kbd: '03' },
    { key: 'davet',   t: 'davet',   d: 'buluşmaya geçiş cümlesi.',         kbd: '04' },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: E.bg0, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      {/* header */}
      <div style={{
        padding: '6px 24px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <Wordmark size={22} />
        <div style={{
          width: 36, height: 36, borderRadius: 99, background: E.bg2,
          border: `1px solid ${E.border}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: E.mono, fontSize: 11, color: E.inkDim, letterSpacing: '0.1em',
        }}>OK</div>
      </div>

      {/* observation strip */}
      <div style={{ padding: '4px 24px 18px' }}>
        <Tag dot color={E.inkDim}>bugünün gözlemi</Tag>
        <div style={{
          marginTop: 10, fontFamily: E.display, fontStyle: 'italic',
          fontSize: 22, lineHeight: 1.25, color: E.ink, letterSpacing: '-0.02em',
        }}>
          dün üç saatte yedi mesaj attın. <span style={{ color: E.accent }}>bugün biraz nefes ver.</span>
        </div>
      </div>

      <div style={{ padding: '0 24px' }}>
        <HoloRule opacity={0.5} />
      </div>

      {/* mode list — large editorial rows, no cards */}
      <div style={{ padding: '8px 0 0' }}>
        {modes.map((m, i) => (
          <div key={m.key} style={{
            padding: '18px 24px',
            borderBottom: i < modes.length - 1 ? `1px solid ${E.border}` : 'none',
            display: 'flex', alignItems: 'baseline', gap: 16, position: 'relative',
          }}>
            <span style={{
              fontFamily: E.mono, fontSize: 11, color: E.inkFaint, letterSpacing: '0.18em',
              minWidth: 24,
            }}>{m.kbd}</span>
            <div style={{ flex: 1 }}>
              <div style={{
                fontFamily: E.display, fontStyle: 'italic', fontWeight: 400,
                fontSize: 36, lineHeight: 1, color: E.ink, letterSpacing: '-0.03em',
              }}>{m.t}</div>
              <div style={{
                marginTop: 6, fontFamily: E.body, fontSize: 13.5,
                color: E.inkDim, letterSpacing: '-0.005em',
              }}>{m.d}</div>
            </div>
            <span style={{ fontFamily: E.mono, fontSize: 18, color: E.accent }}>↗</span>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />

      {/* free quota footer */}
      <div style={{ padding: '0 24px 14px' }}>
        <div style={{
          background: E.bg1, border: `1px solid ${E.border}`, borderRadius: 14,
          padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <div>
            <div style={{ fontFamily: E.mono, fontSize: 10, color: E.inkFaint, letterSpacing: '0.14em', textTransform: 'uppercase' }}>günlük üretim</div>
            <div style={{ marginTop: 2, fontFamily: E.body, fontSize: 14, color: E.ink }}>
              <span style={{ color: E.pop }}>2</span> / 3 kaldı
            </div>
          </div>
          <button style={{
            background: 'transparent', border: `1px solid ${E.borderStrong}`,
            color: E.ink, fontFamily: E.mono, fontSize: 11, letterSpacing: '0.14em',
            padding: '8px 12px', borderRadius: 10, textTransform: 'uppercase',
          }}>premium</button>
        </div>
      </div>
      <HomeIndicator />
    </div>
  );
}

// ─── 04 · Cevap modu — input ────────────────────────────────
function ScreenCevapInput() {
  return (
    <div style={{ width: '100%', height: '100%', background: E.bg0, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      {/* nav */}
      <div style={{ padding: '6px 20px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{
          fontFamily: E.mono, fontSize: 12, color: E.inkDim, letterSpacing: '0.1em',
        }}>← geri</span>
        <Tag color={E.inkFaint}>cevap</Tag>
        <span style={{ width: 32 }} />
      </div>

      <div style={{ padding: '20px 24px 0' }}>
        <div style={{
          fontFamily: E.display, fontStyle: 'italic', fontSize: 38,
          lineHeight: 1, color: E.ink, letterSpacing: '-0.03em',
        }}>
          ne yazıldı?
        </div>
        <div style={{ marginTop: 8, fontFamily: E.body, fontSize: 14, color: E.inkDim }}>
          screenshot at, ya da elle yaz. fark etmez.
        </div>
      </div>

      {/* dropzone — big editorial frame */}
      <div style={{ padding: '22px 20px 0' }}>
        <div style={{
          height: 240, borderRadius: 22, position: 'relative',
          background: `repeating-linear-gradient(135deg, rgba(201,168,255,0.06) 0 8px, transparent 8px 18px)`,
          border: `1.5px dashed ${E.borderStrong}`,
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
          gap: 12,
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 16, background: E.bg2,
            border: `1px solid ${E.border}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <rect x="3" y="5" width="18" height="14" rx="2" stroke={E.accent} strokeWidth="1.5"/>
              <circle cx="8.5" cy="10.5" r="1.5" fill={E.accent}/>
              <path d="M3 17l5-5 4 4 3-3 6 6" stroke={E.accent} strokeWidth="1.5" fill="none" strokeLinecap="round"/>
            </svg>
          </div>
          <div style={{
            fontFamily: E.display, fontStyle: 'italic', fontSize: 22,
            color: E.ink, letterSpacing: '-0.02em',
          }}>screenshot bırak</div>
          <div style={{ fontFamily: E.mono, fontSize: 10, color: E.inkFaint, letterSpacing: '0.16em', textTransform: 'uppercase' }}>
            png · jpg · 24 saat sonra silinir
          </div>
        </div>
        <div style={{ textAlign: 'center', margin: '14px 0' }}>
          <Tag color={E.inkFaint}>— ya da —</Tag>
        </div>
        <button style={{
          width: '100%', padding: '14px 16px', borderRadius: 16,
          background: E.bg1, border: `1px solid ${E.border}`,
          color: E.ink, fontFamily: E.body, fontSize: 15, textAlign: 'left',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <span>elle yaz <span style={{ color: E.inkFaint }}>· konuşmayı sen aktar</span></span>
          <span style={{ color: E.accent, fontSize: 18 }}>→</span>
        </button>
      </div>

      <div style={{ flex: 1 }} />

      {/* tone picker — sticky bottom */}
      <div style={{ padding: '0 20px 12px' }}>
        <div style={{
          fontFamily: E.mono, fontSize: 10, color: E.inkFaint,
          letterSpacing: '0.16em', textTransform: 'uppercase', marginBottom: 10,
        }}>ton</div>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {[
            { t: 'flörtöz', on: false },
            { t: 'esprili', on: true },
            { t: 'direkt',  on: false },
            { t: 'sıcak',   on: false },
            { t: 'gizemli', on: false },
          ].map(({ t, on }) => (
            <span key={t} style={{
              padding: '9px 14px', borderRadius: 99,
              fontFamily: E.body, fontSize: 13,
              background: on ? E.ink : 'transparent',
              color: on ? E.bg0 : E.ink,
              border: on ? 'none' : `1px solid ${E.borderStrong}`,
              fontWeight: on ? 600 : 400,
            }}>{t}</span>
          ))}
        </div>
      </div>

      <div style={{ padding: '0 20px 24px' }}>
        <button style={{
          width: '100%', height: 56, borderRadius: 18,
          background: E.holo, border: 'none', padding: 1.5, cursor: 'pointer',
        }}>
          <div style={{
            width: '100%', height: '100%', borderRadius: 16.5,
            background: E.ink, color: E.bg0,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: E.body, fontWeight: 600, fontSize: 16, letterSpacing: '-0.01em',
          }}>üç cevap üret</div>
        </button>
      </div>
      <HomeIndicator />
    </div>
  );
}

// ─── 05 · Cevap modu — output ───────────────────────────────
function ScreenCevapOutput() {
  const replies = [
    { angle: 'iğneleyici', text: 'üç gün suskunluğu açıklamak için "selam" yetmiyor. ne oldu söyle.' },
    { angle: 'açık',       text: 'üç gündür sustuğun için kırıldım. konuşmak istersen buradayım.' },
    { angle: 'soğuk',      text: 'iyiyim. sen?' },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: E.bg0, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      <div style={{ padding: '6px 20px 4px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontFamily: E.mono, fontSize: 12, color: E.inkDim, letterSpacing: '0.1em' }}>← yeni</span>
        <Tag color={E.inkFaint}>cevap · esprili</Tag>
        <span style={{ width: 32 }} />
      </div>

      {/* observation — Efso speaks (assistant voice, italic, inset like a pull quote) */}
      <div style={{ padding: '14px 24px 0' }}>
        <Tag dot color={E.inkDim}>efso</Tag>
        <div style={{
          marginTop: 10, position: 'relative', paddingLeft: 14,
          borderLeft: `2px solid ${E.accent}`,
        }}>
          <div style={{
            fontFamily: E.display, fontStyle: 'italic', fontSize: 19,
            lineHeight: 1.35, color: E.ink, letterSpacing: '-0.015em',
          }}>
            üç gün sustu, sonra "selam" attı. valla bu sıfırdan değil — korkudan.
          </div>
        </div>
      </div>

      <div style={{ padding: '20px 20px 0', flex: 1, overflow: 'hidden' }}>
        <div style={{
          fontFamily: E.mono, fontSize: 10, color: E.inkFaint,
          letterSpacing: '0.16em', textTransform: 'uppercase', marginBottom: 12, padding: '0 4px',
        }}>3 cevap · kaydır →</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {replies.map((r, i) => (
            <div key={i} style={{
              background: i === 0 ? E.bg2 : E.bg1,
              borderRadius: 20,
              border: i === 0 ? `1px solid ${E.borderStrong}` : `1px solid ${E.border}`,
              padding: '16px 18px', position: 'relative',
            }}>
              {i === 0 && (
                <div style={{
                  position: 'absolute', top: -1, left: 18, height: 2, width: 36,
                  background: E.holo, borderRadius: 99,
                }} />
              )}
              <div style={{
                display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10,
              }}>
                <div style={{
                  fontFamily: E.mono, fontSize: 10, color: E.accent,
                  letterSpacing: '0.16em', textTransform: 'uppercase',
                }}>angle · {r.angle}</div>
                <div style={{ display: 'flex', gap: 6 }}>
                  <span style={{
                    width: 24, height: 24, borderRadius: 99,
                    border: `1px solid ${E.border}`,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontFamily: E.mono, fontSize: 11, color: E.inkDim,
                  }}>♡</span>
                  <span style={{
                    width: 24, height: 24, borderRadius: 99,
                    border: `1px solid ${E.border}`,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontFamily: E.mono, fontSize: 10, color: E.inkDim,
                  }}>↻</span>
                </div>
              </div>
              <div style={{
                fontFamily: E.body, fontSize: 15.5, lineHeight: 1.45,
                color: E.ink, letterSpacing: '-0.01em',
              }}>{r.text}</div>
              <div style={{ marginTop: 14, display: 'flex', gap: 10 }}>
                <button style={{
                  flex: 1, padding: '10px 12px', borderRadius: 11,
                  background: i === 0 ? E.ink : 'transparent',
                  color: i === 0 ? E.bg0 : E.ink,
                  border: i === 0 ? 'none' : `1px solid ${E.borderStrong}`,
                  fontFamily: E.body, fontSize: 13, fontWeight: 500,
                }}>kopyala</button>
                <button style={{
                  padding: '10px 14px', borderRadius: 11, background: 'transparent',
                  border: `1px solid ${E.border}`, color: E.inkDim,
                  fontFamily: E.mono, fontSize: 11, letterSpacing: '0.1em',
                }}>düzenle</button>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ padding: '12px 20px 22px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '12px 14px', background: E.bg1, borderRadius: 14,
          border: `1px solid ${E.border}`,
        }}>
          <span style={{ fontFamily: E.mono, fontSize: 11, color: E.inkFaint, letterSpacing: '0.12em' }}>
            beğendin mi?
          </span>
          <div style={{ display: 'flex', gap: 8 }}>
            <span style={{ fontFamily: E.body, fontSize: 14, color: E.ink, padding: '6px 10px', borderRadius: 8, background: E.bg2 }}>👍</span>
            <span style={{ fontFamily: E.body, fontSize: 14, color: E.ink, padding: '6px 10px', borderRadius: 8, background: E.bg2 }}>👎</span>
          </div>
        </div>
      </div>
      <HomeIndicator />
    </div>
  );
}

// ─── 06 · Paywall ───────────────────────────────────────────
function ScreenPaywall() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: `radial-gradient(140% 60% at 50% 0%, rgba(201,168,255,0.22) 0%, transparent 55%), ${E.bg0}`,
      display: 'flex', flexDirection: 'column',
    }}>
      <StatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'flex-end' }}>
        <span style={{
          fontFamily: E.mono, fontSize: 12, color: E.inkFaint,
          letterSpacing: '0.1em', padding: '6px 10px',
        }}>kapat ×</span>
      </div>

      <div style={{ padding: '24px 28px 0' }}>
        <Tag color={E.accent}>premium</Tag>
        <div style={{
          marginTop: 14, fontFamily: E.display, fontStyle: 'italic',
          fontSize: 56, lineHeight: 0.95, color: E.ink, letterSpacing: '-0.035em',
        }}>
          her<br/>konuşmada<br/><span style={{ color: E.accent }}>hazır.</span>
        </div>
        <div style={{ marginTop: 14, fontFamily: E.body, fontSize: 14.5, color: E.inkDim, lineHeight: 1.5 }}>
          günde 3 üretim azdır. premium'da sınır yok — sadece sen, ekran, ve doğru cümle.
        </div>
      </div>

      {/* benefit list — minimalist marks, not icons */}
      <div style={{ padding: '24px 28px 0' }}>
        {[
          ['sınırsız', 'her mod, her ton, gün boyu'],
          ['öncelik', 'yoğun saatlerde hızlı kuyruk'],
          ['geçmiş', '30 gün konuşma arşivi'],
          ['arketip', 'kalibrasyonu istediğin kadar yenile'],
        ].map(([t, d]) => (
          <div key={t} style={{
            display: 'flex', gap: 16, padding: '12px 0',
            borderBottom: `1px solid ${E.border}`,
          }}>
            <span style={{
              fontFamily: E.mono, fontSize: 11, color: E.accent,
              letterSpacing: '0.16em', textTransform: 'uppercase',
              minWidth: 70,
            }}>+ {t}</span>
            <span style={{ fontFamily: E.body, fontSize: 14, color: E.ink, flex: 1 }}>{d}</span>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />

      {/* trial card */}
      <div style={{ padding: '0 20px 12px' }}>
        <HoloBorder radius={22} padding={1.2}>
          <div style={{ padding: '18px 18px 16px' }}>
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12,
            }}>
              <div>
                <div style={{ fontFamily: E.body, fontSize: 15, fontWeight: 600, color: E.ink }}>
                  3 gün ücretsiz dene
                </div>
                <div style={{ fontFamily: E.mono, fontSize: 11, color: E.inkDim, marginTop: 3, letterSpacing: '0.05em' }}>
                  sonra ₺49 / hafta · istediğin zaman iptal
                </div>
              </div>
              <div style={{
                width: 44, height: 26, borderRadius: 99, background: E.accent,
                position: 'relative', boxShadow: `0 0 18px ${E.accentGlow}`,
              }}>
                <div style={{
                  position: 'absolute', top: 2, right: 2, width: 22, height: 22,
                  borderRadius: 99, background: E.ink,
                }} />
              </div>
            </div>
            <button style={{
              width: '100%', height: 54, borderRadius: 14, border: 'none',
              background: E.ink, color: E.bg0,
              fontFamily: E.body, fontWeight: 600, fontSize: 16,
            }}>ücretsiz başlat</button>
          </div>
        </HoloBorder>
      </div>

      <div style={{ padding: '0 28px 22px', display: 'flex', justifyContent: 'center', gap: 18 }}>
        {['restore', 'şartlar', 'gizlilik'].map(t => (
          <span key={t} style={{
            fontFamily: E.mono, fontSize: 10, color: E.inkFaint,
            letterSpacing: '0.14em', textTransform: 'uppercase',
          }}>{t}</span>
        ))}
      </div>
      <HomeIndicator />
    </div>
  );
}

// ─── 07 · Profile ───────────────────────────────────────────
function ScreenProfile() {
  return (
    <div style={{ width: '100%', height: '100%', background: E.bg0, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      <div style={{ padding: '6px 24px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontFamily: E.mono, fontSize: 12, color: E.inkDim, letterSpacing: '0.1em' }}>← geri</span>
        <Tag color={E.inkFaint}>profil</Tag>
        <span style={{ width: 32 }} />
      </div>

      {/* archetype card — full width, holo edge */}
      <div style={{ padding: '14px 16px 0' }}>
        <HoloBorder radius={26} padding={1.2}>
          <div style={{
            padding: '22px 20px',
            display: 'flex', gap: 16, alignItems: 'center',
            background: `linear-gradient(180deg, ${E.bg2} 0%, ${E.bg1} 100%)`,
            borderRadius: 25,
          }}>
            <ArchetypeIcon kind="dryroaster" size={88} glow={false} />
            <div style={{ flex: 1 }}>
              <Tag color={E.accent}>arketip</Tag>
              <div style={{
                fontFamily: E.display, fontStyle: 'italic', fontSize: 30,
                lineHeight: 1, color: E.ink, marginTop: 6, letterSpacing: '-0.025em',
              }}>dryroaster</div>
              <div style={{ fontFamily: E.mono, fontSize: 10, color: E.inkDim, marginTop: 6, letterSpacing: '0.12em' }}>
                🥀 EFSO · tier 2
              </div>
            </div>
          </div>
        </HoloBorder>
      </div>

      {/* stats row */}
      <div style={{ padding: '14px 16px 0' }}>
        <div style={{
          display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8,
        }}>
          {[
            ['127', 'üretim'],
            ['38', 'kopyalanan'],
            ['76%', 'beğeni'],
          ].map(([n, l]) => (
            <div key={l} style={{
              padding: '14px 10px', background: E.bg1,
              border: `1px solid ${E.border}`, borderRadius: 14,
              textAlign: 'center',
            }}>
              <div style={{
                fontFamily: E.display, fontStyle: 'italic', fontSize: 28,
                color: E.ink, lineHeight: 1, letterSpacing: '-0.02em',
              }}>{n}</div>
              <div style={{
                marginTop: 6, fontFamily: E.mono, fontSize: 10, color: E.inkFaint,
                letterSpacing: '0.14em', textTransform: 'uppercase',
              }}>{l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* observation log — recent */}
      <div style={{ padding: '20px 24px 0' }}>
        <Tag dot color={E.inkDim}>son gözlemler</Tag>
        <div style={{ marginTop: 14, display: 'flex', flexDirection: 'column' }}>
          {[
            ['dün 21:14', 'savunmaya geçtin. soruyu sorduran sen değildin.'],
            ['önceki gün', 'iyi cümle. virgülü hak etmediği yere koymuşsun.'],
            ['salı',      'üç saatte yedi mesaj. sustuğun yer doluydu.'],
          ].map(([t, q], i) => (
            <div key={i} style={{
              padding: '14px 0',
              borderBottom: i < 2 ? `1px solid ${E.border}` : 'none',
            }}>
              <div style={{
                fontFamily: E.mono, fontSize: 10, color: E.inkFaint,
                letterSpacing: '0.14em', textTransform: 'uppercase',
              }}>{t}</div>
              <div style={{
                marginTop: 6, fontFamily: E.display, fontStyle: 'italic',
                fontSize: 16, color: E.ink, lineHeight: 1.35, letterSpacing: '-0.01em',
              }}>"{q}"</div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ flex: 1 }} />

      <div style={{ padding: '0 16px 22px' }}>
        <div style={{
          background: E.bg1, borderRadius: 14, border: `1px solid ${E.border}`,
          overflow: 'hidden',
        }}>
          {['kalibrasyonu yenile', 'ayarlar', 'çıkış'].map((t, i) => (
            <div key={t} style={{
              padding: '14px 18px',
              borderBottom: i < 2 ? `1px solid ${E.border}` : 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              fontFamily: E.body, fontSize: 14.5, color: i === 2 ? E.inkDim : E.ink,
            }}>
              <span>{t}</span>
              <span style={{ color: E.inkFaint }}>›</span>
            </div>
          ))}
        </div>
      </div>
      <HomeIndicator />
    </div>
  );
}

// ─── Export ─────────────────────────────────────────────────
Object.assign(window, {
  ScreenSplash, ScreenCalibrationResult, ScreenHome, ScreenCevapInput,
  ScreenCevapOutput, ScreenPaywall, ScreenProfile,
  ArchetypeIcon, ARCH_META,
  StatusBar, HomeIndicator, Wordmark, HoloRule, HoloBorder, Tag,
  EFSO_TOKENS: E,
});
