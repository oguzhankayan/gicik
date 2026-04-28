/* Generation streaming, Result, Profile, Empty states */

const Generation = () => (
  <Phone>
    <div style={{ display:'flex', alignItems:'center', padding:'60px 20px 8px' }}>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.back}</span>
    </div>
    <div style={{ padding:'10px 24px 0' }}>
      <div className="t-mono" style={{ color:'rgba(255,255,255,0.6)', fontSize: 11 }}>CEVAP MODU / FLÖRTÖZ TON</div>
      <div className="t-display t-allcaps" style={{ fontSize: 24, marginTop: 8 }}>gıcık yazıyor…</div>
    </div>
    <div style={{ padding:'20px 24px 0' }}>
      <Obs>3 gün cevap yok, sonra 'selam'. yazmamış sayılır. ama ben yazacağım.<span className="cursor"/></Obs>
    </div>
    <div style={{ padding:'18px 24px 0', display:'flex', flexDirection:'column', gap: 12 }}>
      {/* card 1 — half streamed */}
      <div className="reply">
        <div className="label">01 — DOĞRUDAN ENGAGE</div>
        <p className="text">üç gün sonra "selam" yetmez. en azından bir<span className="cursor"/></p>
        <div className="row">
          <span style={{
            display:'inline-flex', alignItems:'center', gap:6, height:32, padding:'0 12px',
            borderRadius:999, border:'1px solid rgba(255,255,255,0.08)', color:'rgba(255,255,255,0.4)', fontSize: 13,
          }}>{Ico.clip} kopyala</span>
          <span style={{ display:'flex', gap: 14, color:'rgba(255,255,255,0.25)' }}>👍 👎</span>
        </div>
      </div>
      {/* card 2,3 — shimmer */}
      {[1,2].map(i => (
        <div key={i} className="reply" style={{ height: 142, padding: 0, overflow:'hidden' }}>
          <div style={{ padding: 18, display:'flex', flexDirection:'column', gap: 10 }}>
            <div className="shimmer" style={{ width: 100, height: 10, borderRadius: 4 }}/>
            <div className="shimmer" style={{ width: '92%', height: 14, borderRadius: 4, marginTop: 6 }}/>
            <div className="shimmer" style={{ width: '78%', height: 14, borderRadius: 4 }}/>
            <div className="shimmer" style={{ width: '60%', height: 14, borderRadius: 4 }}/>
            <div style={{ display:'flex', justifyContent:'space-between', marginTop: 6 }}>
              <div className="shimmer" style={{ width: 80, height: 24, borderRadius: 999 }}/>
              <div className="shimmer" style={{ width: 40, height: 16, borderRadius: 4 }}/>
            </div>
          </div>
        </div>
      ))}
    </div>
  </Phone>
);

const Result = ({ state = 'default' }) => (
  <Phone>
    <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'60px 20px 8px' }}>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.back}</span>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.refresh}</span>
    </div>
    <div style={{ padding:'10px 24px 0' }}>
      <div className="t-mono" style={{ color:'rgba(255,255,255,0.5)', fontSize: 11 }}>CEVAP › FLÖRTÖZ</div>
      <div style={{ marginTop: 14 }}>
        <Obs>üçü de farklı açıdan giriyor. 02 risk seviyesi en yüksek.</Obs>
      </div>
    </div>
    <div style={{ padding:'16px 24px 180px', display:'flex', flexDirection:'column', gap: 12 }}>
      <ReplyCard label="01 — DOĞRUDAN ENGAGE" text='üç gün sonra "selam" gelmek demek. en azından "merhaba" deseydin. ne yapıyoruz?' copied={state==='copied'}/>
      <ReplyCard label="02 — İMA" text="ortadan kaybolan birinin geri dönüşü, genelde dönmek için değil bakmak için olur. hangisi sen?"/>
      <ReplyCard label="03 — KISA" text="selam. üç gün uzun bir sessizlik. iyi misin?"/>
    </div>
    <div style={{ position:'absolute', bottom: 28, left: 24, right: 24 }}>
      <div style={{ display:'flex', gap: 10 }}>
        <button className="btn-secondary" style={{ flex: 1, fontSize: 14 }}>farklı ton dene</button>
        <button className="btn-primary" style={{ flex: 1, fontSize: 14 }}>yeni cevap üret</button>
      </div>
      <div style={{ textAlign:'center', marginTop: 12 }}>
        <span style={{ color:'rgba(255,255,255,0.4)', fontSize: 13 }}>konuşmayı bitir</span>
      </div>
    </div>
  </Phone>
);

