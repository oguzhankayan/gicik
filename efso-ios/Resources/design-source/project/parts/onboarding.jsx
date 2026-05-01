/* Onboarding screens — splash, demographic, calibration intro */

const SplashScreen = () => (
  <Phone>
    <div style={{ position:'absolute', inset: 0, display:'flex', flexDirection:'column' }}>
      {/* glow halo */}
      <div style={{
        position:'absolute', top: '32%', left:'50%', transform:'translate(-50%, -50%)',
        width: 360, height: 360, borderRadius: 999,
        background: 'radial-gradient(closest-side, rgba(255,0,128,0.5), rgba(128,0,255,0.3) 50%, transparent 75%)',
        filter: 'blur(40px)', pointerEvents:'none',
      }}/>
      <div style={{ flex: 1, display:'flex', flexDirection:'column', justifyContent:'center', alignItems:'center', paddingTop: 80 }}>
        <Logo size={88}/>
        <div style={{ marginTop: 28, color: 'rgba(255,255,255,0.7)', fontSize: 16, letterSpacing:'-0.01em' }}>
          yazma. gıcık yazsın.
        </div>
      </div>
      <div style={{ padding: '0 24px 48px', position:'relative', zIndex: 5 }}>
        <button className="btn-primary">başla</button>
        <div style={{ textAlign:'center', marginTop: 14, color:'rgba(255,255,255,0.4)', fontSize: 12 }}>
          giriş yaparak şartları kabul ediyorsun
        </div>
      </div>
    </div>
  </Phone>
);

const DemographicScreen = () => (
  <Phone>
    <TopBar active={0} total={8}/>
    <div style={{ padding: '8px 24px 0' }}>
      <div className="t-mono" style={{ color:'#CCFF00', fontSize: 11 }}>01 / KISA TANIŞMA</div>
      <div className="t-display t-allcaps" style={{ fontSize: 30, marginTop: 12, lineHeight: 1.05 }}>
        önce biraz<br/>tanışalım
      </div>

      <div style={{ marginTop: 36 }}>
        <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 14, marginBottom: 12 }}>cinsiyet</div>
        <div style={{ display:'flex', gap: 8, flexWrap:'wrap' }}>
          <Chip lg selected>kadın</Chip>
          <Chip lg>erkek</Chip>
          <Chip lg>belirtmiyorum</Chip>
        </div>
      </div>

      <div style={{ marginTop: 28 }}>
        <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 14, marginBottom: 12 }}>yaş</div>
        <div style={{ display:'flex', gap: 8, flexWrap:'wrap' }}>
          <Chip lg>18-24</Chip>
          <Chip lg selected>25-34</Chip>
          <Chip lg>35-44</Chip>
          <Chip lg>45+</Chip>
        </div>
      </div>

      <div style={{ marginTop: 28 }}>
        <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 14, marginBottom: 12 }}>ne arıyorsun</div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 10 }}>
          {[['💞','ilişki', false],['🌙','casual', true],['🎭','eğlence', false],['💍','birlikteyim', false]].map(([e,t,sel],i)=>(
            <div key={i} style={{
              height: 80, borderRadius: 16,
              background: sel ? 'rgba(45,27,78,0.6)' : 'rgba(26,15,46,0.55)',
              border: '1px solid rgba(255,255,255,0.08)',
              display:'flex', alignItems:'center', gap: 12, padding:'0 16px',
              position:'relative',
            }} className={sel ? '' : ''}>
              {sel && <span style={{position:'absolute', inset:0, padding:1, borderRadius:16, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude', pointerEvents:'none'}}/>}
              <span style={{ fontSize: 22 }}>{e}</span>
              <span style={{ fontSize: 16 }}>{t}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <button className="btn-primary">devam</button>
    </div>
  </Phone>
);

const CalibrationIntro = () => (
  <Phone>
    <TopBar active={1} total={8}/>
    <div style={{ position:'absolute', inset:'90px 0 120px', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
      {/* orbital */}
      <div style={{ position:'relative', width: 280, height: 280, display:'flex', alignItems:'center', justifyContent:'center' }}>
        <div style={{ position:'absolute', inset:0, borderRadius:999, background:'radial-gradient(closest-side, rgba(255,0,128,0.35), transparent 70%)', filter:'blur(30px)' }}/>
        {[260, 200, 140, 90].map((s, i) => (
          <div key={i} className="spin-slow" style={{
            position:'absolute', width: s, height: s, borderRadius: 999,
            border: '1px solid transparent',
            background: 'linear-gradient(110deg, #FF0080, #8000FF, #00FFFF, #00FF80) border-box',
            WebkitMask: 'linear-gradient(#000 0 0) padding-box, linear-gradient(#000 0 0)',
            WebkitMaskComposite: 'xor', maskComposite: 'exclude',
            opacity: 0.7 - i * 0.1,
            animationDuration: `${20 + i * 6}s`,
            animationDirection: i % 2 ? 'reverse' : 'normal',
          }}/>
        ))}
        <div className="pulse-glow" style={{ width: 18, height: 18, borderRadius: 999, background:'#fff', boxShadow:'0 0 20px #FF0080, 0 0 40px #8000FF' }}/>
      </div>
      <div className="t-display t-allcaps" style={{ fontSize: 30, marginTop: 32, textAlign:'center' }}>
        gıcık'ı kalibre et
      </div>
      <div style={{ color:'rgba(255,255,255,0.7)', fontSize: 15, marginTop: 10, textAlign:'center', padding:'0 32px', lineHeight: 1.45 }}>
        9 soru. 2 dakika. soru sormaya gerek yok,<br/>gözlem yapmamız gerek.
      </div>
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <div style={{ display:'flex', justifyContent:'center', gap: 18, marginBottom: 18, color:'rgba(255,255,255,0.6)', fontSize: 13 }}>
        <span><span style={{color:'#CCFF00'}}>●</span> 9 soru</span>
        <span><span style={{color:'#CCFF00'}}>●</span> ~2 dk</span>
        <span><span style={{color:'#CCFF00'}}>●</span> atlanamaz</span>
      </div>
      <button className="btn-primary">başla</button>
    </div>
  </Phone>
);

Object.assign(window, { SplashScreen, DemographicScreen, CalibrationIntro });
