/* Home, screenshot picker (3 states), tone selector */

const Home = () => (
  <Phone>
    <div style={{ padding:'58px 24px 0', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
      <div style={{ width: 36, height: 36, borderRadius: 999, background:'rgba(45,27,78,0.7)', border:'1px solid rgba(255,255,255,0.1)', display:'flex', alignItems:'center', justifyContent:'center', fontSize: 18 }}>🥀</div>
      <Logo size={26}/>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.gear}</span>
    </div>
    {/* archetype banner */}
    <div style={{ padding:'18px 24px 0' }}>
      <div style={{ position:'relative', height: 46, borderRadius: 999, background:'rgba(26,15,46,0.6)', display:'flex', alignItems:'center', padding:'0 18px', justifyContent:'space-between' }}>
        <span style={{position:'absolute', inset:0, padding:1, borderRadius:999, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude', opacity: 0.7}}/>
        <span style={{ fontSize: 14, color:'rgba(255,255,255,0.85)' }}><span style={{ marginRight: 6 }}>🥀</span>gıcık seni gıcık olarak biliyor</span>
        <span style={{ color:'rgba(255,255,255,0.5)' }}>{Ico.chevR}</span>
      </div>
    </div>
    {/* header */}
    <div style={{ padding:'24px 24px 12px' }}>
      <div className="t-mono" style={{ color:'#CCFF00', fontSize: 11 }}>MODLAR</div>
      <div className="t-display t-allcaps" style={{ fontSize: 22, marginTop: 8 }}>bugün ne deneyeceksin?</div>
    </div>
    {/* mode grid */}
    <div style={{ padding:'4px 24px 0', display:'grid', gridTemplateColumns:'1fr 1fr', gap: 10 }}>
      {[
        ['CEVAP', 'gelen mesaja cevap', Ico.reply, false],
        ['AÇILIŞ', 'ilk mesaj', Ico.spark, false],
        ['BIO', 'profil yazısı', Ico.bio, false],
        ['HAYALET', 'ghost edildi', Ico.ghost, false],
        ['DAVET', 'buluşmaya çağır', Ico.invite, false],
        ['YAKINDA', 'yeni mod', Ico.lock, true],
      ].map(([t, s, icon, locked], i) => (
        <div key={i} className="mode-card" style={{ opacity: locked ? 0.45 : 1 }}>
          <div style={{ color:'rgba(255,255,255,0.85)' }}>{icon}</div>
          <div>
            <div className="t-display t-allcaps" style={{ fontSize: 18 }}>{t}</div>
            <div style={{ color:'rgba(255,255,255,0.55)', fontSize: 12, marginTop: 2 }}>{s}</div>
          </div>
        </div>
      ))}
    </div>
    {/* history */}
    <div style={{ padding:'20px 0 0' }}>
      <div className="t-mono" style={{ color:'#CCFF00', fontSize: 11, padding:'0 24px 10px' }}>SON KULLANIM</div>
      <div style={{ display:'flex', gap: 10, padding:'0 24px', overflowX:'auto' }}>
        {[
          ['cevap', 'tinder', '12dk önce', '"huysuzluğun ortak özelliği..."'],
          ['açılış', 'bumble', '2sa önce', '"profilin bana fazla iyi..."'],
          ['hayalet', 'instagram', 'dün', '"3 gün cevap yok, sonra..."'],
        ].map(([m, p, t, snip], i) => (
          <div key={i} style={{ flex:'0 0 150px', padding: 12, borderRadius: 14, background:'rgba(26,15,46,0.5)', border:'1px solid rgba(255,255,255,0.05)' }}>
            <div className="t-mono" style={{ color:'rgba(255,255,255,0.5)', fontSize: 10 }}>{p.toUpperCase()} · {t}</div>
            <div className="t-display t-allcaps" style={{ fontSize: 13, marginTop: 6 }}>{m}</div>
            <div style={{ color:'rgba(255,255,255,0.7)', fontSize: 11, marginTop: 6, lineHeight: 1.3 }}>{snip}</div>
          </div>
        ))}
      </div>
    </div>
  </Phone>
);

const PickerShell = ({ children }) => (
  <Phone>
    <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'60px 20px 8px' }}>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.back}</span>
      <span style={{ fontSize: 16, color:'rgba(255,255,255,0.85)' }}>cevap modu</span>
      <span style={{ width: 20 }}/>
    </div>
    <div style={{ padding:'10px 24px 0' }}>
      <div className="t-display t-allcaps" style={{ fontSize: 24, lineHeight: 1.05 }}>ekran görüntüsünü<br/>yükle</div>
      <div style={{ color:'rgba(255,255,255,0.7)', fontSize: 14, marginTop: 10 }}>
        konuşmanın olduğu kadar göstermen yeter.<br/>kim olduğun gizli kalır.
      </div>
    </div>
    {children}
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <button className="btn-secondary">örnek görüntü kullan</button>
    </div>
  </Phone>
);