const Profile = () => (
  <Phone>
    <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'60px 20px 8px' }}>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.back}</span>
      <span style={{ fontSize: 16 }}>profil</span>
      <span style={{ width: 20 }}/>
    </div>
    <div style={{ padding:'18px 24px 0', display:'flex', flexDirection:'column', alignItems:'center' }}>
      <div style={{ position:'relative', width: 110, height: 110, borderRadius: 999, background:'rgba(45,27,78,0.7)', display:'flex', alignItems:'center', justifyContent:'center' }}>
        <span style={{position:'absolute', inset:0, padding:1.5, borderRadius:999, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude'}}/>
        <span style={{position:'absolute', inset:-14, borderRadius:999, background:'radial-gradient(closest-side, rgba(255,0,128,0.4), transparent 70%)', filter:'blur(18px)', zIndex:-1}}/>
        <span style={{ fontSize: 52 }}>🥀</span>
      </div>
      <div className="t-display t-allcaps" style={{ fontSize: 22, marginTop: 14 }}>🥀 gıcık</div>
      <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 13, marginTop: 4 }}>stratejist hint'i ile</div>
    </div>
    <div style={{ padding:'18px 24px 0', display:'flex', gap: 10 }}>
      {[['47','cevap üretildi'],['12','gün aktif'],['82%','kopya oranı']].map(([n,l],i)=>(
        <div key={i} style={{ flex: 1, borderRadius: 14, background:'rgba(26,15,46,0.55)', border:'1px solid rgba(255,255,255,0.06)', padding:'14px 12px' }}>
          <div className="t-display" style={{ fontSize: 22, color:'#CCFF00' }}>{n}</div>
          <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 11, marginTop: 2 }}>{l}</div>
        </div>
      ))}
    </div>
    <div style={{ padding:'18px 24px 0' }}>
      {[
        ['kalibrasyonu yenile', null, true],
        ['abonelik', 'premium', true],
        ['veri ve yapay zeka', null, true],
        ['bildirimler', 'toggle', false],
        ['haptic geri bildirim', 'toggle-on', false],
        ['dil', 'türkçe', true],
      ].map(([t, val, chev], i) => (
        <div key={i} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'14px 0', borderBottom:'1px solid rgba(255,255,255,0.06)' }}>
          <span style={{ fontSize: 15, color:'rgba(255,255,255,0.9)' }}>{t}</span>
          <span style={{ display:'flex', alignItems:'center', gap: 10 }}>
            {val === 'premium' && <span className="t-mono" style={{ fontSize: 10, padding:'3px 8px', borderRadius: 999, background:'rgba(204,255,0,0.12)', color:'#CCFF00' }}>PREMIUM</span>}
            {val === 'toggle' && <div style={{ width: 40, height: 24, borderRadius: 999, background:'rgba(255,255,255,0.1)', border:'1px solid rgba(255,255,255,0.15)', position:'relative' }}><div style={{ position:'absolute', left: 2, top: 2, width: 18, height: 18, borderRadius: 999, background:'rgba(255,255,255,0.4)' }}/></div>}
            {val === 'toggle-on' && <div style={{ width: 40, height: 24, borderRadius: 999, background:'var(--holo)', position:'relative', boxShadow:'0 0 8px rgba(255,0,128,0.4)' }}><div style={{ position:'absolute', right: 2, top: 2, width: 18, height: 18, borderRadius: 999, background:'#fff' }}/></div>}
            {val === 'türkçe' && <span style={{ color:'rgba(255,255,255,0.5)', fontSize: 14 }}>türkçe</span>}
            {chev && <span style={{ color:'rgba(255,255,255,0.3)' }}>{Ico.chevR}</span>}
          </span>
        </div>
      ))}
    </div>
    <div style={{ position:'absolute', bottom: 24, left: 24, right: 24, textAlign:'center' }}>
      <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 14 }}>çıkış yap</div>
      <div className="t-mono" style={{ color:'rgba(255,255,255,0.3)', fontSize: 10, marginTop: 12 }}>v1.0.0 / build 42 / made in silivri</div>
    </div>
  </Phone>
);

