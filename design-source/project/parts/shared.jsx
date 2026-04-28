/* gicik shared primitives — load with type=text/babel */

const Phone = ({ children, label, w = 393, h = 852 }) => (
  <div style={{
    width: w, height: h, borderRadius: 54, overflow: 'hidden',
    position: 'relative',
    background: '#0A0612',
    boxShadow: '0 0 0 10px #0a0a10, 0 0 0 11px #2a2530, 0 30px 60px rgba(0,0,0,0.6)',
  }} className="gicik cosmic-bg">
    {/* dynamic island */}
    <div style={{
      position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
      width: 122, height: 36, borderRadius: 22, background: '#000', zIndex: 80,
    }}/>
    {/* status bar */}
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, zIndex: 70,
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '20px 32px 0', color: '#fff', fontSize: 16, fontWeight: 600,
    }}>
      <span>9:41</span>
      <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <svg width="18" height="11" viewBox="0 0 18 11"><rect x="0" y="7" width="3" height="4" rx="0.6" fill="#fff"/><rect x="4.5" y="5" width="3" height="6" rx="0.6" fill="#fff"/><rect x="9" y="2.5" width="3" height="8.5" rx="0.6" fill="#fff"/><rect x="13.5" y="0" width="3" height="11" rx="0.6" fill="#fff"/></svg>
        <svg width="16" height="11" viewBox="0 0 16 11" fill="none"><path d="M8 3c2 0 3.8.8 5.2 2.2l1-1A8.5 8.5 0 008 1.6 8.5 8.5 0 001.8 4.2l1 1A7 7 0 018 3z" fill="#fff"/><circle cx="8" cy="9.5" r="1.3" fill="#fff"/></svg>
        <svg width="25" height="12" viewBox="0 0 25 12"><rect x="0.5" y="0.5" width="21" height="11" rx="3" stroke="#fff" strokeOpacity="0.5" fill="none"/><rect x="2" y="2" width="18" height="8" rx="1.5" fill="#fff"/></svg>
      </span>
    </div>
    {/* content */}
    <div style={{ position: 'absolute', inset: 0, paddingTop: 0 }}>{children}</div>
    {/* home indicator */}
    <div style={{
      position: 'absolute', bottom: 8, left: '50%', transform: 'translateX(-50%)',
      width: 134, height: 5, borderRadius: 999, background: 'rgba(255,255,255,0.55)', zIndex: 80,
    }}/>
  </div>
);

const Dots = ({ total = 8, active = 0 }) => (
  <div className="dots">
    {Array.from({length: total}).map((_, i) => <i key={i} className={i === active ? 'active' : ''}/>)}
  </div>
);

const TopBar = ({ active, total = 8, back = true, close = false, right }) => (
  <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding: '60px 20px 8px' }}>
    <div style={{ width: 28, display:'flex', alignItems:'center' }}>
      {back && <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M15 6l-6 6 6 6" stroke="rgba(255,255,255,0.7)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>}
    </div>
    {total > 0 ? <Dots total={total} active={active}/> : <span/>}
    <div style={{ width: 28, display:'flex', justifyContent:'flex-end' }}>
      {right}
      {close && <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke="rgba(255,255,255,0.5)" strokeWidth="2" strokeLinecap="round"/></svg>}
    </div>
  </div>
);

const Logo = ({ size = 64 }) => (
  <span className="t-display" style={{ fontSize: size, lineHeight: 1, letterSpacing: '-0.04em', display: 'inline-flex', alignItems: 'flex-start' }}>
    g<span style={{ position: 'relative', display: 'inline-block' }}>
      ı
      <span style={{ position:'absolute', top: size*0.07, left: '50%', transform: 'translateX(-50%)', width: size*0.14, height: size*0.14, borderRadius: 999, background: 'linear-gradient(135deg, #FF0080, #8000FF 50%, #00FFFF 100%)', boxShadow: '0 0 12px rgba(255,0,128,0.7), 0 0 24px rgba(128,0,255,0.5)' }}/>
    </span>cık
  </span>
);

const Chip = ({ children, selected, lg, emoji }) => (
  <span className={`chip ${selected ? 'selected' : ''} ${lg ? 'lg' : ''}`}>
    {emoji && <span style={{ fontSize: 14 }}>{emoji}</span>}
    {children}
  </span>
);

const Obs = ({ children }) => (
  <div className="obs"><p>{children}</p></div>
);

