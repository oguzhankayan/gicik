// modes.jsx — Açılış, Tonla, Davet, ManualChatComposer, ManualProfileEntry,
// GenerationView (loading), ResultView (history detail), ArchetypeSwitcherSheet
const M_E = window.EFSO_TOKENS;
const M_StatusBar = window.StatusBar;
const M_HomeIndicator = window.HomeIndicator;
const M_Wordmark = window.Wordmark;
const M_Tag = window.Tag;
const M_HoloRule = window.HoloRule;
const M_HoloBorder = window.HoloBorder;
const M_ArchetypeIcon = window.ArchetypeIcon;
const M_ARCH = window.ARCH_META;

function ModeNav({ title, secondary = '← geri' }) {
  return (
    <div style={{ padding: '6px 20px 4px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
      <span style={{ fontFamily: M_E.mono, fontSize: 12, color: M_E.inkDim, letterSpacing: '0.1em' }}>{secondary}</span>
      <M_Tag color={M_E.inkFaint}>{title}</M_Tag>
      <span style={{ width: 32 }} />
    </div>
  );
}

function PrimaryCTA({ label }) {
  return (
    <div style={{ padding: '0 20px 22px' }}>
      <button style={{
        width: '100%', height: 56, borderRadius: 18,
        background: M_E.holo, border: 'none', padding: 1.5,
      }}>
        <div style={{
          width: '100%', height: '100%', borderRadius: 16.5,
          background: M_E.ink, color: M_E.bg0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: M_E.body, fontWeight: 600, fontSize: 16, letterSpacing: '-0.01em',
        }}>{label}</div>
      </button>
    </div>
  );
}

function TonePicker({ active = 'esprili' }) {
  const tones = ['flörtöz', 'esprili', 'direkt', 'sıcak', 'gizemli'];
  return (
    <div style={{ padding: '0 20px 14px' }}>
      <div style={{
        fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint,
        letterSpacing: '0.16em', textTransform: 'uppercase', marginBottom: 10,
      }}>ton</div>
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        {tones.map(t => {
          const on = t === active;
          return (
            <span key={t} style={{
              padding: '9px 14px', borderRadius: 99,
              fontFamily: M_E.body, fontSize: 13,
              background: on ? M_E.ink : 'transparent',
              color: on ? M_E.bg0 : M_E.ink,
              border: on ? 'none' : `1px solid ${M_E.borderStrong}`,
              fontWeight: on ? 600 : 400,
            }}>{t}</span>
          );
        })}
      </div>
    </div>
  );
}

// ─── Açılış (opener from profile) ───────────────────────────
function ScreenAcilis() {
  return (
    <div style={{ width: '100%', height: '100%', background: M_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <M_StatusBar />
      <ModeNav title="açılış" />

      <div style={{ padding: '20px 24px 0' }}>
        <div style={{
          fontFamily: M_E.display, fontStyle: 'italic', fontSize: 38,
          lineHeight: 1, color: M_E.ink, letterSpacing: '-0.03em',
        }}>profili göster.</div>
        <div style={{ marginTop: 8, fontFamily: M_E.body, fontSize: 14, color: M_E.inkDim }}>
          bio, foto, hangi app — fark etmez. ilk mesaj çıkar.
        </div>
      </div>

      <div style={{ padding: '24px 20px 0' }}>
        <div style={{
          height: 220, borderRadius: 22,
          background: `repeating-linear-gradient(135deg, rgba(201,168,255,0.06) 0 8px, transparent 8px 18px)`,
          border: `1.5px dashed ${M_E.borderStrong}`,
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 10,
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 16, background: M_E.bg2,
            border: `1px solid ${M_E.border}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <span style={{ fontSize: 26 }}>👤</span>
          </div>
          <div style={{ fontFamily: M_E.display, fontStyle: 'italic', fontSize: 22, color: M_E.ink, letterSpacing: '-0.02em' }}>
            profil ekran görüntüsü
          </div>
          <div style={{ fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint, letterSpacing: '0.16em' }}>BIO + FOTO + İLGİ</div>
        </div>
      </div>

      <div style={{ padding: '14px 20px 0' }}>
        <button style={{
          width: '100%', padding: '14px 16px', borderRadius: 14,
          background: M_E.bg1, border: `1px solid ${M_E.border}`,
          color: M_E.ink, fontFamily: M_E.body, fontSize: 14, textAlign: 'left',
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <span>elle yaz <span style={{ color: M_E.inkFaint }}>· bio'yu kopyala</span></span>
          <span style={{ color: M_E.accent }}>→</span>
        </button>
      </div>

      <div style={{ flex: 1 }} />
      <TonePicker active="flörtöz" />
      <PrimaryCTA label="açılış üret" />
      <M_HomeIndicator />
    </div>
  );
}

// ─── Tonla (rewrite a draft) ────────────────────────────────
function ScreenTonla() {
  return (
    <div style={{ width: '100%', height: '100%', background: M_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <M_StatusBar />
      <ModeNav title="tonla" />
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{
          fontFamily: M_E.display, fontStyle: 'italic', fontSize: 38,
          lineHeight: 1, color: M_E.ink, letterSpacing: '-0.03em',
        }}>taslağı yaz.</div>
        <div style={{ marginTop: 8, fontFamily: M_E.body, fontSize: 14, color: M_E.inkDim }}>
          ne demek istediğini yaz. ton biz bakarız.
        </div>
      </div>

      <div style={{ padding: '20px 20px 0' }}>
        <div style={{
          minHeight: 180, padding: '16px 18px', borderRadius: 16,
          background: M_E.bg1, border: `1px solid ${M_E.borderStrong}`,
          fontFamily: M_E.body, fontSize: 16, color: M_E.ink, lineHeight: 1.55,
        }}>
          ya bir cevap atsana artık üç gündür bekliyorum tam olarak ne dediğimi bilmediğin halde ne hissediyorsun bana söyle
        </div>
        <div style={{
          marginTop: 8, display: 'flex', justifyContent: 'space-between',
          fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint, letterSpacing: '0.14em',
        }}>
          <span>140 / 500 KARAKTER</span>
          <span style={{ color: M_E.accent }}>SES SIZIYOR · SİVİLT</span>
        </div>
      </div>

      <div style={{ padding: '14px 20px 0' }}>
        <div style={{
          padding: '12px 14px', background: M_E.bg2, borderRadius: 12,
          border: `1px solid ${M_E.border}`,
          display: 'flex', gap: 10, alignItems: 'flex-start',
        }}>
          <span style={{ color: M_E.accent, fontSize: 14 }}>✦</span>
          <div style={{ flex: 1, fontFamily: M_E.display, fontStyle: 'italic', fontSize: 13.5, color: M_E.ink, lineHeight: 1.4 }}>
            kızgınlığını saklayamıyorsun. yazıyı kısalt, soru ile bitir — gücünü kaybetme.
          </div>
        </div>
      </div>

      <div style={{ flex: 1 }} />
      <TonePicker active="direkt" />
      <PrimaryCTA label="tonla" />
      <M_HomeIndicator />
    </div>
  );
}

// ─── Davet (transition to date) ─────────────────────────────
function ScreenDavet() {
  return (
    <div style={{ width: '100%', height: '100%', background: M_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <M_StatusBar />
      <ModeNav title="davet" />
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{
          fontFamily: M_E.display, fontStyle: 'italic', fontSize: 38,
          lineHeight: 1, color: M_E.ink, letterSpacing: '-0.03em',
        }}>buluşmaya geç.</div>
        <div style={{ marginTop: 8, fontFamily: M_E.body, fontSize: 14, color: M_E.inkDim }}>
          birkaç detay — gerisini efso bağlar.
        </div>
      </div>

      <div style={{ padding: '24px 20px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {[
          ['konuşma süresi', '11 gündür yazışıyorsunuz'],
          ['ortak ilgi',     'kahve, sinema, eski plak'],
          ['ne kadar yakın', 'iyi gidiyor — flört, espri var'],
          ['şehir',          'istanbul · ikiniz de avrupa'],
        ].map(([k, v]) => (
          <div key={k} style={{
            padding: '14px 16px', borderRadius: 14, background: M_E.bg1,
            border: `1px solid ${M_E.border}`,
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          }}>
            <span style={{ fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint, letterSpacing: '0.14em', textTransform: 'uppercase' }}>{k}</span>
            <span style={{ fontFamily: M_E.body, fontSize: 13.5, color: M_E.ink }}>{v}</span>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />
      <TonePicker active="sıcak" />
      <PrimaryCTA label="davet üret" />
      <M_HomeIndicator />
    </div>
  );
}

// ─── Manual Chat Composer (elle yaz) ───────────────────────
function ScreenManualChat() {
  const lines = [
    { who: 'they', t: 'merhaba 🙃' },
    { who: 'me',   t: 'selam' },
    { who: 'they', t: 'dün buluşamadık demek ki' },
    { who: 'me',   t: '...' },
    { who: 'they', t: 'haftaya görüşelim mi?' },
  ];
  return (
    <div style={{ width: '100%', height: '100%', background: M_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <M_StatusBar />
      <ModeNav title="elle yaz" secondary="× iptal" />
      <div style={{ padding: '14px 24px 0' }}>
        <div style={{
          fontFamily: M_E.display, fontStyle: 'italic', fontSize: 28,
          lineHeight: 1, color: M_E.ink, letterSpacing: '-0.025em',
        }}>konuşmayı sen aktar.</div>
        <div style={{ marginTop: 6, fontFamily: M_E.body, fontSize: 13.5, color: M_E.inkDim }}>
          karşıdaki ve sen — sırayla.
        </div>
      </div>

      <div style={{ padding: '18px 16px 0', flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {lines.map((l, i) => (
          <div key={i} style={{
            alignSelf: l.who === 'me' ? 'flex-end' : 'flex-start',
            maxWidth: '78%',
            padding: '10px 14px', borderRadius: 16,
            background: l.who === 'me' ? M_E.ink : M_E.bg2,
            color: l.who === 'me' ? M_E.bg0 : M_E.ink,
            fontFamily: M_E.body, fontSize: 14.5,
            borderTopRightRadius: l.who === 'me' ? 4 : 16,
            borderTopLeftRadius: l.who === 'they' ? 4 : 16,
          }}>{l.t}</div>
        ))}
      </div>

      {/* segmented who is talking */}
      <div style={{ padding: '12px 16px 0' }}>
        <div style={{
          padding: 4, background: M_E.bg2, borderRadius: 12, display: 'flex', gap: 4,
          border: `1px solid ${M_E.border}`,
        }}>
          {['karşıdaki', 'ben'].map((w, i) => (
            <div key={w} style={{
              flex: 1, padding: '8px 0', borderRadius: 9, textAlign: 'center',
              background: i === 0 ? M_E.ink : 'transparent',
              color: i === 0 ? M_E.bg0 : M_E.inkDim,
              fontFamily: M_E.body, fontSize: 13, fontWeight: 600,
            }}>{w}</div>
          ))}
        </div>
      </div>

      <div style={{ padding: '10px 16px 14px', display: 'flex', gap: 10, alignItems: 'center' }}>
        <div style={{
          flex: 1, padding: '12px 14px', borderRadius: 14, background: M_E.bg1,
          border: `1px solid ${M_E.border}`,
          fontFamily: M_E.body, fontSize: 14, color: M_E.inkFaint,
        }}>mesajı yaz...</div>
        <button style={{
          width: 48, height: 48, borderRadius: 14, border: 'none',
          background: M_E.holo, padding: 1.5,
        }}>
          <div style={{
            width: '100%', height: '100%', borderRadius: 12.5, background: M_E.ink,
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: M_E.bg0, fontWeight: 700,
          }}>↵</div>
        </button>
      </div>
      <M_HomeIndicator />
    </div>
  );
}

// ─── Manual Profile Entry ───────────────────────────────────
function ScreenManualProfile() {
  return (
    <div style={{ width: '100%', height: '100%', background: M_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <M_StatusBar />
      <ModeNav title="profil bilgisi" secondary="× iptal" />

      <div style={{ padding: '14px 24px 0' }}>
        <div style={{
          fontFamily: M_E.display, fontStyle: 'italic', fontSize: 30,
          lineHeight: 1, color: M_E.ink, letterSpacing: '-0.025em',
        }}>onu tanıyalım.</div>
      </div>

      <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {[
          ['isim',       'derya, 27, istanbul'],
          ['bio',        '"yapay zeka yazılımcısı, eski plakçı, soğuk kahve fanı"'],
          ['sevdikleri', 'sinema, deniz, ev hayvanları'],
          ['nerden',     'tinder, 4 gündür konuşma'],
        ].map(([k, v]) => (
          <div key={k}>
            <div style={{
              fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint,
              letterSpacing: '0.16em', textTransform: 'uppercase', marginBottom: 6,
            }}>{k}</div>
            <div style={{
              padding: '14px 16px', borderRadius: 12,
              background: M_E.bg1, border: `1px solid ${M_E.border}`,
              fontFamily: M_E.body, fontSize: 14.5, color: M_E.ink, lineHeight: 1.5,
            }}>{v}</div>
          </div>
        ))}
      </div>

      <div style={{ flex: 1 }} />
      <PrimaryCTA label="kaydet ve devam" />
      <M_HomeIndicator />
    </div>
  );
}

// ─── Generation View (loading) ──────────────────────────────
function ScreenGeneration() {
  const lines = [
    { t: 'görsel okunuyor', done: true },
    { t: 'bağlam çıkarılıyor', done: true },
    { t: 'arketip eşleniyor', done: true },
    { t: 'üç ton hazırlanıyor', done: false, active: true },
    { t: 'ince ayar', done: false },
  ];
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(80% 50% at 50% 30%, rgba(123,91,217,0.18) 0%, transparent 60%), ${M_E.bg0}`,
      display: 'flex', flexDirection: 'column',
    }}>
      <M_StatusBar />
      <ModeNav title="cevap · esprili" secondary="× iptal" />

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 28px' }}>
        {/* spinning chrome ring */}
        <div style={{
          width: 110, height: 110, borderRadius: 99, position: 'relative',
        }}>
          <div style={{
            position: 'absolute', inset: 0, borderRadius: 99, background: M_E.holo,
            maskImage: 'conic-gradient(from 0deg, black 0%, black 70%, transparent 95%)',
            WebkitMaskImage: 'conic-gradient(from 0deg, black 0%, black 70%, transparent 95%)',
          }} />
          <div style={{
            position: 'absolute', inset: 4, borderRadius: 99, background: M_E.bg0,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: M_E.display, fontStyle: 'italic', fontSize: 36, color: M_E.ink,
          }}>e</div>
        </div>
        <div style={{
          marginTop: 32, fontFamily: M_E.display, fontStyle: 'italic',
          fontSize: 28, color: M_E.ink, letterSpacing: '-0.025em', textAlign: 'center',
        }}>düşünüyor.</div>
        <div style={{
          marginTop: 4, fontFamily: M_E.mono, fontSize: 11, color: M_E.inkDim,
          letterSpacing: '0.14em', textAlign: 'center',
        }}>~3 saniye</div>
      </div>

      <div style={{ padding: '0 24px 20px' }}>
        {lines.map((l, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0',
            borderBottom: i < lines.length - 1 ? `1px solid ${M_E.border}` : 'none',
          }}>
            <span style={{
              width: 8, height: 8, borderRadius: 99,
              background: l.done ? M_E.accent : (l.active ? M_E.pop : M_E.bg2),
              boxShadow: l.active ? `0 0 12px ${M_E.pop}` : 'none',
            }} />
            <span style={{
              flex: 1, fontFamily: M_E.body, fontSize: 13.5,
              color: l.done ? M_E.inkDim : (l.active ? M_E.ink : M_E.inkFaint),
              textDecoration: l.done ? 'line-through' : 'none',
              textDecorationColor: M_E.inkGhost,
            }}>{l.t}</span>
            {l.done && <span style={{ color: M_E.accent, fontSize: 12 }}>✓</span>}
          </div>
        ))}
      </div>
      <M_HomeIndicator />
    </div>
  );
}

// ─── Result / History Detail ────────────────────────────────
function ScreenResult() {
  return (
    <div style={{ width: '100%', height: '100%', background: M_E.bg0, display: 'flex', flexDirection: 'column' }}>
      <M_StatusBar />
      <ModeNav title="geçmiş · 23 nisan" />
      <div style={{ padding: '14px 24px 0' }}>
        <div style={{
          fontFamily: M_E.display, fontStyle: 'italic', fontSize: 28,
          lineHeight: 1, color: M_E.ink, letterSpacing: '-0.025em',
        }}>"haftaya görüşelim mi?"</div>
        <div style={{
          marginTop: 8, fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint,
          letterSpacing: '0.14em', textTransform: 'uppercase',
        }}>cevap · esprili · derya ile</div>
      </div>

      <div style={{ padding: '20px 20px 0' }}>
        <div style={{
          padding: '14px 16px', background: M_E.bg1, borderRadius: 14,
          border: `1px solid ${M_E.border}`,
        }}>
          <div style={{
            fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint,
            letterSpacing: '0.14em', textTransform: 'uppercase', marginBottom: 8,
          }}>seçtiğin · kopyalandı ✓</div>
          <div style={{ fontFamily: M_E.body, fontSize: 15, color: M_E.ink, lineHeight: 1.45 }}>
            haftaya çok soyut. çarşamba akşamı kahve içelim, sinema bölgesinde.
          </div>
        </div>
      </div>

      <div style={{ padding: '20px 24px 0' }}>
        <M_Tag dot color={M_E.inkDim}>efso · gözlem</M_Tag>
        <div style={{
          marginTop: 10, paddingLeft: 14, borderLeft: `2px solid ${M_E.accent}`,
          fontFamily: M_E.display, fontStyle: 'italic',
          fontSize: 17, color: M_E.ink, lineHeight: 1.4, letterSpacing: '-0.015em',
        }}>
          "haftaya" deyince soğutuyor — ama soğutmak istiyor musun? karar senin.
        </div>
      </div>

      <div style={{ padding: '20px 20px 0', flex: 1 }}>
        <div style={{
          fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint,
          letterSpacing: '0.16em', textTransform: 'uppercase', marginBottom: 10,
        }}>diğer 2 alternatif</div>
        {[
          ['açık', 'çarşamba müsait misin? bir kahve içelim.'],
          ['oynak', 'haftaya değil, yarın. niye bekleyelim ki?'],
        ].map(([a, t]) => (
          <div key={a} style={{
            marginBottom: 10, padding: '12px 14px', borderRadius: 12,
            background: 'transparent', border: `1px solid ${M_E.border}`,
          }}>
            <div style={{
              fontFamily: M_E.mono, fontSize: 9, color: M_E.accent,
              letterSpacing: '0.14em', textTransform: 'uppercase', marginBottom: 6,
            }}>angle · {a}</div>
            <div style={{ fontFamily: M_E.body, fontSize: 14, color: M_E.ink }}>{t}</div>
          </div>
        ))}
      </div>

      <div style={{ padding: '10px 20px 22px', display: 'flex', gap: 10 }}>
        <button style={{ flex: 1, padding: '14px 0', borderRadius: 14, background: M_E.bg1, border: `1px solid ${M_E.border}`, color: M_E.ink, fontFamily: M_E.body, fontSize: 14 }}>
          tekrar üret
        </button>
        <button style={{ flex: 1, padding: '14px 0', borderRadius: 14, background: M_E.ink, color: M_E.bg0, fontFamily: M_E.body, fontSize: 14, fontWeight: 600, border: 'none' }}>
          kopyala
        </button>
      </div>
      <M_HomeIndicator />
    </div>
  );
}

// ─── Archetype Switcher Sheet ───────────────────────────────
function ScreenArchetypeSwitcher() {
  const list = ['dryroaster', 'observer', 'softie', 'chaos', 'strategist', 'romantic'];
  return (
    <div style={{
      width: '100%', height: '100%',
      background: 'rgba(0,0,0,0.6)', display: 'flex', flexDirection: 'column',
      justifyContent: 'flex-end',
    }}>
      <M_StatusBar />
      <div style={{ flex: 1 }} />
      <div style={{
        background: M_E.bg0, borderTopLeftRadius: 28, borderTopRightRadius: 28,
        padding: '16px 0 0', borderTop: `1px solid ${M_E.borderStrong}`,
        boxShadow: `0 -20px 60px rgba(0,0,0,0.5)`,
      }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 10 }}>
          <div style={{ width: 40, height: 4, borderRadius: 99, background: M_E.bg2 }} />
        </div>
        <div style={{ padding: '0 24px 14px' }}>
          <M_Tag dot color={M_E.inkDim}>arketipini değiştir</M_Tag>
          <div style={{
            marginTop: 8, fontFamily: M_E.display, fontStyle: 'italic',
            fontSize: 24, color: M_E.ink, letterSpacing: '-0.02em',
          }}>başka bir sesle dene.</div>
        </div>

        <div style={{ padding: '4px 16px 14px', display: 'flex', flexDirection: 'column', gap: 6 }}>
          {list.map((k, i) => {
            const meta = M_ARCH[k];
            const sel = i === 0;
            return (
              <div key={k} style={{
                padding: '12px 14px', borderRadius: 14,
                background: sel ? M_E.bg2 : 'transparent',
                border: sel ? `1px solid ${M_E.borderStrong}` : `1px solid transparent`,
                display: 'flex', gap: 14, alignItems: 'center',
              }}>
                <M_ArchetypeIcon kind={k} size={48} glow={false} />
                <div style={{ flex: 1 }}>
                  <div style={{
                    fontFamily: M_E.display, fontStyle: 'italic', fontSize: 19,
                    color: M_E.ink, letterSpacing: '-0.02em', lineHeight: 1,
                  }}>{k}</div>
                  <div style={{ fontFamily: M_E.mono, fontSize: 10, color: M_E.inkFaint, letterSpacing: '0.12em', marginTop: 4 }}>
                    {meta.emoji} {meta.label} · {meta.title}
                  </div>
                </div>
                {sel && <span style={{ color: M_E.accent, fontFamily: M_E.mono, fontSize: 11 }}>aktif</span>}
              </div>
            );
          })}
        </div>
        <div style={{ padding: '0 20px 26px' }}>
          <button style={{
            width: '100%', height: 50, borderRadius: 14, background: 'transparent',
            border: `1px solid ${M_E.borderStrong}`, color: M_E.ink,
            fontFamily: M_E.body, fontSize: 14,
          }}>kalibrasyonu yeniden yap →</button>
        </div>
        <M_HomeIndicator />
      </div>
    </div>
  );
}

Object.assign(window, {
  ScreenAcilis, ScreenTonla, ScreenDavet,
  ScreenManualChat, ScreenManualProfile,
  ScreenGeneration, ScreenResult, ScreenArchetypeSwitcher,
});