const PickerEmpty = () => (
  <PickerShell>
    <div style={{ padding:'24px 24px 0' }}>
      <div style={{
        height: 280, borderRadius: 18,
        border: '1.5px dashed rgba(255,255,255,0.2)',
        display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
        gap: 14, color:'rgba(255,255,255,0.6)',
      }}>
        {Ico.upload}
        <div style={{ fontSize: 16, color:'rgba(255,255,255,0.85)' }}>fotoğraflardan seç</div>
        <div style={{ fontSize: 13, color:'rgba(255,255,255,0.45)' }}>veya buraya sürükle</div>
      </div>
      <div className="obs" style={{ marginTop: 16 }}>
        <p style={{ fontStyle:'normal', fontSize: 13 }}>screenshot 24 saat sonra silinir. isimleri otomatik bulanıklaştırırız (deneysel).</p>
      </div>
    </div>
  </PickerShell>
);

const FauxChat = () => (
  <div style={{
    width:'100%', height: '100%',
    background: 'repeating-linear-gradient(135deg, rgba(255,255,255,0.04) 0 8px, rgba(255,255,255,0.06) 8px 16px), linear-gradient(160deg, #2D1B4E, #1A0F2E)',
    padding: 14, display:'flex', flexDirection:'column', gap: 8,
  }}>
    {[['l','akşam ne yapıyon'],['r','huysuz kediyle huysuz insan, ikimizden biri kahve içecek'],['l','demek ki ikimiz buluşacağız'],['l','11 cumartesi?']].map(([s,t],i)=>(
      <div key={i} style={{
        alignSelf: s==='l'?'flex-start':'flex-end',
        maxWidth:'78%', padding:'8px 12px', borderRadius: 14,
        background: s==='l' ? 'rgba(255,255,255,0.12)' : 'rgba(255,0,128,0.5)',
        fontSize: 12, color:'#fff', filter:'blur(0.4px)',
      }}>{t}</div>
    ))}
  </div>
);

const PickerProgress = () => (
  <PickerShell>
    <div style={{ padding:'24px 24px 0' }}>
      <div style={{ position:'relative', height: 280, borderRadius: 18, overflow:'hidden', border:'1px solid rgba(255,255,255,0.1)' }}>
        <FauxChat/>
        <div className="shimmer" style={{ position:'absolute', inset: 0, mixBlendMode:'screen', opacity: 0.6 }}/>
        <div style={{
          position:'absolute', bottom: 0, left:0, right:0, padding:'14px 16px',
          background:'linear-gradient(to top, rgba(10,6,18,0.95), transparent)',
          color:'#fff', fontSize: 14,
        }}>
          <span className="t-mono" style={{ color:'#CCFF00' }}>● </span>yorumlanıyor…
        </div>
      </div>
    </div>
  </PickerShell>
);