const ReplyCard = ({ label, text, copied, copyText = 'kopyala' }) => (
  <div className="reply">
    <div className="label">{label}</div>
    <p className="text">{text}</p>
    <div className="row">
      <span style={{
        display:'inline-flex', alignItems:'center', gap:6,
        height:32, padding:'0 12px', borderRadius:999,
        border:`1px solid ${copied ? 'rgba(204,255,0,0.6)' : 'rgba(255,255,255,0.12)'}`,
        color: copied ? '#CCFF00' : 'rgba(255,255,255,0.85)',
        fontSize: 13, fontWeight: 500,
        background: copied ? 'rgba(204,255,0,0.08)' : 'transparent',
      }}>
        {copied ? <>kopyalandı <span>✓</span></> : <>
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><rect x="9" y="9" width="11" height="11" rx="2" stroke="currentColor" strokeWidth="1.8"/><path d="M5 15V6a2 2 0 012-2h9" stroke="currentColor" strokeWidth="1.8"/></svg>
          {copyText}
        </>}
      </span>
      <span style={{ display:'flex', gap: 14, color:'rgba(255,255,255,0.4)' }}>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M7 22V11l5-9 1 1v6h6l-2 11H7z" stroke="currentColor" strokeWidth="1.5"/></svg>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" style={{ transform:'rotate(180deg)'}}><path d="M7 22V11l5-9 1 1v6h6l-2 11H7z" stroke="currentColor" strokeWidth="1.5"/></svg>
      </span>
    </div>
  </div>
);

// Icon set — minimal line work
const Ico = {
  back: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M15 6l-6 6 6 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  close: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg>,
  chevR: <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  upload: <svg width="48" height="48" viewBox="0 0 48 48" fill="none"><path d="M24 32V12M24 12l-9 9M24 12l9 9" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/><path d="M8 30v6a4 4 0 004 4h24a4 4 0 004-4v-6" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/></svg>,
  refresh: <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M21 12a9 9 0 11-3-6.7L21 8M21 3v5h-5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  gear: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="1.6"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 110-4h.09a1.65 1.65 0 001.51-1 1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z" stroke="currentColor" strokeWidth="1.4"/></svg>,
  reply: <svg width="28" height="28" viewBox="0 0 28 28" fill="none"><path d="M22 14a8 8 0 01-8 8h-2l-5 3 1-5a8 8 0 1114-6z" stroke="currentColor" strokeWidth="1.5"/></svg>,
  spark: <svg width="28" height="28" viewBox="0 0 28 28" fill="none"><path d="M14 4v6M14 18v6M4 14h6M18 14h6M7 7l4 4M17 17l4 4M7 21l4-4M17 11l4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/></svg>,
  bio: <svg width="28" height="28" viewBox="0 0 28 28" fill="none"><path d="M5 6h18M5 12h18M5 18h12" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/></svg>,
  ghost: <svg width="28" height="28" viewBox="0 0 28 28" fill="none"><path d="M5 24V12a9 9 0 1118 0v12l-3-2-3 2-3-2-3 2-3-2-3 2z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/><circle cx="11" cy="12" r="1" fill="currentColor"/><circle cx="17" cy="12" r="1" fill="currentColor"/></svg>,
  invite: <svg width="28" height="28" viewBox="0 0 28 28" fill="none"><path d="M9 4l3 8-3 12 12-12-12-8z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/></svg>,
  lock: <svg width="28" height="28" viewBox="0 0 28 28" fill="none"><rect x="6" y="13" width="16" height="11" rx="2" stroke="currentColor" strokeWidth="1.5"/><path d="M10 13V9a4 4 0 018 0v4" stroke="currentColor" strokeWidth="1.5"/></svg>,
  check: <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 12l5 5L20 7" stroke="#CCFF00" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  envelope: <svg width="120" height="90" viewBox="0 0 120 90" fill="none"><rect x="6" y="14" width="108" height="68" rx="10" stroke="rgba(255,255,255,0.7)" strokeWidth="1.5"/><path d="M10 20l50 35 50-35" stroke="rgba(255,255,255,0.7)" strokeWidth="1.5" strokeLinejoin="round"/></svg>,
  clip: <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><rect x="9" y="9" width="11" height="11" rx="2" stroke="currentColor" strokeWidth="1.8"/><path d="M5 15V6a2 2 0 012-2h9" stroke="currentColor" strokeWidth="1.8"/></svg>,
};

Object.assign(window, { Phone, Dots, TopBar, Logo, Chip, Obs, ReplyCard, Ico });
