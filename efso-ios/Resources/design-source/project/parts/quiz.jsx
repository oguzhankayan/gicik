/* Quiz variants A-F + Calibration result reveal */

const QuizShell = ({ qNum = 4, total = 9, label, question, sub, children, footerLink }) => (
  <Phone>
    <TopBar active={1} total={8} close/>
    <div style={{ padding:'8px 24px 0' }}>
      <div className="t-mono" style={{ color:'#CCFF00', fontSize: 11 }}>
        {String(qNum).padStart(2,'0')} / {String(total).padStart(2,'0')}
      </div>
      <div className="t-display t-allcaps" style={{ fontSize: 26, marginTop: 12, lineHeight: 1.1 }}>
        {question}
      </div>
      {sub && <div style={{ color:'rgba(255,255,255,0.6)', fontSize: 14, marginTop: 10 }}>{sub}</div>}
    </div>
    <div style={{ padding:'28px 24px 0' }}>{children}</div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      {footerLink && <div style={{ textAlign:'center', marginBottom: 14 }}>
        <span style={{ color:'rgba(255,255,255,0.4)', fontSize: 13, textDecoration:'underline' }}>{footerLink}</span>
      </div>}
      <button className="btn-primary">devam</button>
    </div>
  </Phone>
);

// VARIANT A — single select chips (stacked rows)
const QuizSingleSelect = () => (
  <QuizShell qNum={3} question="mizah tarzın" sub="hangisi sana en yakın">
    <div style={{ display:'flex', flexDirection:'column', gap: 10 }}>
      {[
        ['dry, deadpan', false],
        ['sarcasm, iğneli', true],
        ['absurd, saçma', false],
        ['wholesome, şirin', false],
      ].map(([t,sel],i) => (
        <div key={i} style={{
          height: 56, borderRadius: 14,
          background: sel ? 'rgba(45,27,78,0.6)' : 'rgba(26,15,46,0.55)',
          border:'1px solid rgba(255,255,255,0.08)',
          display:'flex', alignItems:'center', padding:'0 18px',
          position:'relative', fontSize: 15,
        }}>
          {sel && <span style={{position:'absolute', inset:0, padding:1, borderRadius:14, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude', pointerEvents:'none'}}/>}
          {t}
        </div>
      ))}
    </div>
  </QuizShell>
);

// VARIANT B — binary scenario
const QuizBinary = () => (
  <QuizShell qNum={4} question={"arkadaşın kötü bir karar\nalmak üzere"} footerLink="ikisi de değil">
    <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 12 }}>
      {[
        ['💬', 'açıkça\nsöylerim', false],
        ['🤔', 'soru sorarım,\nkendi görsün', true],
      ].map(([e,t,sel],i) => (
        <div key={i} style={{
          height: 200, borderRadius: 18, padding: 18,
          background: sel ? 'rgba(45,27,78,0.6)' : 'rgba(26,15,46,0.55)',
          border: '1px solid rgba(255,255,255,0.08)',
          display:'flex', flexDirection:'column', justifyContent:'space-between',
          position:'relative',
        }}>
          {sel && <span style={{position:'absolute', inset:0, padding:1, borderRadius:18, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude'}}/>}
          <span style={{ fontSize: 28 }}>{e}</span>
          <span style={{ fontSize: 17, lineHeight: 1.3, whiteSpace:'pre-line', fontWeight: 500 }}>{t}</span>
        </div>
      ))}
    </div>
  </QuizShell>
);

// VARIANT C — likert 1-5
const QuizLikert = () => (
  <QuizShell qNum={5} question={"flört ederken risk\nalır mısın?"}>
    <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'30px 8px 16px' }}>
      {[1,2,3,4,5].map(n => {
        const active = n === 4;
        return (
          <div key={n} style={{ position:'relative' }}>
            {active && <div style={{ position:'absolute', inset: -10, borderRadius:999, background:'radial-gradient(closest-side, rgba(255,0,128,0.4), transparent 70%)', filter:'blur(8px)'}}/>}
            <div style={{
              width: active ? 28 : 18, height: active ? 28 : 18, borderRadius: 999,
              background: active ? 'linear-gradient(135deg,#FF0080,#8000FF,#00FFFF)' : 'rgba(255,255,255,0.12)',
              border: active ? 'none' : '1px solid rgba(255,255,255,0.15)',
              transition:'all .3s',
            }}/>
          </div>
        );
      })}
    </div>
    <div style={{ display:'flex', justifyContent:'space-between', color:'rgba(255,255,255,0.5)', fontSize: 13, padding:'0 4px' }}>
      <span>asla</span>
      <span>şartlara göre</span>
      <span>evet</span>
    </div>
  </QuizShell>
);

// VARIANT D — slider
const QuizSlider = () => (
  <QuizShell qNum={6} question={"yazma stilin"}>
    <div style={{ padding:'30px 0 12px' }}>
      <div style={{ position:'relative', height: 4, borderRadius: 999, background:'rgba(255,255,255,0.08)' }}>
        <div style={{ position:'absolute', inset:'0 35% 0 0', borderRadius: 999, background:'var(--holo)' }}/>
        <div style={{ position:'absolute', left:'65%', top:'50%', transform:'translate(-50%,-50%)', width: 28, height: 28, borderRadius: 999, background:'#fff', boxShadow:'0 0 16px rgba(255,0,128,0.5)' }}/>
      </div>
      <div style={{ display:'flex', justifyContent:'space-between', marginTop: 24, color:'rgba(255,255,255,0.5)', fontSize: 13 }}>
        <span>yarı formal</span>
        <span>amk yaa abi</span>
      </div>
    </div>
  </QuizShell>
);

// VARIANT E — image-style binary stacked
const QuizImageBinary = () => (
  <QuizShell qNum={7} question={"hangisi senin gibi"}>
    <div style={{ display:'flex', flexDirection:'column', gap: 12 }}>
      {[
        ['ilk mesajı ben atarım', false],
        ['o yazarsa yazarım', true],
      ].map(([t,sel],i) => (
        <div key={i} style={{
          position:'relative', height: 130, borderRadius: 18, padding:'18px 20px 18px 26px',
          background: sel ? 'rgba(45,27,78,0.6)' : 'rgba(26,15,46,0.55)',
          border:'1px solid rgba(255,255,255,0.08)',
          display:'flex', alignItems:'center',
        }}>
          <div style={{ position:'absolute', left: 10, top: 18, bottom: 18, width: 3, borderRadius: 2, background: sel ? 'var(--holo)' : 'rgba(204,255,0,0.6)' }}/>
          {sel && <span style={{position:'absolute', inset:0, padding:1, borderRadius:18, background:'var(--holo)', WebkitMask:'linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0)', WebkitMaskComposite:'xor', maskComposite:'exclude'}}/>}
          <span style={{ fontSize: 18, flex: 1, fontWeight: 500 }}>{t}</span>
          {sel && <span style={{ width: 24, height: 24, borderRadius: 999, background:'#CCFF00', display:'flex', alignItems:'center', justifyContent:'center', color:'#0A0612', fontSize: 14 }}>✓</span>}
        </div>
      ))}
    </div>
  </QuizShell>
);

// VARIANT F — free text
const QuizFreeText = () => (
  <QuizShell qNum={9} question={"son flört ettiğin\nmesajdan bir parça"} sub="opsiyonel. atlayabilirsin." footerLink="atla">
    <textarea readOnly defaultValue={"yarın boşsan dünyanın en huysuz kahvecisinde 11 nasıl"} style={{
      width:'100%', minHeight: 160, padding: 16,
      background:'rgba(26,15,46,0.55)',
      border:'1px solid rgba(255,255,255,0.1)',
      borderRadius: 12, color:'#fff', fontSize: 16,
      fontFamily:'inherit', resize: 'none', outline: 'none',
    }}/>
    <div className="t-mono" style={{ color:'rgba(255,255,255,0.4)', fontSize: 11, marginTop: 8, textAlign:'right' }}>
      53 / 500 KARAKTER
    </div>
  </QuizShell>
);

// CALIBRATION RESULT REVEAL
const CalibrationResult = () => (
  <Phone>
    <div style={{ padding:'60px 20px 8px', display:'flex', justifyContent:'flex-end' }}>
      <span style={{ color:'rgba(255,255,255,0.7)', fontSize: 16 }}>tamam</span>
    </div>
    <div style={{ padding:'10px 24px 0', display:'flex', flexDirection:'column', alignItems:'center' }}>
      {/* hero orbital with archetype */}
      <div style={{ position:'relative', width: 240, height: 240, display:'flex', alignItems:'center', justifyContent:'center', marginTop: 8 }}>
        <div style={{ position:'absolute', inset:-30, borderRadius:999, background:'radial-gradient(closest-side, rgba(255,0,128,0.55), rgba(128,0,255,0.3) 50%, transparent 80%)', filter:'blur(28px)' }}/>
        {[230, 175, 125].map((s,i) => (
          <div key={i} className="spin-slow" style={{
            position:'absolute', width: s, height: s, borderRadius: 999,
            background: 'linear-gradient(110deg, #FF0080, #8000FF, #00FFFF, #00FF80) border-box',
            WebkitMask: 'linear-gradient(#000 0 0) padding-box, linear-gradient(#000 0 0)',
            WebkitMaskComposite: 'xor', maskComposite: 'exclude',
            border:'1px solid transparent',
            opacity: 0.6 - i*0.05,
            animationDuration: `${30 + i*8}s`,
          }}/>
        ))}
        <div style={{ fontSize: 80, filter:'drop-shadow(0 0 22px rgba(255,0,128,0.7))' }}>🥀</div>
      </div>

      <div className="t-mono" style={{ color:'#CCFF00', fontSize: 11, marginTop: 18 }}>SENİN TARZIN…</div>
      <div className="t-display t-allcaps" style={{ fontSize: 40, letterSpacing:'-0.01em', marginTop: 6 }}>
        gıcık
      </div>

      <div style={{ width:'100%', marginTop: 24, display:'flex', flexDirection:'column', gap: 10 }}>
        <Obs>spesifik gözlem yaparsın, klişe sevmezsin</Obs>
        <Obs>kısa cümle, nokta dostusun</Obs>
        <Obs>soğuk değilsin ama mesafe seversin</Obs>
      </div>
    </div>
    <div style={{ position:'absolute', bottom: 32, left: 24, right: 24 }}>
      <div style={{ textAlign:'center', marginBottom: 14, color:'rgba(255,255,255,0.4)', fontSize: 11, fontFamily:'var(--mono)' }}>
        HER ZAMAN DEĞİŞEBİLİR. AYARLARDAN.
      </div>
      <button className="btn-primary">devam et</button>
      <div style={{ textAlign:'center', marginTop: 10 }}>
        <span style={{ color:'rgba(255,255,255,0.6)', fontSize: 14 }}>yeniden kalibre et</span>
      </div>
    </div>
  </Phone>
);

Object.assign(window, { QuizSingleSelect, QuizBinary, QuizLikert, QuizSlider, QuizImageBinary, QuizFreeText, CalibrationResult });