const EmptyState = ({ kind }) => {
  const variants = {
    history: {
      icon: (
        <div style={{ position:'relative', width: 140, height: 140, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <div style={{ position:'absolute', inset:-10, borderRadius:999, background:'radial-gradient(closest-side, rgba(255,0,128,0.4), transparent 70%)', filter:'blur(20px)' }}/>
          {[120, 80, 44].map((s, i) => (
            <div key={i} style={{ position:'absolute', width: s, height: s, borderRadius: 999, border:'1px solid rgba(255,255,255,0.12)', opacity: 1 - i*0.2 }}/>
          ))}
          <div style={{ width: 12, height: 12, borderRadius: 999, background:'#FF0080', boxShadow:'0 0 14px #FF0080' }}/>
        </div>
      ),
      text: 'henüz kullanmadın. yukarıdan başla.',
      cta: null,
    },
    network: {
      icon: <div style={{ width: 96, height: 96, borderRadius: 999, border:'1.5px dashed rgba(255,255,255,0.4)', borderStyle:'dashed' }}/>,
      text: 'bağlantı yok. wifi ya da hücresel?',
      cta: ['secondary', 'tekrar dene'],
    },
    rate: {
      icon: <div style={{ position:'relative', width: 70, height: 80, display:'flex', alignItems:'center', justifyContent:'center' }}>
        <div style={{ position:'absolute', inset:-10, borderRadius:999, background:'radial-gradient(closest-side, rgba(204,255,0,0.18), transparent 70%)', filter:'blur(14px)' }}/>
        <svg width="60" height="68" viewBox="0 0 60 68" fill="none">
          <rect x="6" y="30" width="48" height="34" rx="6" stroke="url(#h)" strokeWidth="1.5"/>
          <path d="M16 30v-8a14 14 0 0128 0v8" stroke="url(#h)" strokeWidth="1.5"/>
          <defs><linearGradient id="h" x1="0" y1="0" x2="60" y2="60"><stop stopColor="#FF0080"/><stop offset="0.5" stopColor="#8000FF"/><stop offset="1" stopColor="#00FFFF"/></linearGradient></defs>
        </svg>
      </div>,
      text: 'bugünlük bitti. yarın yine ya da sınırsız aç.',
      cta: ['primary', 'sınırsız aç'],
    },
    unsupported: {
      icon: <div style={{ width: 96, height: 96, borderRadius: 999, border:'1.5px dashed rgba(255,255,255,0.3)', display:'flex', alignItems:'center', justifyContent:'center', fontSize: 36, color:'rgba(255,255,255,0.7)' }}>?</div>,
      text: 'bu görüntüde bir konuşma bulamadım. başka birini dene.',
      cta: ['secondary', 'başka görüntü'],
    },
  };
  const v = variants[kind];
  return (
    <Phone>
      <div style={{ position:'absolute', inset: 0, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding:'0 40px', textAlign:'center', gap: 24 }}>
        {v.icon}
        <div style={{ color:'rgba(255,255,255,0.85)', fontSize: 16, fontStyle: kind==='history' ? 'italic':'normal', lineHeight: 1.45 }}>
          {v.text}
        </div>
        {v.cta && (
          <div style={{ width:'100%', maxWidth: 280, marginTop: 4 }}>
            {v.cta[0] === 'primary'
              ? <button className="btn-primary">{v.cta[1]}</button>
              : <button className="btn-secondary">{v.cta[1]}</button>}
          </div>
        )}
      </div>
    </Phone>
  );
};

Object.assign(window, { Generation, Result, Profile, EmptyState });
