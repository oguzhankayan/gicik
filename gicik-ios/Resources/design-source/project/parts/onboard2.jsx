/* Demo upload, notification permission, AI consent, paywall */

const FauxScreenshot = () => (
  <div style={{ position:'relative', width: 240, borderRadius: 18, overflow:'hidden', border:'1px solid rgba(255,255,255,0.1)', background:'#1A0F2E' }}>
    <div style={{ position:'absolute', inset: 0, padding:1, borderRadius:18, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude', pointerEvents:'none', opacity: 0.6 }}/>
    <div style={{
      height: 180,
      background: 'repeating-linear-gradient(135deg, rgba(255,255,255,0.04) 0 8px, rgba(255,255,255,0.06) 8px 16px), linear-gradient(135deg, #2D1B4E, #1A0F2E)',
      display:'flex', alignItems:'flex-end', padding: 12, position:'relative',
    }}>
      <span className="t-mono" style={{ position:'absolute', top: 10, right: 10, color:'#CCFF00', fontSize: 10, padding:'3px 7px', borderRadius:999, border:'1px solid rgba(204,255,0,0.4)' }}>DEMO</span>
      <div>
        <div style={{ fontSize: 18, fontWeight: 600 }}>Mira, 27</div>
        <div style={{ fontSize: 13, color:'rgba(255,255,255,0.7)', marginTop: 2 }}>kahve, kitap, kedi.<br/>üçü de huysuz.</div>
      </div>
    </div>
  </div>
);

const DemoUpload = () => (
  <Phone>
    <TopBar active={5} total={8}/>
    <div style={{ padding:'8px 24px 0' }}>
      <div className="t-mono" style={{ color:'rgba(255,255,255,0.5)', fontSize: 11 }}>DEMO / DENEME</div>
      <div className="t-display t-allcaps" style={{ fontSize: 26, marginTop: 8 }}>böyle bir şey</div>
    </div>
    <div style={{ padding:'18px 24px 0', display:'flex', justifyContent:'center' }}>
      <FauxScreenshot/>
    </div>
    <div style={{ padding:'18px 24px 0' }}>
      <Obs>kahve klişesi var ama 'huysuz' iyi detay. oradan tut.</Obs>
    </div>
    <div style={{ padding:'14px 24px 110px', display:'flex', flexDirection:'column', gap: 10, overflow:'auto', maxHeight: 360 }}>
      <ReplyCard label="01 — SPESİFİK" text="huysuz kediyle huysuz insan arasında fark var mı?"/>
      <ReplyCard label="02 — SORU" text="üç huysuzluğun ortak özelliği ne?"/>
      <ReplyCard label="03 — İRONİ" text="kahve, kitap, kedi listene 'huy' eklersen tehlikeli oluyor."/>
      <ReplyCard label="04 — DİREKT" text="mira, profilin bana fazla iyi görünüyor. neredesin?"/>
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <button className="btn-secondary">ben de denemek istiyorum →</button>
    </div>
  </Phone>
);

const NotificationPermission = () => (
  <Phone>
    <TopBar active={6} total={8} back={false}/>
    <div style={{ position:'absolute', inset:'90px 0 200px', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
      <div style={{ position:'relative', width: 200, height: 160, display:'flex', alignItems:'center', justifyContent:'center' }}>
        <div className="pulse-glow" style={{ position:'absolute', inset:-30, borderRadius:999, background:'radial-gradient(closest-side, rgba(255,0,128,0.5), transparent 70%)', filter:'blur(24px)' }}/>
        {Ico.envelope}
      </div>
      <div className="t-display t-allcaps" style={{ fontSize: 28, textAlign:'center', marginTop: 36, lineHeight: 1.05 }}>
        gıcık sana<br/>haber versin
      </div>
      <div style={{ color:'rgba(255,255,255,0.7)', fontSize: 15, lineHeight: 1.45, textAlign:'center', padding:'14px 28px 0' }}>
        yeni mod geldiğinde, prompt güncellendiğinde,<br/>ya da tarzına bir şey eklediğimizde.<br/>seyrek. sıkıcı değil.
      </div>
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <button className="btn-primary">izin ver</button>
      <div style={{ textAlign:'center', marginTop: 14 }}>
        <span style={{ color:'rgba(255,255,255,0.4)', fontSize: 14 }}>şimdi değil</span>
      </div>
    </div>
  </Phone>
);

const AIConsent = () => (
  <Phone>
    <div style={{ display:'flex', alignItems:'center', padding:'60px 20px 8px', gap: 14 }}>
      <span style={{ color:'rgba(255,255,255,0.7)' }}>{Ico.back}</span>
      <span style={{ fontSize: 16, color:'rgba(255,255,255,0.85)' }}>veri ve yapay zeka</span>
    </div>
    <div style={{ padding:'12px 24px 0' }}>
      <div className="t-display t-allcaps" style={{ fontSize: 22, lineHeight: 1.1 }}>açıkça<br/>ne oluyor</div>
    </div>
    <div style={{ padding:'24px 24px 220px', overflow:'auto', maxHeight: 460 }}>
      {[
        ['EKRAN GÖRÜNTÜLERİN', [
          'yüklediğin görüntü 24 saat sonra silinir.',
          'üzerindeki yazıyı yorumlamak için yapay zeka modellerine gönderilir.',
          'isimleri otomatik bulanıklaştırmaya çalışıyoruz, deneysel.',
        ]],
        ['KONUŞMA KAYITLARIN', [
          'ürettiğimiz cevaplar 30 gün saklanır.',
          'hangi cevabı seçtiğini, geri bildirimini gözlemleriz.',
          'modeli senin tarzına göre eğitmek için kullanmıyoruz, sadece kalibre ediyoruz.',
        ]],
        ['HAKLARIN', [
          ['verilerini istediğin an silebilirsin', true],
          ['dışa aktarabilirsin', true],
          ['kalibrasyonu yenileyebilirsin', true],
        ]],
      ].map(([h, items], si) => (
        <div key={si} style={{ marginBottom: 24 }}>
          <div className="t-mono" style={{ color:'#CCFF00', fontSize: 11, marginBottom: 12 }}>{h}</div>
          {items.map((it, i) => {
            if (Array.isArray(it)) {
              return <div key={i} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'14px 0', borderBottom:'1px solid rgba(255,255,255,0.06)' }}>
                <span style={{ color:'rgba(255,255,255,0.85)', fontSize: 15 }}>{it[0]}</span>
                <span style={{ color:'rgba(255,255,255,0.4)' }}>{Ico.chevR}</span>
              </div>;
            }
            return <div key={i} style={{ color:'rgba(255,255,255,0.7)', fontSize: 15, lineHeight: 1.5, marginBottom: 6 }}>{it}</div>;
          })}
        </div>
      ))}
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <div style={{
        display:'flex', alignItems:'center', justifyContent:'space-between',
        padding:'14px 16px', borderRadius: 14,
        background:'rgba(26,15,46,0.6)', border:'1px solid rgba(255,255,255,0.08)', marginBottom: 14,
      }}>
        <span style={{ fontSize: 14 }}>yapay zeka kullanımına onay veriyorum</span>
        <div style={{ width: 46, height: 28, borderRadius: 999, background:'var(--holo)', position:'relative', boxShadow:'0 0 12px rgba(255,0,128,0.4)' }}>
          <div style={{ position:'absolute', right: 2, top: 2, width: 24, height: 24, borderRadius: 999, background:'#fff' }}/>
        </div>
      </div>
      <div style={{ color:'rgba(255,255,255,0.4)', fontSize: 11, marginBottom: 14, textAlign:'center' }}>bu olmadan çalışmaz. her zaman geri çekebilirsin.</div>
      <button className="btn-primary">kaydet</button>
    </div>
  </Phone>
);

const Paywall = () => (
  <Phone>
    <div style={{ padding:'60px 20px 8px', display:'flex', justifyContent:'flex-end' }}>
      <span style={{ color:'rgba(255,255,255,0.4)' }}>{Ico.close}</span>
    </div>
    <div style={{ padding:'10px 24px 0' }}>
      <div className="t-display t-allcaps" style={{ fontSize: 36, lineHeight: 1.0 }}>
        gıcık<br/>sınırsız
      </div>
      <div style={{ color:'rgba(255,255,255,0.7)', fontSize: 15, marginTop: 10 }}>
        tüm modlar. tüm tonlar.<br/>her gün.
      </div>
    </div>
    <div style={{ padding:'20px 24px 0', display:'flex', flexDirection:'column', gap: 10 }}>
      {['sınırsız cevap üretimi','5 modun hepsi (cevap, açılış, bio, hayalet, davet)','5 farklı ton','kalibrasyon güncellemeleri','yeni modlar geldiğinde önce sen'].map((t,i)=>(
        <div key={i} style={{ display:'flex', alignItems:'center', gap: 12, fontSize: 14, color:'rgba(255,255,255,0.9)' }}>
          {Ico.check} {t}
        </div>
      ))}
    </div>
    <div style={{ padding:'18px 24px 0', display:'flex', flexDirection:'column', gap: 10 }}>
      <div style={{ position:'relative', borderRadius: 18, padding: 16, background:'rgba(45,27,78,0.7)' }}>
        <span style={{position:'absolute', inset:0, padding:1.5, borderRadius:18, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude'}}/>
        <span style={{position:'absolute', inset:-12, borderRadius:18, background:'radial-gradient(closest-side, rgba(255,0,128,0.25), transparent 70%)', filter:'blur(14px)', zIndex:-1}}/>
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start' }}>
          <div>
            <div className="t-mono" style={{ color:'#CCFF00', fontSize: 10 }}>EN POPÜLER / 80% AVANTAJ</div>
            <div style={{ fontSize: 22, fontWeight: 700, marginTop: 6 }}>₺499 / yıl</div>
            <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 13, marginTop: 2 }}>ayda ₺41,5'e geliyor</div>
          </div>
          <div style={{ width: 22, height: 22, borderRadius: 999, background:'#CCFF00', display:'flex', alignItems:'center', justifyContent:'center' }}>
            <div style={{ width: 10, height: 10, borderRadius: 999, background:'#0A0612' }}/>
          </div>
        </div>
      </div>
      <div style={{ borderRadius: 18, padding: 16, background:'rgba(26,15,46,0.55)', border:'1px solid rgba(255,255,255,0.08)', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <div>
          <div style={{ fontSize: 18, fontWeight: 600 }}>₺49 / hafta</div>
          <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 13 }}>haftalık iptal edilebilir</div>
        </div>
        <div style={{ width: 22, height: 22, borderRadius: 999, border:'1.5px solid rgba(255,255,255,0.25)' }}/>
      </div>
    </div>
    <div style={{ padding:'14px 24px 0', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
      <div>
        <div style={{ fontSize: 15 }}>3 gün ücretsiz dene</div>
        <div style={{ color:'rgba(255,255,255,0.4)', fontSize: 11, marginTop: 2 }}>3 gün sonra otomatik fatura. istediğin an iptal.</div>
      </div>
      <div style={{ width: 46, height: 28, borderRadius: 999, background:'var(--holo)', position:'relative', boxShadow:'0 0 12px rgba(255,0,128,0.4)' }}>
        <div style={{ position:'absolute', right: 2, top: 2, width: 24, height: 24, borderRadius: 999, background:'#fff' }}/>
      </div>
    </div>
    <div style={{ position:'absolute', bottom: 28, left: 24, right: 24 }}>
      <button className="btn-primary holo-fill">ücretsiz başlat</button>
      <div style={{ display:'flex', justifyContent:'center', gap: 10, marginTop: 10, color:'rgba(255,255,255,0.4)', fontSize: 11 }}>
        <span>satın al</span><span>·</span><span>restore</span><span>·</span><span>şartlar</span><span>·</span><span>privacy</span>
      </div>
    </div>
  </Phone>
);

Object.assign(window, { DemoUpload, NotificationPermission, AIConsent, Paywall });
