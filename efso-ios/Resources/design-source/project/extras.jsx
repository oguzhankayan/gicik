// extras.jsx — HowItWorks, Settings (with VoiceSampleEditor), Archetype Gallery, EmailSignInSheet, ValueIntro
const X_E = window.EFSO_TOKENS;
const X_StatusBar = window.StatusBar;
const X_HomeIndicator = window.HomeIndicator;
const X_Wordmark = window.Wordmark;
const X_Tag = window.Tag;
const X_HoloRule = window.HoloRule;
const X_ArchetypeIcon = window.ArchetypeIcon;
const X_ARCH = window.ARCH_META;

function XHeader({ title, secondary = '← geri' }) {
  return (
    <div style={{ padding: '6px 20px 4px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
      <span style={{ fontFamily: X_E.mono, fontSize: 12, color: X_E.inkDim, letterSpacing: '0.1em' }}>{secondary}</span>
      <X_Tag color={X_E.inkFaint}>{title}</X_Tag>
      <span style={{ width: 32 }} />
    </div>
  );
}

// ─── How It Works ───────────────────────────────────────────
function ScreenHowItWorks() {
  const steps = [
    { n: '01', t: 'kalibre et', d: '9 soru. nasıl yazdığını öğrenir.' },
    { n: '02', t: 'konuşmayı ver', d: 'screenshot ya da elle. neyi tartıştığınızı anlar.' },
    { n: '03', t: 'üç açıyla cevap al', d: 'farklı tonlar. seçimini sen yap.' },
    { n: '04', t: 'gözlemi oku', d: 'ne hissettiğini fark et. cümleden önce.' },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: X_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <X_StatusBar />
      <XHeader title="nasıl çalışır" />
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{
          fontFamily: X_E.display, fontStyle: 'italic', fontSize: 36,
          lineHeight: 1, color: X_E.ink, letterSpacing: '-0.03em',
        }}>4 adım.<br/>otomatik değil.</div>
        <div style={{ marginTop: 10, fontFamily: X_E.body, fontSize: 14, color: X_E.inkDim, lineHeight: 1.5 }}>
          efso senin yerine konuşmaz. bağlamı okur, ne demek istediğini netleştirir.
        </div>
      </div>

      <div style={{ padding: '28px 20px 0' }}>
        {steps.map((s, i) => (
          <div key={s.n} style={{
            display: 'flex', gap: 16, padding: '18px 0',
            borderTop: `1px solid ${X_E.border}`,
            borderBottom: i === steps.length - 1 ? `1px solid ${X_E.border}` : 'none',
          }}>
            <span style={{
              fontFamily: X_E.mono, fontSize: 11, color: X_E.accent,
              letterSpacing: '0.16em', minWidth: 28,
            }}>{s.n}</span>
            <div style={{ flex: 1 }}>
              <div style={{
                fontFamily: X_E.display, fontStyle: 'italic',
                fontSize: 22, color: X_E.ink, letterSpacing: '-0.02em', lineHeight: 1,
              }}>{s.t}</div>
              <div style={{ marginTop: 6, fontFamily: X_E.body, fontSize: 13.5, color: X_E.inkDim, lineHeight: 1.4 }}>{s.d}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />
      <div style={{ padding: '0 20px 22px' }}>
        <button style={{
          width: '100%', height: 56, borderRadius: 18, background: X_E.ink,
          border: 'none', color: X_E.bg0, fontFamily: X_E.body, fontSize: 16, fontWeight: 600,
        }}>tamam, başlayalım</button>
      </div>
      <X_HomeIndicator />
    </div>
  );
}

// ─── Settings ───────────────────────────────────────────────
function ScreenSettings() {
  const groups = [
    {
      h: 'hesap',
      items: [
        ['arketip', 'observer'],
        ['kalibrasyonu yenile', '→'],
        ['ses örneği düzenle', '→'],
      ],
    },
    {
      h: 'bildirim',
      items: [
        ['günlük gözlem', 'açık'],
        ['saat', '21:30'],
        ['hatırlatmalar', 'kapalı'],
      ],
    },
    {
      h: 'yapay zeka & veri',
      items: [
        ['onayı geri çek', '→'],
        ['konuşma geçmişi', '23 öğe'],
        ['verimi sil', '→', 'danger'],
      ],
    },
    {
      h: 'abonelik',
      items: [
        ['plan', 'pro · aylık'],
        ['yenileme', '15 nis'],
        ['iptal et', '→'],
      ],
    },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: X_E.bg0, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <X_StatusBar />
      <XHeader title="ayarlar" />
      <div style={{ padding: '14px 24px 0' }}>
        <div style={{
          fontFamily: X_E.display, fontStyle: 'italic', fontSize: 32,
          lineHeight: 1, color: X_E.ink, letterSpacing: '-0.025em',
        }}>ayarlar.</div>
      </div>

      <div style={{ padding: '20px 20px 0', flex: 1, overflow: 'hidden' }}>
        {groups.map(g => (
          <div key={g.h} style={{ marginBottom: 18 }}>
            <div style={{
              fontFamily: X_E.mono, fontSize: 10, color: X_E.inkFaint,
              letterSpacing: '0.18em', textTransform: 'uppercase', padding: '0 4px 8px',
            }}>{g.h}</div>
            <div style={{
              background: X_E.bg1, borderRadius: 14, border: `1px solid ${X_E.border}`,
              overflow: 'hidden',
            }}>
              {g.items.map(([k, v, kind], i) => (
                <div key={k} style={{
                  padding: '14px 16px',
                  borderTop: i > 0 ? `1px solid ${X_E.border}` : 'none',
                  display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                }}>
                  <span style={{
                    fontFamily: X_E.body, fontSize: 14,
                    color: kind === 'danger' ? '#FF6B6B' : X_E.ink,
                  }}>{k}</span>
                  <span style={{ fontFamily: X_E.body, fontSize: 13, color: X_E.inkDim }}>{v}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
      <X_HomeIndicator />
    </div>
  );
}

// ─── Voice Sample Editor ────────────────────────────────────
function ScreenVoiceSampleEditor() {
  return (
    <div style={{ width: '100%', height: '100%', background: X_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <X_StatusBar />
      <XHeader title="ses örneği" />
      <div style={{ padding: '14px 24px 0' }}>
        <div style={{
          fontFamily: X_E.display, fontStyle: 'italic', fontSize: 30,
          lineHeight: 1.05, color: X_E.ink, letterSpacing: '-0.025em',
        }}>nasıl yazdığını<br/>biz ezberleyelim.</div>
        <div style={{ marginTop: 10, fontFamily: X_E.body, fontSize: 13.5, color: X_E.inkDim, lineHeight: 1.5 }}>
          son 5-10 mesajını yapıştır. üslup, kelime, noktalama — hepsi sayar.
        </div>
      </div>

      <div style={{ padding: '20px 20px 0' }}>
        <div style={{
          padding: '14px 16px', borderRadius: 14, background: X_E.bg1,
          border: `1px solid ${X_E.borderStrong}`,
          fontFamily: X_E.body, fontSize: 14, color: X_E.ink, lineHeight: 1.6,
          minHeight: 220,
        }}>
          <div>"yarın boş musun"</div>
          <div>"hadi gel kahve içelim"</div>
          <div>"of sıkıldım yaa, çıkalım"</div>
          <div>"saat kaç gibi?"</div>
          <div style={{ color: X_E.inkFaint }}>...</div>
        </div>
        <div style={{
          marginTop: 8, display: 'flex', justifyContent: 'space-between',
          fontFamily: X_E.mono, fontSize: 10, color: X_E.inkFaint, letterSpacing: '0.14em',
        }}>
          <span>4 / 10 ÖRNEK</span>
          <span style={{ color: X_E.accent }}>+ ÖRNEK EKLE</span>
        </div>
      </div>

      <div style={{ padding: '20px 20px 0' }}>
        <div style={{
          padding: '14px 16px', background: X_E.bg2, borderRadius: 14,
          border: `1px solid ${X_E.border}`,
        }}>
          <div style={{
            fontFamily: X_E.mono, fontSize: 10, color: X_E.accent,
            letterSpacing: '0.14em', textTransform: 'uppercase', marginBottom: 8,
          }}>tespit · şu an</div>
          <div style={{ fontFamily: X_E.display, fontStyle: 'italic', fontSize: 15.5, color: X_E.ink, lineHeight: 1.4 }}>
            "kısa cümleler, lowercase, hafif bıkkınlık tonu. emoji yok."
          </div>
        </div>
      </div>

      <div style={{ flex: 1 }} />
      <div style={{ padding: '0 20px 22px' }}>
        <button style={{
          width: '100%', height: 56, borderRadius: 18, background: X_E.ink,
          border: 'none', color: X_E.bg0, fontFamily: X_E.body, fontSize: 16, fontWeight: 600,
        }}>kaydet ve uygula</button>
      </div>
      <X_HomeIndicator />
    </div>
  );
}

// ─── Email Sign In Sheet ────────────────────────────────────
function ScreenEmailSignIn() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: 'rgba(0,0,0,0.6)', display: 'flex', flexDirection: 'column',
      justifyContent: 'flex-end',
    }}>
      <X_StatusBar />
      <div style={{ flex: 1 }} />
      <div style={{
        background: X_E.bg0, borderTopLeftRadius: 28, borderTopRightRadius: 28,
        padding: '16px 0 0', borderTop: `1px solid ${X_E.borderStrong}`,
      }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 10 }}>
          <div style={{ width: 40, height: 4, borderRadius: 99, background: X_E.bg2 }} />
        </div>

        <div style={{ padding: '8px 24px 0' }}>
          <X_Tag dot color={X_E.inkDim}>email ile</X_Tag>
          <div style={{
            marginTop: 10, fontFamily: X_E.display, fontStyle: 'italic',
            fontSize: 30, color: X_E.ink, letterSpacing: '-0.025em',
          }}>email at, kod gelsin.</div>
          <div style={{ marginTop: 6, fontFamily: X_E.body, fontSize: 13.5, color: X_E.inkDim }}>
            şifre yok. tek seferlik kod.
          </div>
        </div>

        <div style={{ padding: '24px 20px 0' }}>
          <div style={{
            padding: '16px 18px', borderRadius: 14, background: X_E.bg1,
            border: `1.5px solid ${X_E.accent}`,
            fontFamily: X_E.body, fontSize: 16, color: X_E.ink,
            display: 'flex', alignItems: 'center', gap: 8,
          }}>
            <span>seni@efso.app</span>
            <span style={{
              width: 2, height: 18, background: X_E.accent,
              animation: 'blink 1s infinite',
            }} />
          </div>
          <div style={{
            marginTop: 8, fontFamily: X_E.mono, fontSize: 10, color: X_E.inkFaint,
            letterSpacing: '0.14em', textTransform: 'uppercase',
          }}>EMAIL ADRESİN · GİZLİ KALIR</div>
        </div>

        <div style={{ padding: '24px 20px 28px' }}>
          <button style={{
            width: '100%', height: 56, borderRadius: 18, background: X_E.ink,
            border: 'none', color: X_E.bg0, fontFamily: X_E.body, fontSize: 16, fontWeight: 600,
          }}>kod gönder →</button>
        </div>
        <X_HomeIndicator />
      </div>
    </div>
  );
}

// ─── Value Intro (3-card swipe pre-quiz) ────────────────────
function ScreenValueIntro() {
  return (
    <div style={{
      width: '100%', height: '100%', background: X_E.bg0,
      display: 'flex', flexDirection: 'column', position: 'relative',
    }}>
      <X_StatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between' }}>
        <X_Wordmark size={18} />
        <span style={{ fontFamily: X_E.mono, fontSize: 11, color: X_E.inkFaint, letterSpacing: '0.14em' }}>02 / 03</span>
      </div>

      <div style={{ padding: '32px 28px 0' }}>
        <div style={{
          fontFamily: X_E.display, fontStyle: 'italic', fontSize: 56,
          lineHeight: 0.95, color: X_E.ink, letterSpacing: '-0.035em',
        }}>cevap yazmak<br/>kolay.<br/><span style={{ color: X_E.accent }}>doğru cevap</span><br/>zor.</div>
      </div>

      <div style={{ padding: '40px 28px 0' }}>
        <div style={{
          fontFamily: X_E.body, fontSize: 14.5, color: X_E.inkDim, lineHeight: 1.5,
        }}>
          rizz değil. otomatik flört değil. sana kim olduğunu hatırlatan bir cümle.
        </div>
      </div>

      <div style={{ flex: 1 }} />

      {/* dots */}
      <div style={{ padding: '0 0 18px', display: 'flex', justifyContent: 'center', gap: 6 }}>
        {[0, 1, 2].map(i => (
          <div key={i} style={{
            width: i === 1 ? 24 : 6, height: 6, borderRadius: 99,
            background: i === 1 ? X_E.ink : X_E.bg2,
          }} />
        ))}
      </div>

      <div style={{ padding: '0 20px 22px' }}>
        <button style={{
          width: '100%', height: 56, borderRadius: 18, background: X_E.ink,
          border: 'none', color: X_E.bg0, fontFamily: X_E.body, fontSize: 16, fontWeight: 600,
        }}>devam →</button>
      </div>
      <X_HomeIndicator />
    </div>
  );
}

// ─── Archetype Gallery (6 cards) ────────────────────────────
function ScreenArchetypeGallery() {
  const order = ['dryroaster', 'observer', 'softie', 'chaos', 'strategist', 'romantic'];
  return (
    <div style={{ width: '100%', height: '100%', background: X_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <X_StatusBar />
      <XHeader title="6 arketip" />
      <div style={{ padding: '14px 24px 0' }}>
        <div style={{
          fontFamily: X_E.display, fontStyle: 'italic', fontSize: 34,
          lineHeight: 1, color: X_E.ink, letterSpacing: '-0.028em',
        }}>altı ses.<br/>biri seninki.</div>
        <div style={{ marginTop: 8, fontFamily: X_E.body, fontSize: 13.5, color: X_E.inkDim }}>
          istediğin zaman değiştir.
        </div>
      </div>

      <div style={{
        padding: '20px 16px 0', flex: 1,
        display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10,
      }}>
        {order.map((k, i) => {
          const m = X_ARCH[k];
          const featured = i === 1;
          return (
            <div key={k} style={{
              padding: '14px 12px', borderRadius: 16,
              background: featured ? X_E.bg2 : X_E.bg1,
              border: featured ? `1.5px solid ${X_E.accent}` : `1px solid ${X_E.border}`,
              position: 'relative', minHeight: 160,
              display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
            }}>
              {featured && (
                <span style={{
                  position: 'absolute', top: 8, right: 10,
                  fontFamily: X_E.mono, fontSize: 9, color: X_E.accent,
                  letterSpacing: '0.14em',
                }}>SENİN</span>
              )}
              <X_ArchetypeIcon kind={k} size={56} glow={featured} />
              <div>
                <div style={{
                  fontFamily: X_E.display, fontStyle: 'italic', fontSize: 18,
                  color: X_E.ink, letterSpacing: '-0.02em', lineHeight: 1,
                }}>{k}</div>
                <div style={{
                  marginTop: 4, fontFamily: X_E.mono, fontSize: 9,
                  color: X_E.inkFaint, letterSpacing: '0.14em',
                }}>{m.emoji} · {m.title}</div>
              </div>
            </div>
          );
        })}
      </div>
      <X_HomeIndicator />
    </div>
  );
}

Object.assign(window, {
  ScreenHowItWorks, ScreenSettings, ScreenVoiceSampleEditor,
  ScreenEmailSignIn, ScreenValueIntro, ScreenArchetypeGallery,
});
