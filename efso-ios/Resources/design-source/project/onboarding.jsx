// onboarding.jsx — calibration quiz, demographic, demo upload, permissions, consent
const O_E = window.EFSO_TOKENS;
const O_StatusBar = window.StatusBar;
const O_HomeIndicator = window.HomeIndicator;
const O_Wordmark = window.Wordmark;
const O_Tag = window.Tag;
const O_HoloRule = window.HoloRule;

// shared chrome — back arrow + step counter
function OnbHeader({ step, total, label = 'kalibrasyon', onClose = false }) {
  return (
    <div style={{
      padding: '8px 22px 4px', display: 'flex',
      alignItems: 'center', justifyContent: 'space-between',
    }}>
      <span style={{
        fontFamily: O_E.mono, fontSize: 12, color: O_E.inkDim,
        letterSpacing: '0.1em',
      }}>← geri</span>
      <div style={{ flex: 1, padding: '0 14px' }}>
        <div style={{
          height: 2, background: O_E.bg2, borderRadius: 99,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{
            position: 'absolute', top: 0, left: 0, height: '100%',
            width: `${(step / total) * 100}%`, background: O_E.holo,
          }} />
        </div>
      </div>
      <span style={{
        fontFamily: O_E.mono, fontSize: 11, color: O_E.inkFaint,
        letterSpacing: '0.14em', minWidth: 38, textAlign: 'right',
      }}>{String(step).padStart(2, '0')}/{String(total).padStart(2, '0')}</span>
    </div>
  );
}

function OnbCTA({ label = 'devam', enabled = true, secondary = null }) {
  return (
    <div style={{ padding: '0 20px 24px' }}>
      {secondary && (
        <div style={{ textAlign: 'center', marginBottom: 14 }}>
          <span style={{
            fontFamily: O_E.mono, fontSize: 11, color: O_E.inkFaint,
            letterSpacing: '0.14em', textTransform: 'uppercase',
            textDecoration: 'underline', textDecorationColor: O_E.inkGhost,
            textUnderlineOffset: 4,
          }}>{secondary}</span>
        </div>
      )}
      <button style={{
        width: '100%', height: 56, borderRadius: 18, border: 'none',
        background: enabled ? O_E.ink : O_E.bg2,
        color: enabled ? O_E.bg0 : O_E.inkFaint,
        fontFamily: O_E.body, fontWeight: 600, fontSize: 16,
        letterSpacing: '-0.01em', cursor: 'pointer',
      }}>{label} →</button>
    </div>
  );
}

// ─── 08 · Demographic (yaş + cinsiyet) ──────────────────────
function ScreenDemographic() {
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <OnbHeader step={1} total={12} />
      <div style={{ padding: '24px 24px 0' }}>
        <O_Tag color={O_E.accent}>başlamadan önce</O_Tag>
        <div style={{
          marginTop: 14, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 38, lineHeight: 1, color: O_E.ink, letterSpacing: '-0.03em',
        }}>seni kim<br/>tanıyalım?</div>
        <div style={{ marginTop: 10, fontFamily: O_E.body, fontSize: 14, color: O_E.inkDim, lineHeight: 1.5 }}>
          iki bilgi yeter. yaş tonu, cinsiyet üslubu kalibre eder.
        </div>
      </div>

      <div style={{ padding: '36px 24px 0' }}>
        <div style={{ fontFamily: O_E.mono, fontSize: 10, color: O_E.inkFaint, letterSpacing: '0.16em', textTransform: 'uppercase' }}>yaş</div>
        <div style={{
          marginTop: 10, display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8,
        }}>
          {['16-19', '20-24', '25-29', '30+'].map((y, i) => (
            <div key={y} style={{
              padding: '14px 0', textAlign: 'center', borderRadius: 12,
              background: i === 1 ? O_E.ink : 'transparent',
              color: i === 1 ? O_E.bg0 : O_E.ink,
              border: i === 1 ? 'none' : `1px solid ${O_E.borderStrong}`,
              fontFamily: O_E.body, fontSize: 14, fontWeight: 500,
            }}>{y}</div>
          ))}
        </div>
      </div>

      <div style={{ padding: '24px 24px 0' }}>
        <div style={{ fontFamily: O_E.mono, fontSize: 10, color: O_E.inkFaint, letterSpacing: '0.16em', textTransform: 'uppercase' }}>cinsiyet</div>
        <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {['kadın', 'erkek', 'non-binary', 'belirtmek istemiyorum'].map((g, i) => (
            <div key={g} style={{
              padding: '14px 18px', borderRadius: 12,
              background: i === 0 ? O_E.bg2 : 'transparent',
              border: `1px solid ${i === 0 ? O_E.borderStrong : O_E.border}`,
              fontFamily: O_E.body, fontSize: 15, color: O_E.ink,
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            }}>
              <span>{g}</span>
              {i === 0 && <span style={{ color: O_E.accent, fontFamily: O_E.mono, fontSize: 11 }}>✓</span>}
            </div>
          ))}
        </div>
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA enabled={true} />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 09 · Calibration Intro ─────────────────────────────────
function ScreenCalibrationIntro() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(120% 60% at 50% 30%, rgba(123,91,217,0.18) 0%, transparent 60%), ${O_E.bg0}`,
      display: 'flex', flexDirection: 'column', position: 'relative',
    }}>
      <O_StatusBar />
      <OnbHeader step={2} total={12} />

      <div style={{ padding: '36px 28px 0' }}>
        <O_Tag color={O_E.accent} dot>9 soru · 60 saniye</O_Tag>
        <div style={{
          marginTop: 18, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 56, lineHeight: 0.95, color: O_E.ink, letterSpacing: '-0.035em',
        }}>nasıl<br/>yazdığını<br/><span style={{ color: O_E.accent }}>okuyalım.</span></div>
      </div>

      <div style={{ flex: 1 }} />

      <div style={{ padding: '0 28px 12px' }}>
        {[
          ['9', 'soru — kısa, dürüst'],
          ['6', 'arketipten birine yerleşeceksin'],
          ['∞', 'istediğin zaman yenile'],
        ].map(([n, t], i) => (
          <div key={i} style={{
            display: 'flex', gap: 18, padding: '14px 0',
            borderTop: i === 0 ? `1px solid ${O_E.border}` : 'none',
            borderBottom: `1px solid ${O_E.border}`,
            alignItems: 'baseline',
          }}>
            <span style={{
              fontFamily: O_E.display, fontStyle: 'italic', fontSize: 28,
              color: O_E.accent, letterSpacing: '-0.02em', minWidth: 36,
            }}>{n}</span>
            <span style={{ fontFamily: O_E.body, fontSize: 14, color: O_E.ink, flex: 1 }}>{t}</span>
          </div>
        ))}
      </div>

      <OnbCTA label="başla" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 10 · Quiz · single select (humor_style) ────────────────
function ScreenQuizSingle() {
  const opts = ['kara mizah', 'laf sokan, ironik', 'absürt, saçma', 'düz, ifadesiz', 'tatlış, masum'];
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <OnbHeader step={4} total={12} />
      <div style={{ padding: '20px 24px 0' }}>
        <span style={{
          fontFamily: O_E.mono, fontSize: 11, color: O_E.accent,
          letterSpacing: '0.14em', textTransform: 'uppercase',
        }}>03 / 09</span>
        <div style={{
          marginTop: 12, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 36, lineHeight: 1.05, color: O_E.ink, letterSpacing: '-0.025em',
        }}>mizah tarzın?</div>
        <div style={{ marginTop: 8, fontFamily: O_E.body, fontSize: 14, color: O_E.inkDim }}>
          en çok hangisi sana yakın.
        </div>
      </div>

      <div style={{ padding: '28px 20px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {opts.map((o, i) => (
          <div key={o} style={{
            padding: '16px 18px', borderRadius: 14,
            background: i === 1 ? O_E.bg2 : 'transparent',
            border: `1px solid ${i === 1 ? O_E.accent : O_E.border}`,
            fontFamily: O_E.body, fontSize: 15.5, color: O_E.ink,
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <span>{o}</span>
            {i === 1 && (
              <span style={{
                width: 22, height: 22, borderRadius: 99, background: O_E.accent,
                color: O_E.bg0, fontFamily: O_E.mono, fontSize: 11, fontWeight: 700,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>✓</span>
            )}
          </div>
        ))}
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 11 · Quiz · binary scenario ────────────────────────────
function ScreenQuizBinary() {
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <OnbHeader step={3} total={12} />
      <div style={{ padding: '20px 24px 0' }}>
        <span style={{
          fontFamily: O_E.mono, fontSize: 11, color: O_E.accent,
          letterSpacing: '0.14em', textTransform: 'uppercase',
        }}>02 / 09</span>
        <div style={{
          marginTop: 12, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 32, lineHeight: 1.1, color: O_E.ink, letterSpacing: '-0.025em',
        }}>arkadaşın kötü bir<br/>karar alıyor.</div>
      </div>

      <div style={{ padding: '32px 20px 0', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {[
          { e: '💬', t: 'açıkça\nsöylerim', sel: false },
          { e: '🤔', t: 'soru sorarım,\nkendi görsün', sel: true },
        ].map((c, i) => (
          <div key={i} style={{
            height: 200, padding: '18px 16px', borderRadius: 20,
            background: c.sel ? O_E.bg2 : 'transparent',
            border: c.sel ? `1.5px solid ${O_E.accent}` : `1px solid ${O_E.border}`,
            display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
            position: 'relative',
          }}>
            {c.sel && (
              <div style={{ position: 'absolute', top: -1, left: 16, height: 2, width: 32, background: O_E.holo, borderRadius: 99 }} />
            )}
            <span style={{ fontSize: 32 }}>{c.e}</span>
            <span style={{
              fontFamily: O_E.body, fontSize: 16, color: O_E.ink,
              whiteSpace: 'pre-line', fontWeight: 500, lineHeight: 1.3,
            }}>{c.t}</span>
          </div>
        ))}
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA secondary="ikisi de değil" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 12 · Quiz · likert ─────────────────────────────────────
function ScreenQuizLikert() {
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <OnbHeader step={5} total={12} />
      <div style={{ padding: '20px 24px 0' }}>
        <span style={{
          fontFamily: O_E.mono, fontSize: 11, color: O_E.accent,
          letterSpacing: '0.14em', textTransform: 'uppercase',
        }}>04 / 09</span>
        <div style={{
          marginTop: 12, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 32, lineHeight: 1.1, color: O_E.ink, letterSpacing: '-0.025em',
        }}>flörtte risk<br/>alır mısın?</div>
      </div>

      <div style={{ padding: '60px 28px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          {[1, 2, 3, 4, 5].map(n => (
            <div key={n} style={{
              width: n === 4 ? 32 : 18, height: n === 4 ? 32 : 18, borderRadius: 99,
              background: n === 4 ? O_E.holo : 'transparent',
              border: n === 4 ? 'none' : `1.5px solid ${O_E.borderStrong}`,
              boxShadow: n === 4 ? `0 0 18px ${O_E.accentGlow}` : 'none',
            }} />
          ))}
        </div>
        <div style={{ marginTop: 28, display: 'flex', justifyContent: 'space-between' }}>
          {['asla', 'şartlara göre', 'evet'].map(t => (
            <span key={t} style={{ fontFamily: O_E.body, fontSize: 13, color: O_E.inkDim }}>{t}</span>
          ))}
        </div>
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 13 · Quiz · slider ─────────────────────────────────────
function ScreenQuizSlider() {
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <OnbHeader step={6} total={12} />
      <div style={{ padding: '20px 24px 0' }}>
        <span style={{
          fontFamily: O_E.mono, fontSize: 11, color: O_E.accent,
          letterSpacing: '0.14em', textTransform: 'uppercase',
        }}>05 / 09</span>
        <div style={{
          marginTop: 12, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 36, lineHeight: 1, color: O_E.ink, letterSpacing: '-0.025em',
        }}>yazma stilin?</div>
      </div>

      <div style={{ padding: '60px 28px 0', position: 'relative' }}>
        <div style={{ position: 'relative', height: 4, background: O_E.bg2, borderRadius: 99 }}>
          <div style={{ position: 'absolute', left: 0, top: 0, height: '100%', width: '68%', background: O_E.holo, borderRadius: 99 }} />
          <div style={{
            position: 'absolute', left: '68%', top: '50%', transform: 'translate(-50%, -50%)',
            width: 28, height: 28, borderRadius: 99, background: O_E.ink,
            boxShadow: `0 0 18px ${O_E.accentGlow}`,
          }} />
        </div>
        <div style={{ marginTop: 24, display: 'flex', justifyContent: 'space-between' }}>
          <span style={{ fontFamily: O_E.body, fontSize: 13, color: O_E.inkDim }}>yarı formal</span>
          <span style={{ fontFamily: O_E.body, fontSize: 13, color: O_E.inkDim }}>amk yaa abi</span>
        </div>
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 14 · Quiz · free text ──────────────────────────────────
function ScreenQuizFreeText() {
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <OnbHeader step={10} total={12} />
      <div style={{ padding: '20px 24px 0' }}>
        <span style={{
          fontFamily: O_E.mono, fontSize: 11, color: O_E.accent,
          letterSpacing: '0.14em', textTransform: 'uppercase',
        }}>09 / 09 · son</span>
        <div style={{
          marginTop: 12, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 32, lineHeight: 1.05, color: O_E.ink, letterSpacing: '-0.025em',
        }}>bize biraz<br/>kendinden bahset</div>
        <div style={{ marginTop: 8, fontFamily: O_E.body, fontSize: 14, color: O_E.inkDim }}>
          opsiyonel. geçebilirsin.
        </div>
      </div>

      <div style={{ padding: '20px 20px 0' }}>
        <div style={{
          minHeight: 220, padding: '16px 18px', borderRadius: 14,
          background: O_E.bg1, border: `1px solid ${O_E.border}`,
          fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 16, color: O_E.inkFaint, lineHeight: 1.5,
        }}>
          ne yapıyorsun, neden buradasın, ne tarz mesajlar atıyorsun. ne hissediyorsan yaz...
        </div>
        <div style={{
          marginTop: 8, textAlign: 'right',
          fontFamily: O_E.mono, fontSize: 10, color: O_E.inkFaint, letterSpacing: '0.14em',
        }}>0 / 500 KARAKTER</div>
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA secondary="atla" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 15 · Demo Upload ───────────────────────────────────────
function ScreenDemoUpload() {
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <OnbHeader step={11} total={12} />
      <div style={{ padding: '20px 24px 0' }}>
        <O_Tag color={O_E.accent} dot>ilk üretimin</O_Tag>
        <div style={{
          marginTop: 14, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 38, lineHeight: 1, color: O_E.ink, letterSpacing: '-0.03em',
        }}>bir konuşma<br/>dene.</div>
        <div style={{ marginTop: 10, fontFamily: O_E.body, fontSize: 14, color: O_E.inkDim, lineHeight: 1.5 }}>
          gerçek bir dm screenshot'ı at. ya da örnek konuşmayı kullan — ikisi de sayılır.
        </div>
      </div>

      <div style={{ padding: '24px 20px 0', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {/* primary */}
        <div style={{
          padding: '24px', borderRadius: 22,
          background: `repeating-linear-gradient(135deg, rgba(201,168,255,0.05) 0 8px, transparent 8px 18px), ${O_E.bg1}`,
          border: `1.5px dashed ${O_E.borderStrong}`,
          display: 'flex', alignItems: 'center', gap: 16,
        }}>
          <div style={{
            width: 48, height: 48, borderRadius: 14, background: O_E.bg2,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            border: `1px solid ${O_E.border}`,
          }}>
            <span style={{ fontSize: 22 }}>📷</span>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: O_E.display, fontStyle: 'italic', fontSize: 18, color: O_E.ink }}>
              screenshot seç
            </div>
            <div style={{ fontFamily: O_E.mono, fontSize: 10, color: O_E.inkFaint, letterSpacing: '0.14em', marginTop: 4 }}>
              GALERIDEN
            </div>
          </div>
        </div>
        {/* secondary */}
        <div style={{
          padding: '20px', borderRadius: 18,
          background: O_E.bg1, border: `1px solid ${O_E.border}`,
          display: 'flex', alignItems: 'center', gap: 14,
        }}>
          <div style={{
            width: 40, height: 40, borderRadius: 12, background: O_E.bg2,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: O_E.display, fontSize: 18, color: O_E.accent, fontStyle: 'italic',
          }}>✦</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: O_E.body, fontSize: 15, color: O_E.ink, fontWeight: 500 }}>örnek konuşma</div>
            <div style={{ fontFamily: O_E.body, fontSize: 12, color: O_E.inkDim }}>
              "üç gün suskun" senaryosunu dene
            </div>
          </div>
          <span style={{ color: O_E.accent, fontSize: 16 }}>→</span>
        </div>
        {/* manual */}
        <div style={{
          padding: '20px', borderRadius: 18,
          background: 'transparent', border: `1px solid ${O_E.border}`,
          display: 'flex', alignItems: 'center', gap: 14,
        }}>
          <div style={{
            width: 40, height: 40, borderRadius: 12, background: O_E.bg2,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: O_E.mono, fontSize: 14, color: O_E.inkDim,
          }}>Aa</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: O_E.body, fontSize: 15, color: O_E.ink, fontWeight: 500 }}>elle yaz</div>
            <div style={{ fontFamily: O_E.body, fontSize: 12, color: O_E.inkDim }}>
              konuşmayı sen aktar
            </div>
          </div>
          <span style={{ color: O_E.inkFaint, fontSize: 16 }}>→</span>
        </div>
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA secondary="şimdilik atla" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 16 · Notification Permission ───────────────────────────
function ScreenNotifPerm() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(80% 50% at 50% 30%, rgba(201,168,255,0.18) 0%, transparent 60%), ${O_E.bg0}`,
      display: 'flex', flexDirection: 'column',
    }}>
      <O_StatusBar />
      <OnbHeader step={12} total={12} />

      <div style={{ padding: '32px 28px 0' }}>
        <O_Tag color={O_E.accent}>günde bir gözlem</O_Tag>
        <div style={{
          marginTop: 14, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 48, lineHeight: 0.98, color: O_E.ink, letterSpacing: '-0.03em',
        }}>sessizce.<br/>günde bir.</div>
        <div style={{ marginTop: 12, fontFamily: O_E.body, fontSize: 14, color: O_E.inkDim, lineHeight: 1.5 }}>
          spam yok. günde tek bir bildirim — gözlem, hatırlatma, ya da yeni öğrendiği bir şey.
        </div>
      </div>

      {/* fake notif preview */}
      <div style={{ padding: '36px 16px 0' }}>
        <div style={{
          background: 'rgba(28, 21, 48, 0.9)', backdropFilter: 'blur(20px)',
          borderRadius: 18, padding: '12px 14px',
          border: `1px solid ${O_E.border}`,
          display: 'flex', gap: 12, alignItems: 'flex-start',
        }}>
          <div style={{
            width: 38, height: 38, borderRadius: 9,
            background: O_E.holo, padding: 1,
          }}>
            <div style={{
              width: '100%', height: '100%', borderRadius: 8, background: O_E.bg0,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: O_E.display, fontStyle: 'italic', fontSize: 18, color: O_E.ink,
            }}>e</div>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span style={{ fontFamily: O_E.body, fontSize: 13, fontWeight: 600, color: O_E.ink }}>efso</span>
              <span style={{ fontFamily: O_E.body, fontSize: 11, color: O_E.inkFaint }}>şimdi</span>
            </div>
            <div style={{
              marginTop: 4, fontFamily: O_E.display, fontStyle: 'italic',
              fontSize: 14.5, color: O_E.ink, lineHeight: 1.4,
            }}>
              "iki gün önce yazdığın cümleye bakalım. cevabını hak ediyor mu?"
            </div>
          </div>
        </div>
      </div>

      <div style={{ flex: 1 }} />
      <OnbCTA label="bildirimlere izin ver" secondary="şimdi değil" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 17 · AI Consent ────────────────────────────────────────