const PickerComplete = () => (
  <PickerShell>
    <div style={{ padding:'24px 24px 0' }}>
      <div style={{ position:'relative', height: 280, borderRadius: 18, overflow:'hidden' }}>
        <span style={{position:'absolute', inset:0, padding:1, borderRadius:18, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude', pointerEvents:'none', zIndex: 4}}/>
        <FauxChat/>
        <div style={{ position:'absolute', top: 10, right: 10, width: 28, height: 28, borderRadius: 999, background:'#CCFF00', display:'flex', alignItems:'center', justifyContent:'center', color:'#0A0612', fontSize: 14, zIndex: 5 }}>✓</div>
      </div>
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <button className="btn-primary">devam</button>
    </div>
  </PickerShell>
);

// Override the secondary button visible on PickerComplete (we replaced footer)
const ToneSelector = () => (
  <Phone>
    <div style={{ display:'flex', alignItems:'center', padding:'60px 20px 8px', gap: 10 }}>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.back}</span>
      <span style={{ color:'rgba(255,255,255,0.5)', fontSize: 13 }}>cevap › ton seç</span>
    </div>
    <div style={{ padding:'8px 24px 0', display:'flex', justifyContent:'space-between', alignItems:'flex-start' }}>
      <div>
        <div className="t-display t-allcaps" style={{ fontSize: 24, lineHeight: 1.05 }}>ne tonda<br/>konuşacağız?</div>
      </div>
      <div style={{ width: 60, height: 80, borderRadius: 10, background:'repeating-linear-gradient(135deg, rgba(255,255,255,0.05) 0 4px, rgba(255,255,255,0.08) 4px 8px), #1A0F2E', border:'1px solid rgba(255,255,255,0.1)' }}/>
    </div>
    <div style={{ padding:'18px 24px 0' }}>
      <Obs>konuşmaya bakınca sıcak çıkan bir hat var. flörtöz işler ama esprili daha güvenli.</Obs>
    </div>
    <div style={{ padding:'18px 24px 0', display:'flex', flexDirection:'column', gap: 10 }}>
      {[
        ['💋','FLÖRTÖZ','ima + cesaret + kapatıcı', false, false],
        ['😏','ESPRİLİ','zekayla flört, pun yok', true, true],
        ['🎯','DİREKT','net, oyalamayan, saygılı', false, false],
        ['🤍','SICAK','samimi, biraz vulnerable', false, false],
        ['🌑','GİZEMLİ','az veren, merak uyandıran', false, false],
      ].map(([e, t, d, sel, rec], i) => (
        <div key={i} style={{
          position:'relative', height: 72, borderRadius: 16,
          background: sel ? 'rgba(45,27,78,0.65)' : 'rgba(26,15,46,0.55)',
          border:'1px solid rgba(255,255,255,0.08)',
          display:'flex', alignItems:'center', padding:'0 18px', gap: 14,
        }}>
          {sel && <span style={{position:'absolute', inset:0, padding:1, borderRadius:16, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude'}}/>}
          {sel && <span style={{position:'absolute', left:0, top:14, bottom:14, width: 3, borderRadius:2, background:'#CCFF00'}}/>}
          <span style={{ fontSize: 22 }}>{e}</span>
          <div style={{ flex: 1 }}>
            <div className="t-display t-allcaps" style={{ fontSize: 16 }}>{t}</div>
            <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 12, marginTop: 2 }}>{d}</div>
          </div>
          {rec && <span style={{ fontSize: 10, color:'#CCFF00', padding:'4px 10px', borderRadius: 999, border:'1px solid rgba(204,255,0,0.4)' }} className="t-mono">ÖNERİLEN</span>}
        </div>
      ))}
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <button className="btn-primary">üret</button>
    </div>
  </Phone>
);

Object.assign(window, { Home, PickerEmpty, PickerProgress, PickerComplete, ToneSelector });