function ScreenAIConsent() {
  return (
    <div style={{ width: '100%', height: '100%', background: O_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <O_StatusBar />
      <div style={{ padding: '8px 22px 4px', display: 'flex', justifyContent: 'space-between' }}>
        <O_Wordmark size={18} />
        <span style={{ fontFamily: O_E.mono, fontSize: 11, color: O_E.inkFaint, letterSpacing: '0.14em' }}>YASAL</span>
      </div>

      <div style={{ padding: '24px 24px 0' }}>
        <div style={{
          fontFamily: O_E.display, fontStyle: 'italic', fontSize: 36,
          lineHeight: 1, color: O_E.ink, letterSpacing: '-0.025em',
        }}>yapay zeka<br/>şeffaflığı.</div>
        <div style={{ marginTop: 14, fontFamily: O_E.body, fontSize: 14.5, color: O_E.inkDim, lineHeight: 1.55 }}>
          efso yapay zeka kullanır. çıktılar yanlış olabilir, ezbere değil — gözlem yardımıyla.
          devam etmeden bunları onayla.
        </div>
      </div>

      <div style={{ padding: '24px 20px 0' }}>
        {[
          ['ne işliyor', 'ekran görüntüleri, yazdıkların, kalibrasyon cevapların'],
          ['ne kadar tutuyor', 'screenshot 24 saat. konuşma 30 gün. kalibrasyon — silene kadar.'],
          ['kiminle paylaşıyor', 'kimseyle. anthropic + google ile geçici olarak işlenir, depolanmaz.'],
          ['geri alabilir miyim', 'evet. ayarlar → veri ve yapay zeka → onayı geri çek.'],
        ].map(([q, a]) => (
          <div key={q} style={{
            padding: '14px 0', borderBottom: `1px solid ${O_E.border}`,
          }}>
            <div style={{
              fontFamily: O_E.mono, fontSize: 10, color: O_E.accent,
              letterSpacing: '0.16em', textTransform: 'uppercase',
            }}>{q}</div>
            <div style={{ marginTop: 4, fontFamily: O_E.body, fontSize: 13.5, color: O_E.ink, lineHeight: 1.45 }}>{a}</div>
          </div>
        ))}
      </div>

      <div style={{ padding: '20px 24px 0', display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{
          width: 22, height: 22, borderRadius: 6,
          background: O_E.accent, display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: O_E.bg0, fontWeight: 700, fontSize: 14,
        }}>✓</div>
        <span style={{ fontFamily: O_E.body, fontSize: 13.5, color: O_E.ink }}>
          okudum, anladım. <span style={{ textDecoration: 'underline', color: O_E.inkDim }}>tüm metni gör</span>
        </span>
      </div>
      <div style={{ flex: 1 }} />
      <OnbCTA label="kabul et ve devam" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 18 · Pre-paywall value (tease) ─────────────────────────
function ScreenPrePaywallValue() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(120% 60% at 50% 40%, rgba(123,91,217,0.18) 0%, transparent 60%), ${O_E.bg0}`,
      display: 'flex', flexDirection: 'column',
    }}>
      <O_StatusBar />
      <div style={{ padding: '8px 22px 0' }}>
        <O_Tag color={O_E.inkFaint}>kalibrasyon · tamam</O_Tag>
      </div>

      <div style={{ padding: '24px 28px 0' }}>
        <div style={{
          fontFamily: O_E.display, fontStyle: 'italic', fontSize: 44,
          lineHeight: 0.98, color: O_E.ink, letterSpacing: '-0.03em',
        }}>3 mesaj, 3 gün<br/>boyunca <span style={{ color: O_E.accent }}>ücretsiz.</span></div>
        <div style={{ marginTop: 12, fontFamily: O_E.body, fontSize: 14, color: O_E.inkDim, lineHeight: 1.5 }}>
          ister tinder, ister anneanne. zorlandığın her konuşmaya 3 cevap.
        </div>
      </div>

      {/* visual stack — 3 floating "reply cards" */}
      <div style={{ padding: '32px 20px 0', position: 'relative' }}>
        {[
          { y: 0,  rot: -3, content: 'üç gündür sessizdin. ne oldu söyle.', tone: 'direkt' },
          { y: 22, rot: 2,  content: 'iki haftalık kontrolü kaçırma — pazartesi 10\'a yazdırdım.', tone: 'sıcak' },
          { y: 44, rot: -1, content: 'anlamak için soruyorum, savunmaya değil.', tone: 'açık' },
        ].map((c, i) => (
          <div key={i} style={{
            background: i === 1 ? O_E.bg2 : O_E.bg1,
            border: i === 1 ? `1px solid ${O_E.borderStrong}` : `1px solid ${O_E.border}`,
            borderRadius: 18, padding: '14px 16px',
            transform: `translateY(${c.y}px) rotate(${c.rot}deg)`,
            position: i === 0 ? 'relative' : 'absolute',
            top: i > 0 ? 0 : 'auto', left: i > 0 ? 20 : 'auto', right: i > 0 ? 20 : 'auto',
            zIndex: 3 - i,
            boxShadow: '0 12px 24px rgba(0,0,0,0.3)',
          }}>
            <div style={{
              fontFamily: O_E.mono, fontSize: 9, color: O_E.accent,
              letterSpacing: '0.14em', textTransform: 'uppercase', marginBottom: 6,
            }}>angle · {c.tone}</div>
            <div style={{ fontFamily: O_E.body, fontSize: 14, color: O_E.ink, lineHeight: 1.45 }}>{c.content}</div>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />
      <OnbCTA label="devam et" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 19 · Star Rating Prime ─────────────────────────────────
function ScreenStarRating() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(120% 60% at 50% 30%, rgba(232,255,107,0.10) 0%, transparent 60%), ${O_E.bg0}`,
      display: 'flex', flexDirection: 'column', position: 'relative',
    }}>
      <O_StatusBar />
      <div style={{ padding: '40px 28px 0' }}>
        <O_Tag color={O_E.pop} dot>türkiye'nin ilk türkçe ai iletişim koçu</O_Tag>
        <div style={{
          marginTop: 18, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 42, lineHeight: 1, color: O_E.ink, letterSpacing: '-0.03em',
        }}>elle yapılmış.<br/>türkçe konuşur.</div>
      </div>

      {/* fake review cards */}
      <div style={{ padding: '32px 20px 0', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {[
          { name: 'merve_k.', stars: 5, q: 'çok kez kurtardı. özellikle iş mesajlarında.' },
          { name: 'arda',     stars: 5, q: 'gözlem kısmını okumak terapi gibi.' },
          { name: 'd.',       stars: 5, q: 'rizz değil — bu bir farkındalık aleti.' },
        ].map((r, i) => (
          <div key={i} style={{
            padding: '14px 16px', background: O_E.bg1, borderRadius: 16,
            border: `1px solid ${O_E.border}`,
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
              <span style={{ fontFamily: O_E.mono, fontSize: 11, color: O_E.inkDim, letterSpacing: '0.1em' }}>@{r.name}</span>
              <span style={{ color: O_E.pop, letterSpacing: 1 }}>{'★'.repeat(r.stars)}</span>
            </div>
            <div style={{ fontFamily: O_E.display, fontStyle: 'italic', fontSize: 15, color: O_E.ink, lineHeight: 1.4 }}>
              "{r.q}"
            </div>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />
      <div style={{
        padding: '0 28px 12px', textAlign: 'center',
        fontFamily: O_E.mono, fontSize: 11, color: O_E.inkDim, letterSpacing: '0.1em',
      }}>
        beğendiysen ★★★★★ ile destek ol — tek istediğimiz bu.
      </div>
      <OnbCTA label="devam" />
      <O_HomeIndicator />
    </div>
  );
}

// ─── 20 · Sign In ───────────────────────────────────────────
function ScreenSignIn() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(80% 50% at 50% 30%, rgba(201,168,255,0.18) 0%, transparent 60%), ${O_E.bg0}`,
      display: 'flex', flexDirection: 'column',
    }}>
      <O_StatusBar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 28px' }}>
        <O_Wordmark size={64} />
        <div style={{
          marginTop: 22, fontFamily: O_E.display, fontStyle: 'italic',
          fontSize: 22, color: O_E.inkDim, lineHeight: 1.3, textAlign: 'center', letterSpacing: '-0.015em',
        }}>
          önce sen ol.<br/>sonra cümleler gelir.
        </div>
      </div>

      <div style={{ padding: '0 20px 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <button style={{
          height: 56, borderRadius: 16, border: 'none', background: O_E.ink, color: O_E.bg0,
          fontFamily: O_E.body, fontSize: 16, fontWeight: 600,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
        }}>
          <span style={{ fontSize: 18 }}></span> apple ile devam et
        </button>
        <button style={{
          height: 56, borderRadius: 16, background: 'transparent',
          border: `1px solid ${O_E.borderStrong}`, color: O_E.ink,
          fontFamily: O_E.body, fontSize: 16, fontWeight: 500,
        }}>
          email ile devam et
        </button>
      </div>

      <div style={{
        padding: '0 28px 20px', textAlign: 'center',
        fontFamily: O_E.mono, fontSize: 10, color: O_E.inkFaint,
        letterSpacing: '0.12em', lineHeight: 1.6,
      }}>
        DEVAM EDEREK <span style={{ color: O_E.inkDim, textDecoration: 'underline' }}>ŞARTLAR</span> &<br/>
        <span style={{ color: O_E.inkDim, textDecoration: 'underline' }}>GİZLİLİK POLİTİKASI</span>'NI KABUL EDERSİN
      </div>
      <O_HomeIndicator />
    </div>
  );
}

Object.assign(window, {
  ScreenDemographic, ScreenCalibrationIntro,
  ScreenQuizSingle, ScreenQuizBinary, ScreenQuizLikert, ScreenQuizSlider, ScreenQuizFreeText,
  ScreenDemoUpload, ScreenNotifPerm, ScreenAIConsent,
  ScreenPrePaywallValue, ScreenStarRating, ScreenSignIn,
});
