/* Motif « la planche » : implémentation de référence, portable en CoreGraphics (cercles, arcs, rectangles, courbes, polygones). */

// ─── 1. Tirages ───────────────────────────────────────────────────────────────
// Graine : FNV-1a 64 bits. Tirage n : SplitMix64 à accès direct (état = graine + (n+1)·γ), donc un tirage ne dépend
// ni de l'ordre de dessin ni du nombre de pièces : agrandir le cadre ajoute des pièces sans changer les autres.
const M64=(1n<<64n)-1n, GAMMA=0x9e3779b97f4a7c15n;
function graine(s){let h=0xcbf29ce484222325n;for(const c of new TextEncoder().encode(s.toLowerCase())){h^=BigInt(c);h=(h*0x100000001b3n)&M64}return h}
function tirage(g,n){let z=(g+BigInt(n+1)*GAMMA)&M64;z=((z^(z>>30n))*0xbf58476d1ce4e5b9n)&M64;z=((z^(z>>27n))*0x94d049bb133111ebn)&M64;z^=z>>31n;return Number(z>>11n)/9007199254740992}
const rangPiece=j=>j>=0?2*j:-2*j-1;                                  // 0,-1,1,-2,2… → 0,1,2,3,4…
const rangGrille=(a,b)=>{const x=rangPiece(a),y=rangPiece(b);return (x+y)*(x+y+1)/2+y}; // appariement de Cantor

// ─── 2. Fonds ─────────────────────────────────────────────────────────────────
const FONDS={
 persil:{c:'#0F5B33',s:'#0C4527',e:'#F4F8EC',es:'#E8F3E3',h:['#7FD36B','#B9E58A']},
 rose:{c:'#F7C9D4',s:'#6A2440',e:'#4A1029',es:'#FFDDE6',h:['#0F5B33','#2E9E4F']},
 beurre:{c:'#FFDC63',s:'#42320A',e:'#3A2A00',es:'#FFE9A3',h:['#0F5B33','#2E8B45']},
 faience:{c:'#BCDDF5',s:'#163F63',e:'#0B2E4D',es:'#D3EAFB',h:['#0F5B33','#2E8B45']},
 pois:{c:'#CBE38A',s:'#39500F',e:'#1F3304',es:'#E2F3B4',h:['#0F5B33','#2F7A2E']},
 aubergine:{c:'#43214F',s:'#371A42',e:'#FBEAF6',es:'#F3DDF0',h:['#7FD36B','#B9E58A']},
};
const ORDRE_FONDS=['persil','rose','beurre','faience','pois','aubergine'];
function oklab(h){const v=[1,3,5].map(i=>parseInt(h.substr(i,2),16)/255).map(c=>c<=.04045?c/12.92:((c+.055)/1.055)**2.4);const[r,g,b]=v;const l=Math.cbrt(.4122214708*r+.5363325363*g+.0514459929*b),m=Math.cbrt(.2119034982*r+.6806995451*g+.1073969566*b),s=Math.cbrt(.0883024619*r+.2817188376*g+.6299787005*b);return[.2104542553*l+.793617785*m-.0040720468*s,1.9779984951*l-2.428592205*m+.4505937099*s,.0259040371*l+.7827717662*m-.808675766*s]}
const ecart=(a,b)=>{const x=oklab(a),y=oklab(b);return Math.hypot(x[0]-y[0],x[1]-y[1],x[2]-y[2])};

let uid=0;
const f=n=>Math.round(n*100)/100;
const disque=(r,fill,x=0,y=0,a='')=>`<circle cx="${f(x)}" cy="${f(y)}" r="${f(r)}" fill="${fill}" ${a}/>`;
function forme(v,R,fond,w,jeu){ // dessin centré, rayon R, trait de couteau w de la couleur du fond, jeu dans [-0,5 ; 0,5[
 const [t,p,c,d,det]=v;const tr=`stroke="${fond}" stroke-width="${f(w)}" stroke-linejoin="round"`;
 if(t==='rondelle'){
  const deux=det==='jaune';
  let s=disque(R,p,0,0,tr);if(!deux)s+=disque(R*.86,c);
  if(det==='coeur'){s+=disque(R*.36,d);for(let i=0;i<8;i++){const a=i*Math.PI/4+jeu;s+=`<line x1="${f(Math.cos(a)*R*.44)}" y1="${f(Math.sin(a)*R*.44)}" x2="${f(Math.cos(a)*R*.7)}" y2="${f(Math.sin(a)*R*.7)}" stroke="${d}" stroke-width="${f(R*.07)}" stroke-linecap="round"/>`}}
  if(det==='graines')for(let i=0;i<7;i++){const a=i*Math.PI*2/7+jeu;s+=`<ellipse cx="0" cy="${f(-R*.48)}" rx="${f(R*.07)}" ry="${f(R*.14)}" fill="${d}" transform="rotate(${f(a*57.3)})"/>`}
  if(det==='quartiers')for(let i=0;i<5;i++){const a=i*72+jeu*60;s+=`<g transform="rotate(${f(a)})"><path d="M0 ${f(-R*.16)} L${f(R*.3)} ${f(-R*.56)} Q0 ${f(-R*.86)} ${f(-R*.3)} ${f(-R*.56)}Z" fill="${d}"/>${disque(R*.06,p,-R*.1,-R*.5)}${disque(R*.06,p,R*.1,-R*.5)}</g>`}
  if(det==='anneaux')for(const q of[.66,.46,.24])s+=`<circle r="${f(R*q)}" fill="none" stroke="${d}" stroke-width="${f(R*.08)}"/>`;
  if(det==='rayons')for(let i=0;i<8;i++)s+=`<g transform="rotate(${f(i*45+jeu*40)})"><path d="M0 ${f(-R*.1)} L${f(R*.22)} ${f(-R*.66)} Q0 ${f(-R*.8)} ${f(-R*.22)} ${f(-R*.66)}Z" fill="${d}"/></g>`;
  if(det==='jaune')s+=disque(R*.5,d,R*.08*jeu,R*.08);
  return s}
 if(t==='quartier'){let s=`<g transform="rotate(${f(jeu*30)})"><path d="M${f(-R)} ${f(-R*.35)} A${f(R)} ${f(R)} 0 0 0 ${f(R)} ${f(-R*.35)}Z" fill="${p}" ${tr}/><path d="M${f(-R*.84)} ${f(-R*.35)} A${f(R*.84)} ${f(R*.84)} 0 0 0 ${f(R*.84)} ${f(-R*.35)}Z" fill="${c}"/>`;if(v[4]!=='nu')s+=`<ellipse cx="${f(-R*.14)}" cy="${f(-R*.1)}" rx="${f(R*.07)}" ry="${f(R*.14)}" fill="${d}"/><ellipse cx="${f(R*.14)}" cy="${f(-R*.1)}" rx="${f(R*.07)}" ry="${f(R*.14)}" fill="${d}"/>`;else s+=`<path d="M${f(-R*.5)} ${f(-R*.12)} Q${f(-R*.05)} ${f(R*.28)} ${f(R*.5)} ${f(-R*.06)}" fill="none" stroke="${d}" stroke-width="${f(R*.1)}" stroke-linecap="round"/>`;return s+'</g>'}
 if(t==='de'){const a=R*.82;return `<g transform="rotate(${f(jeu*26)})"><rect x="${f(-a)}" y="${f(-a)}" width="${f(2*a)}" height="${f(2*a)}" rx="${f(R*.14)}" fill="${p}" ${tr}/><rect x="${f(-a)}" y="${f(-a)}" width="${f(1.56*a)}" height="${f(1.56*a)}" rx="${f(R*.14)}" fill="${c}"/><path d="M${f(-a*.62)} ${f(a*.12)} Q${f(-a*.1)} ${f(-a*.3)} ${f(a*.2)} ${f(-a*.62)}" fill="none" stroke="${d}" stroke-width="${f(R*.12)}" stroke-linecap="round"/></g>`}
 if(t==='baton'){const l=R*1.05,h=R*.27;return `<g transform="rotate(${f(62+jeu*18)})"><rect x="${f(-l)}" y="${f(-h)}" width="${f(2*l)}" height="${f(2*h)}" rx="${f(R*.12)}" fill="${c}" ${tr}/><rect x="${f(-l)}" y="${f(h*.2)}" width="${f(2*l)}" height="${f(h*.8)}" rx="${f(R*.1)}" fill="${p}"/><rect x="${f(-l*.8)}" y="${f(-h*.65)}" width="${f(l*1.1)}" height="${f(h*.28)}" rx="${f(h*.14)}" fill="${d}"/></g>`}
 if(t==='lardon'){const l=R*.92,h=R*.42;return `<g transform="rotate(${f(70+jeu*34)})"><rect x="${f(-l)}" y="${f(-h)}" width="${f(2*l)}" height="${f(2*h)}" rx="${f(R*.14)}" fill="${p}" ${tr}/><rect x="${f(-l)}" y="${f(-h*.45)}" width="${f(2*l)}" height="${f(h*.5)}" fill="${c}"/><rect x="${f(-l)}" y="${f(h*.5)}" width="${f(2*l)}" height="${f(h*.5)}" rx="${f(R*.1)}" fill="${d}"/></g>`}
 if(t==='laniere')return `<g transform="rotate(${f(jeu*34)})"><path d="M${f(-R*.5)} ${f(-R*.95)} Q${f(R*.5)} 0 ${f(-R*.5)} ${f(R*.95)} L${f(R*.05)} ${f(R*.95)} Q${f(R*1.05)} 0 ${f(R*.05)} ${f(-R*.95)}Z" fill="${p}" ${tr}/><path d="M${f(-R*.36)} ${f(-R*.86)} Q${f(R*.62)} 0 ${f(-R*.36)} ${f(R*.86)}" fill="none" stroke="${c}" stroke-width="${f(R*.2)}"/></g>`;
 if(t==='tranche'){const a=R*1.08,b=R*.74;let s=`<g transform="rotate(${f(-58+jeu*8)})"><rect x="${f(-a)}" y="${f(-b)}" width="${f(2*a)}" height="${f(2*b)}" rx="${f(b*.62)}" fill="${p}" ${tr}/><rect x="${f(-a*.86)}" y="${f(-b*.8)}" width="${f(a*1.72)}" height="${f(b*1.6)}" rx="${f(b*.5)}" fill="${c}"/>`;for(const q of[-.42,0,.42])s+=`<path d="M${f(a*q-R*.1)} ${f(-b*.55)} Q${f(a*q+R*.16)} 0 ${f(a*q-R*.1)} ${f(b*.55)}" fill="none" stroke="${d}" stroke-width="${f(R*.09)}" stroke-linecap="round"/>`;return s+'</g>'}
 if(t==='coin')return `<g transform="rotate(${f(jeu*22)})"><path d="M${f(-R*1.05)} ${f(R*.62)} L${f(R*.62)} ${f(-R*.7)} Q${f(R*1.12)} ${f(-R*.1)} ${f(R*.95)} ${f(R*.62)}Z" fill="${p}" ${tr}/><path d="M${f(-R*.98)} ${f(R*.5)} L${f(R*.58)} ${f(-R*.66)} Q${f(R*.86)} ${f(-R*.1)} ${f(R*.7)} ${f(R*.5)}Z" fill="${c}"/>${disque(R*.17,d,R*.2,R*.1)}${disque(R*.1,d,-R*.22,R*.24)}${disque(R*.08,d,R*.46,-R*.2)}</g>`;
 if(t==='champignon')return `<g transform="rotate(${f(jeu*36)})"><path d="M${f(-R*1.02)} ${f(R*.1)} Q${f(-R*1.02)} ${f(-R*.88)} 0 ${f(-R*.88)} Q${f(R*1.02)} ${f(-R*.88)} ${f(R*1.02)} ${f(R*.1)} Q${f(R*.9)} ${f(R*.36)} ${f(R*.3)} ${f(R*.26)} Q${f(R*.24)} ${f(R*.6)} ${f(R*.4)} ${f(R*.88)} Q0 ${f(R*1.04)} ${f(-R*.4)} ${f(R*.88)} Q${f(-R*.24)} ${f(R*.6)} ${f(-R*.3)} ${f(R*.26)} Q${f(-R*.9)} ${f(R*.36)} ${f(-R*1.02)} ${f(R*.1)}Z" fill="${p}" ${tr}/><path d="M${f(-R*.84)} ${f(R*.06)} Q${f(-R*.8)} ${f(-R*.7)} 0 ${f(-R*.7)} Q${f(R*.8)} ${f(-R*.7)} ${f(R*.84)} ${f(R*.06)} Q${f(R*.5)} ${f(-R*.08)} ${f(R*.2)} ${f(R*.08)} Q${f(R*.1)} ${f(R*.5)} ${f(R*.24)} ${f(R*.8)} Q0 ${f(R*.88)} ${f(-R*.24)} ${f(R*.8)} Q${f(-R*.1)} ${f(R*.5)} ${f(-R*.2)} ${f(R*.08)} Q${f(-R*.5)} ${f(-R*.08)} ${f(-R*.84)} ${f(R*.06)}Z" fill="${c}"/><path d="M${f(-R*.56)} ${f(-R*.1)} Q${f(-R*.4)} ${f(-R*.5)} 0 ${f(-R*.5)} Q${f(R*.4)} ${f(-R*.5)} ${f(R*.56)} ${f(-R*.1)}" fill="none" stroke="${d}" stroke-width="${f(R*.08)}" stroke-linecap="round"/></g>`;
 if(t==='gousse')return `<g transform="rotate(${f(15+jeu*8)})"><path d="M0 ${f(-1.08*R)} C${f(.1*R)} ${f(-.8*R)} ${f(.72*R)} ${f(-.42*R)} ${f(.72*R)} ${f(.28*R)} C${f(.72*R)} ${f(.78*R)} ${f(.4*R)} ${f(R)} 0 ${f(R)} C${f(-.4*R)} ${f(R)} ${f(-.72*R)} ${f(.78*R)} ${f(-.72*R)} ${f(.28*R)} C${f(-.72*R)} ${f(-.42*R)} ${f(-.1*R)} ${f(-.8*R)} 0 ${f(-1.08*R)}Z" fill="${p}" ${tr}/><path d="M0 ${f(-.78*R)} C${f(.08*R)} ${f(-.58*R)} ${f(.54*R)} ${f(-.3*R)} ${f(.54*R)} ${f(.26*R)} C${f(.54*R)} ${f(.64*R)} ${f(.3*R)} ${f(.82*R)} 0 ${f(.82*R)} C${f(-.3*R)} ${f(.82*R)} ${f(-.54*R)} ${f(.64*R)} ${f(-.54*R)} ${f(.26*R)} C${f(-.54*R)} ${f(-.3*R)} ${f(-.08*R)} ${f(-.58*R)} 0 ${f(-.78*R)}Z" fill="${c}"/><path d="M${f(-.2*R)} ${f(-.2*R)} Q${f(-.13*R)} ${f(.14*R)} ${f(-.2*R)} ${f(.44*R)}" stroke="${d}" stroke-width="${f(.15*R)}" stroke-linecap="round" fill="none"/></g>`;
 if(t==='feuille')return `<g transform="rotate(${f(24+jeu*70)})"><path d="M0 ${f(-R*1.05)} Q${f(R*.95)} ${f(-R*.1)} 0 ${f(R*1.05)} Q${f(-R*.95)} ${f(-R*.1)} 0 ${f(-R*1.05)}Z" fill="${p}" ${tr}/><path d="M0 ${f(-R*.9)} Q${f(R*.76)} ${f(-R*.1)} 0 ${f(R*.9)}Z" fill="${c}"/><path d="M0 ${f(-R*.8)} L0 ${f(R*1.02)}" stroke="${d}" stroke-width="${f(R*.09)}"/></g>`;
 if(t==='goutte')return disque(R*.95,d,0,0,tr)+disque(R*.83,c)+`<path d="M${f(-R*.5)} ${f(R*.1)} A${f(R*.5)} ${f(R*.5)} 0 1 1 ${f(R*.35)} ${f(R*.32)}" fill="none" stroke="${d}" stroke-width="${f(R*.13)}" stroke-linecap="round"/>`;
 if(t==='nuage')return `<g transform="rotate(${f(jeu*50)})"><path d="M${f(-R)} ${f(R*.5)} L${f(-R*.2)} ${f(-R*.75)} Q0 ${f(-R*.95)} ${f(R*.2)} ${f(-R*.75)} L${f(R)} ${f(R*.5)} Q${f(R*.95)} ${f(R*.74)} ${f(R*.7)} ${f(R*.74)} L${f(-R*.7)} ${f(R*.74)} Q${f(-R*.95)} ${f(R*.74)} ${f(-R)} ${f(R*.5)}Z" fill="${c}" ${tr}/><path d="M${f(R*.05)} ${f(-R*.6)} L${f(R*.6)} ${f(R*.46)}" stroke="${d}" stroke-width="${f(R*.12)}" stroke-linecap="round"/></g>`;
 if(t==='fleurette')return `<g transform="rotate(${f(jeu*40)})"><path d="M${f(-R*.22)} ${f(R*.1)} L${f(-R*.3)} ${f(R*.98)} L${f(R*.3)} ${f(R*.98)} L${f(R*.22)} ${f(R*.1)}Z" fill="${d}" ${tr}/>${[[-.52,.02,.44],[.52,.02,.44],[-.28,-.46,.46],[.3,-.46,.46],[0,-.06,.5]].map(([x,y,q])=>disque(R*q,p,R*x,R*y,tr)).join('')}${[[-.52,-.02,.34],[.52,-.02,.34],[-.28,-.5,.36],[.3,-.5,.36],[0,-.12,.38]].map(([x,y,q])=>disque(R*q,c,R*x,R*y)).join('')}</g>`;
 if(t==='crevette')return `<g transform="rotate(${f(-20+jeu*30)})"><path d="M${f(-R*.95)} ${f(R*.25)} A${f(R*.95)} ${f(R*.95)} 0 0 1 ${f(R*.95)} ${f(R*.1)} L${f(R*.42)} ${f(R*.3)} A${f(R*.5)} ${f(R*.5)} 0 0 0 ${f(-R*.4)} ${f(R*.3)}Z" fill="${p}" ${tr}/>${[-60,-20,20,55].map(a=>`<path d="M0 ${f(-R*.5)} L0 ${f(-R*.86)}" transform="translate(0 ${f(R*.14)}) rotate(${a})" stroke="${d}" stroke-width="${f(R*.11)}" stroke-linecap="round"/>`).join('')}</g>`;
 if(t==='noix')return `<g transform="rotate(${f(jeu*80)})"><path d="M0 ${f(-R)} Q${f(R*.95)} ${f(-R*.9)} ${f(R*.86)} 0 Q${f(R*.9)} ${f(R*.9)} 0 ${f(R)} Q${f(-R*.9)} ${f(R*.9)} ${f(-R*.86)} 0 Q${f(-R*.95)} ${f(-R*.9)} 0 ${f(-R)}Z" fill="${p}" ${tr}/><path d="M0 ${f(-R*.86)} L0 ${f(R*.86)} M${f(-R*.5)} ${f(-R*.5)} Q${f(-R*.15)} ${f(-R*.2)} ${f(-R*.52)} ${f(R*.1)} Q${f(-R*.2)} ${f(R*.3)} ${f(-R*.45)} ${f(R*.6)} M${f(R*.5)} ${f(-R*.5)} Q${f(R*.15)} ${f(-R*.2)} ${f(R*.52)} ${f(R*.1)} Q${f(R*.2)} ${f(R*.3)} ${f(R*.45)} ${f(R*.6)}" fill="none" stroke="${c}" stroke-width="${f(R*.14)}" stroke-linecap="round"/></g>`;
 if(t==='olive')return disque(R*.86,p,0,0,tr)+disque(R*.4,c,R*.06*jeu,0)+disque(R*.24,d,R*.06*jeu,0);
 return disque(R,c,0,0,tr);
}

// ─── 3. Dictionnaire ──────────────────────────────────────────────────────────
// Visuel : [taille, peau, chair, détail, variante]
const VIS={
 tomate:['rondelle','#D8331F','#F0614A','#FFC9A8','quartiers'],courgette:['rondelle','#3F8B2E','#DCEBA6','#B5CF74','graines'],
 concombre:['rondelle','#2F7A3A','#E2F2C0','#BBDD95','graines'],aubergine:['rondelle','#4A1E58','#F1E6C4','#C9B487','graines'],
 carotte:['rondelle','#F07818','#FF9838','#FFC070','coeur'],panais:['rondelle','#D9C28A','#FAF0CF','#EAD9A2','coeur'],
 navet:['rondelle','#B06A9B','#FBF4F2','#EBD9E2','nu'],radis:['rondelle','#D62F5C','#FFF6F4','#F6C9D2','nu'],
 betterave:['rondelle','#7A0F42','#A81F60','#C94A85','anneaux'],oignon:['rondelle','#D9A441','#FFF6DF','#E8CF95','anneaux'],
 oignonRouge:['rondelle','#A63A6E','#FBEFF4','#DDA6C4','anneaux'],echalote:['rondelle','#B9708A','#FBEDEE','#DDA9B4','anneaux'],
 poireau:['rondelle','#5E9E3C','#E4F0B8','#A4C76A','anneaux'],fenouil:['rondelle','#9CC47A','#F2F8DE','#C9E0A8','anneaux'],
 celeri:['quartier','#8DB34E','#E3EDB5','#B9D27C','nu'],chou:['rondelle','#4E9A35','#CFE79A','#9CCB62','anneaux'],
 chouRouge:['rondelle','#5B1B57','#A35A9A','#DDB4DA','anneaux'],chouFleur:['fleurette','#E6DDBE','#FFFBEA','#C9D69A'],
 brocoli:['fleurette','#2F7A34','#58A84A','#8CC56C'],pdt:['rondelle','#D9B45A','#FBEAB0','#EED78C','nu'],
 patateDouce:['rondelle','#B4522A','#F79A55','#FFB67C','nu'],potiron:['quartier','#E06A12','#FFA23F','#FFE0A8','pepins'],
 poivron:['laniere','#C4261D','#E8452F','#F58A6C'],poivronVert:['laniere','#2F7A34','#57A948','#9CD07F'],
 piment:['laniere','#A8181B','#DB2F2A','#F27A6A'],haricotVert:['baton','#3E8A33','#69B24A','#8FCC6C'],
 asperge:['baton','#5B8F3A','#9CC56A','#C9E3A0'],epinard:['feuille','#2B7A3A','#4F9E50','#8CC98A'],
 laitue:['feuille','#4E9A35','#9FCF5E','#D3EBA0'],endive:['feuille','#D7DE9A','#FBF9E2','#E7EBBB'],
 avocat:['quartier','#3C5B22','#D6E58A','#8A5A2B','pepins'],artichaut:['feuille','#5F7F4A','#A3BC82','#D3E0BD'],
 champignon:['champignon','#8E6A4B','#EBDCC4','#B79A78'],ail:['gousse','#DE8FA7','#FFFDF4','#F0B4C4'],
 gingembre:['rondelle','#C79A5A','#F8E3AE','#E2C283','nu'],maisGrain:['grain','#F2B91D','#FFD447','#FFE88F'],
 citron:['rondelle','#F2C21A','#FFF1A0','#F7D548','rayons'],citronVert:['rondelle','#5FA03A','#E3F0B0','#B6D774','rayons'],
 orange:['rondelle','#F08A1A','#FFD08A','#FFA83F','rayons'],pomme:['quartier','#C9352B','#FFF4D6','#8A5A2B','pepins'],
 poire:['quartier','#A6A53A','#FBF6D8','#8A5A2B','pepins'],banane:['rondelle','#F0CC3A','#FFF4C8','#E2CF8A','graines'],
 fraise:['quartier','#D4213A','#F7707A','#FFC2C0','pepins'],abricot:['quartier','#E98A2B','#FFBE6A','#C9741E','nu'],
 cerise:['olive','#A3122F','#D8415A','#F7A3A8'],prune:['quartier','#5B2566','#E5B45A','#8A4A1E','nu'],
 framboise:['grain','#C2224F','#E04A72','#F48BA6'],raisin:['grain','#5F2F63','#8C5590','#C8A2CB'],
 olive:['olive','#4C5B2A','#8C9A55','#C23B2A'],oeuf:['rondelle','#FFFFFF','#FFFFFF','#FFB81C','jaune'],
 boeuf:['de','#7E1F22','#B23A38','#E9B9A8'],veau:['de','#C9848A','#EBB6B4','#FBE3DE'],agneau:['de','#93303A','#C75A5E','#F0C2BA'],
 porc:['tranche','#E7A9A4','#F3C3BC','#FFE9E4'],poulet:['de','#D9A06A','#F4CFA0','#C2834A'],canard:['tranche','#E9C27A','#B04444','#E9B9A8'],
 lardon:['lardon','#C64A4F','#F2B7AE','#FBE6DF'],jambon:['tranche','#F6D9D2','#EE8E93','#FFFFFF'],saucisse:['rondelle','#A33B2C','#D9694F','#F2B59C','graines'],
 chorizo:['rondelle','#8E1B12','#C73A22','#F6A98A','graines'],hachis:['hache','#93303A','#C2544E','#A8403F'],
 saumon:['tranche','#F9B79A','#FA8258','#FFD2BD'],poisson:['tranche','#A9BECB','#F2F7F9','#C9D8E1'],thon:['tranche','#A34A52','#C9727A','#EDB5B5'],
 crevette:['crevette','#F48A6C','#F48A6C','#FFD5C4'],moule:['quartier','#2A2F45','#F0A24A','#FBD08F','nu'],
 pate:['baton','#E2A93B','#FFD98A','#F6C35C'],lasagne:['tranche','#E9C06A','#FFE6A8','#F3D084'],gnocchi:['olive','#E7CF95','#FBEBBF','#E7CF95'],
 riz:['grain','#FFFDF2','#FFFDF2','#E5DFC8'],semoule:['grain','#F0CE78','#F7DD98','#E2B95A'],quinoa:['grain','#E8D8B0','#F3E7C8','#C9A878'],
 lentille:['grain','#5E6B34','#7C8A45','#4A5628'],lentilleCorail:['grain','#E8723A','#F58F55','#D95F2A'],poisChiche:['grain','#E3B76B','#E9C585','#C9964A'],
 haricotSec:['grain','#B8402F','#C9574A','#8E2A20'],haricotBlanc:['grain','#FBF4E2','#FBF4E2','#E6D8B4'],petitPois:['grain','#58A53A','#79C255','#3F8329'],
 pain:['tranche','#A7642B','#F3D6A0','#D9AE6C'],chapelure:['semis','#C98A3C','#E0AC62','#F0CC92'],flocon:['grain','#E6CFA0','#F3E2BF','#CDAE74'],
 pateTarte:['rondelle','#D9A85A','#F8E0AC','#EBC783','nu'],
 beurre:['de','#E7B92E','#FFE48A','#FFF3C4'],fromage:['coin','#E59A1C','#FFD25A','#F2B533'],chevre:['rondelle','#E9E4D6','#FFFFFF','#EFE9D8','nu'],
 mozza:['rondelle','#F1EEE4','#FFFFFF','#E9E5D8','nu'],bleu:['coin','#D9D6B8','#FBF8E4','#6F8CA8'],feta:['de','#E4E6DF','#FFFFFF','#EEF0EA'],
 chocolat:['de','#3A1B12','#5E3223','#84503A'],noix:['noix','#A8743E','#D9AC72','#8A5A2B'],amande:['feuille','#A5673A','#F3DDB4','#D9B27C'],
 noisette:['olive','#9A6233','#E9CBA0','#F5E2C4'],pistache:['grain','#8FA84A','#B5C96F','#7A5B7F'],cocoRape:['semis','#FFFFFF','#FFFFFF','#EFEBDF'],
 tofu:['de','#E8DEC0','#FBF6E4','#F3EBCF'],persil:['hache','#0F5B33','#2E9E4F','#1E7A45'],herbe:['feuille','#2E8B3D','#57B35A','#9BD68E'],
 lait:['filet','#E8E4D8','#FFFFFF','#F0ECE0'],creme:['filet','#EFE3C4','#FFF8E6','#E9DAB0'],yaourt:['filet','#E4EAEE','#FBFDFF','#DCE6EC'],
 vinRouge:['filet','#5B0E2D','#7D1740','#A43B66'],vinBlanc:['filet','#D9CB6A','#F0E6A0','#FBF6CF'],biere:['filet','#B8761A','#E0A23A','#F6D48C'],
 coulis:['filet','#A8241A','#D1412F','#EC7A62'],miel:['filet','#C9821A','#F0AE34','#FBD47E'],confiture:['filet','#8A1538','#B92D55','#DD6A88'],
 farine:['semis','#FFFFFF','#FFFFFF','#F3EFE4'],sucre:['semis','#FFFFFF','#FFFFFF','#EDEAE3'],cassonade:['semis','#B8793A','#D39A58','#E6BE8A'],cacao:['semis','#4A241A','#6B3A2A','#8A5540'],
};
// clé (nom tel qu'on l'écrit, normalisé au chargement) : visuel, classe (s solide, l liquide, p poudre), masse d'une pièce en g
const DICO_SRC=`tomate:tomate:s:120|tomate cerise:tomate:s:15|tomate pelée:tomate:s:80|concentré de tomate:coulis:l:30|coulis de tomate:coulis:l:200|sauce tomate:coulis:l:200|courgette:courgette:s:220|concombre:concombre:s:350|aubergine:aubergine:s:280|carotte:carotte:s:100|panais:panais:s:150|navet:navet:s:120|radis:radis:s:15|betterave:betterave:s:150|oignon:oignon:s:120|oignon rouge:oignonRouge:s:120|oignon nouveau:poireau:s:30|échalote:echalote:s:30|poireau:poireau:s:150|fenouil:fenouil:s:250|céleri:celeri:s:60|céleri rave:panais:s:600|chou:chou:s:900|chou rouge:chouRouge:s:900|chou fleur:chouFleur:s:800|chou de Bruxelles:chou:s:15|brocoli:brocoli:s:400|pomme de terre:pdt:s:130|patate:pdt:s:130|patate douce:patateDouce:s:250|potiron:potiron:s:1500|potimarron:potiron:s:1200|butternut:potiron:s:1200|courge:potiron:s:1200|poivron:poivron:s:160|poivron vert:poivronVert:s:160|piment:piment:s:10|haricot vert:haricotVert:s:5|asperge:asperge:s:25|épinard:epinard:s:10|blette:epinard:s:60|laitue:laitue:s:250|salade:laitue:s:250|salade verte:laitue:s:250|roquette:laitue:s:50|mâche:laitue:s:100|endive:endive:s:130|avocat:avocat:s:180|artichaut:artichaut:s:250|champignon:champignon:s:20|cèpe:champignon:s:60|girolle:champignon:s:10|ail:ail:s:5|gingembre:gingembre:s:30|maïs:maisGrain:s:200|citron:citron:s:110|citron vert:citronVert:s:70|orange:orange:s:180|pomme:pomme:s:150|poire:poire:s:160|banane:banane:s:120|fraise:fraise:s:15|abricot:abricot:s:45|pêche:abricot:s:130|cerise:cerise:s:8|prune:prune:s:30|pruneau:prune:s:10|framboise:framboise:s:4|myrtille:raisin:s:2|raisin:raisin:s:5|raisin sec:raisin:s:1|olive:olive:s:4|œuf:oeuf:s:55|jaune d'œuf:oeuf:s:20|blanc d'œuf:oeuf:s:35|bœuf:boeuf:s:200|steak:boeuf:s:150|veau:veau:s:200|agneau:agneau:s:200|gigot:agneau:s:1500|porc:porc:s:180|filet mignon:porc:s:500|poulet:poulet:s:1200|blanc de poulet:poulet:s:150|cuisse de poulet:poulet:s:200|dinde:poulet:s:150|lapin:poulet:s:1200|canard:canard:s:350|lardon:lardon:s:5|poitrine fumée:lardon:s:150|bacon:lardon:s:20|noix de Saint-Jacques:stJacques:s:30|jambon:jambon:s:45|jambon cru:jambon:s:25|petit salé:jambon:s:400|saucisse:saucisse:s:120|saucisson:saucisse:s:200|merguez:chorizo:s:60|chorizo:chorizo:s:200|viande hachée:hachis:s:125|bœuf haché:hachis:s:125|chair à saucisse:hachis:s:200|saumon:saumon:s:150|truite:saumon:s:250|cabillaud:poisson:s:150|lieu:poisson:s:150|colin:poisson:s:150|merlu:poisson:s:150|morue:poisson:s:150|sardine:poisson:s:40|thon:thon:s:140|anchois:thon:s:4|crevette:crevette:s:12|gambas:crevette:s:30|moule:moule:s:15|pâte:pate:s:3|spaghetti:pate:s:2|tagliatelle:pate:s:5|coquillette:pate:s:1|macaroni:pate:s:2|penne:pate:s:2|feuille de lasagne:lasagne:s:20|lasagne:lasagne:s:20|gnocchi:gnocchi:s:8|riz:riz:s:1|semoule:semoule:s:1|boulgour:semoule:s:1|couscous:semoule:s:1|quinoa:quinoa:s:1|lentille:lentille:s:1|lentille corail:lentilleCorail:s:1|pois chiche:poisChiche:s:1|haricot rouge:haricotSec:s:1|haricot blanc:haricotBlanc:s:1|petit pois:petitPois:s:1|pois cassé:petitPois:s:1|pain:pain:s:40|pain de mie:pain:s:30|baguette:pain:s:250|chapelure:chapelure:p:30|flocon d'avoine:flocon:s:1|pâte brisée:pateTarte:s:230|pâte feuilletée:pateTarte:s:230|pâte sablée:pateTarte:s:230|pâte à pizza:pateTarte:s:260|beurre:beurre:s:15|fromage:fromage:s:30|gruyère:fromage:s:30|emmental:fromage:s:30|comté:fromage:s:30|parmesan:fromage:s:30|raclette:fromage:s:30|reblochon:fromage:s:450|chèvre:chevre:s:100|bûche de chèvre:chevre:s:180|mozzarella:mozza:s:125|camembert:mozza:s:250|roquefort:bleu:s:100|bleu:bleu:s:100|feta:feta:s:150|ricotta:creme:l:250|mascarpone:creme:l:250|fromage blanc:yaourt:l:100|fromage frais:creme:l:150|chocolat:chocolat:s:10|noix:noix:s:6|amande:amande:s:1|poudre d'amande:semouleAmande:p:1|noisette:noisette:s:1|pistache:pistache:s:1|noix de coco râpée:cocoRape:p:1|tofu:tofu:s:200|persil:persil:s:20|basilic:herbe:s:15|menthe:herbe:s:15|coriandre:herbe:s:15|ciboulette:persil:s:10|estragon:herbe:s:10|lait:lait:l:200|lait de coco:lait:l:400|crème:creme:l:200|crème fraîche:creme:l:200|yaourt:yaourt:l:125|vin rouge:vinRouge:l:150|vin blanc:vinBlanc:l:150|vin:vinRouge:l:150|bière:biere:l:330|cidre:biere:l:250|miel:miel:l:20|confiture:confiture:l:20|farine:farine:p:100|fécule:farine:p:20|maïzena:farine:p:20|sucre:sucre:p:100|sucre glace:sucre:p:50|cassonade:cassonade:p:50|cacao:cacao:p:20`;
VIS.stJacques=['rondelle','#F0D9B0','#FFF9EC','#F3E2C2','nu'];VIS.semouleAmande=['semis','#D9B27C','#F3DDB4','#C99A5E'];
// écartés : jamais dessinés, même si un mot est connu
const EXCLUS_SRC=`jus|fond|eau|sel|gros sel|fleur de sel|poivre|huile|vinaigre|bouillon|cube de bouillon|fond de veau|fumet|sauce soja|nuoc mam|tabasco|jus de citron|jus d'orange|zeste|levure|bicarbonate|sucre vanillé|vanille|extrait|arôme|muscade|noix de muscade|cannelle|curry|curcuma|paprika|cumin|piment d'Espelette|piment de Cayenne|quatre épices|épice|herbe de Provence|bouquet garni|thym|laurier|romarin|clou de girofle|graisse de canard|graisse d'oie|gélatine|moutarde|cognac|rhum|papier cuisson|glaçon`;

// ct-normalisation (sous-ensemble suffisant ici)
const INVAR=new Set(['radis','noix','ananas','mais','anchois','pois','jus','riz','brebis','cassis','colis','couscous','houmous','os','frais','gros','bas']);
function normaliserNom(s){s=s.toLowerCase().replace(/œ/g,'oe').replace(/æ/g,'ae').normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[’'\-]/g,' ').replace(/\([^)]*\)/g,' ').replace(/[^a-z0-9% ]/g,' ').replace(/\s+/g,' ').trim();
 let m=s.split(' ');while(m.length>1&&['de','d','du','des','le','la','l','les'].includes(m[0]))m.shift();
 return m.map(w=>INVAR.has(w)||w.length<3?w:w.replace(/eaux$/,'eau').replace(/[sx]$/,'')).join(' ')}
const DICO=new Map(DICO_SRC.split('|').map(l=>{const[k,v,c,m]=l.split(':');return[normaliserNom(k),{v,c,m:+m,k}]}));
const EXCLUS=EXCLUS_SRC.split('|').map(normaliserNom);
const contient=(n,k)=>(' '+n+' ').includes(' '+k+' ');
/* plus longue clé en mots entiers ; à longueur égale, la plus à gauche. Une exclusion gagne si elle commence avant la clé,
   ou au même endroit en étant au moins aussi longue : « huile d’olive » écarté, « oignon piqué de clous de girofle » dessiné. */
function reconnaitre(nom){const n=normaliserNom(nom);let best=null,lg=0,pos=1e9;
 for(const[k,e]of DICO)if(contient(n,k)){const p=(' '+n+' ').indexOf(' '+k+' ');if(k.length>lg||(k.length===lg&&p<pos)){best=e;lg=k.length;pos=p}}
 for(const k of EXCLUS)if(contient(n,k)){const p=(' '+n+' ').indexOf(' '+k+' ');if(!best||p<pos||(p===pos&&k.length>=lg))return{exclu:true}}
 return best?{v:best.v,c:best.c,m:best.m,cle:best.k}:null}

// ─── 4. Lecture d'une ligne importée (simplifiée) et poids ────────────────────
const UNITES={kg:['kg',1000],kilo:['kg',1000],g:['g',1],gr:['g',1],gramme:['g',1],l:['l',1000],litre:['l',1000],dl:['dl',100],cl:['cl',10],ml:['ml',1],'c. à soupe':['cas',15],'c. à s.':['cas',15],'cuillères à soupe':['cas',15],'cuil. à soupe':['cas',15],'cuillère à soupe':['cas',15],'càs':['cas',15],'c. à café':['cac',5],'c. à c.':['cac',5],'cuillères à café':['cac',5],'cuil. à café':['cac',5],'cuillère à café':['cac',5],
 gousse:['autre',5],tranche:['autre',40],botte:['autre',100],bouquet:['autre',40],sachet:['autre',10],paquet:['autre',250],'boîte':['autre',400],pot:['autre',125],verre:['autre',150],tasse:['autre',200],bol:['autre',300],'poignée':['autre',30],brin:['autre',2],branche:['autre',10],feuille:['autre',2],boule:['autre',125],'pavé':['autre',150],filet:['autre',150],briquette:['autre',200],rouleau:['autre',230],pincée:['autre',.5],plaquette:['autre',200],tablette:['autre',200]};
const FRACT={'½':.5,'¼':.25,'¾':.75,'⅓':1/3,'⅔':2/3};
function lireLigne(l){let s=l.trim().replace(/^[-•*]\s*/,'');let q=null,m=s.match(/^(\d+[.,]?\d*\s*(?:à|-)\s*)?(\d+)\/(\d+)\s*|^(?:\d+[.,]?\d*\s*(?:à|-)\s*)?(\d+(?:[.,]\d+)?|[½¼¾⅓⅔])\s*/);
 if(m&&m[0]){q=m[2]?m[2]/m[3]:(FRACT[m[4]]??parseFloat(m[4].replace(',','.')));s=s.slice(m[0].length)}
 else if(/^une? /.test(s)){q=1;s=s.replace(/^une? /,'')}
 let u=null,ug=null;if(q!=null){const cles=Object.keys(UNITES).sort((a,b)=>b.length-a.length);for(const k of cles){if(k==='bouquet'&&/^bouquet garni/i.test(s))continue;const r=new RegExp('^'+k.replace(/\./g,'\\.')+'(?:s|es)?(?=\\s|\'|’|$)\\.?\\s*','i');if(r.test(s)){u=UNITES[k][0];ug=UNITES[k][1];s=s.replace(r,'');break}}}
 s=s.replace(/^(de |d['’]|du |des )/i,'').trim();return{q,u,ug,nom:s}}
/* masse estimée en grammes : g, kg, ml, cl, dl, l convertis ; pièce = masse du dictionnaire ; sans quantité = 5 */
function masse(l,r){if(l.q==null)return 5;if(l.ug!=null)return l.q*l.ug;return l.q*(r?r.m:80)}
const SALE=new Set('boeuf veau agneau porc poulet canard lardon jambon saucisse chorizo hachis saumon poisson thon crevette moule stJacques oignon oignonRouge echalote ail poireau tomate aubergine poivron poivronVert champignon chou chouRouge chouFleur brocoli celeri fenouil endive artichaut epinard laitue haricotVert asperge pdt lentille lentilleCorail poisChiche haricotSec haricotBlanc petitPois olive fromage chevre mozza bleu feta tofu persil coulis'.split(' '));
const SALE_ECARTE='poivre|bouillon|vinaigre|fumet|fond de veau|sauce soja|nuoc mam|tabasco|moutarde|curry|curcuma|paprika|cumin|piment d\'Espelette|piment de Cayenne|herbe de Provence|bouquet garni|thym|laurier|romarin'.split('|').map(normaliserNom);
function analyser(lignes){const t=lignes.map(x=>{const l=lireLigne(x),r=reconnaitre(l.nom);return{ligne:x,nom:l.nom,r:r&&!r.exclu?r:null,exclu:!!(r&&r.exclu),masse:masse(l,r&&!r.exclu?r:null)}});
 const par=new Map();for(const i of t)if(i.r){const e=par.get(i.r.v)||{v:i.r.v,c:i.r.c,masse:0};e.masse+=i.masse;par.set(i.r.v,e)}
 const tous=[...par.values()].sort((a,b)=>b.masse-a.masse||(a.v<b.v?-1:1));const sol=tous.filter(e=>e.c==='s'&&e.masse>=8),aut=tous.filter(e=>!sol.includes(e));
 // ail et herbes ne prennent une rangée que s'il manque des solides
 const un=c=>aut.filter(e=>e.c===c).slice(0,1),reste=aut.filter(e=>e.c==='s').slice(0,2);
 const dessin=sol.length>=2?sol.slice(0,4):[...sol,...reste,...un('l'),...un('p')].sort((a,b)=>b.masse-a.masse).slice(0,3);
 // preuve de salé : un ingrédient dessinable de SALE, ou un nom écarté de SALE_ECARTE. « sel » n'en est pas une.
 const sale=tous.some(e=>SALE.has(e.v))||t.some(i=>i.exclu&&SALE_ECARTE.some(k=>contient(normaliserNom(i.nom),k)));
 const ms=n=>(par.get(n)||{masse:0}).masse;const sucre=!sale&&ms('sucre')+ms('cassonade')+ms('chocolat')+ms('miel')+ms('confiture')>=40;
 return{dessin,sucre,sale,details:t,inconnus:t.filter(i=>!i.r&&!i.exclu)}}

// ─── 5. Fond ──────────────────────────────────────────────────────────────────
function choisirFond(id,vis){const dep=Number(graine(id+'/fond')%6n);const d=n=>vis.length?Math.min(...vis.slice(0,3).map(v=>Math.max(ecart(FONDS[n].c,VIS[v][1]),ecart(FONDS[n].c,VIS[v][2])))):1;const ordre=[0,1,2,3,4,5].map(i=>ORDRE_FONDS[(dep+i)%6]);return ordre.find(n=>d(n)>=.14)||ordre.reduce((a,b)=>d(b)>d(a)?b:a)}
const mel=(a,b,t)=>'#'+[1,3,5].map(i=>Math.round(parseInt(a.substr(i,2),16)*(1-t)+parseInt(b.substr(i,2),16)*t).toString(16).padStart(2,'0')).join('');
/* recette {id, t, lignes} → modèle de planche, indépendant de la taille */
function composer(r){if(r._c)return r._c;const a=analyser(r.lignes);const fond=r.fond||choisirFond(r.id,a.dessin.map(e=>e.v));
 const max=a.dessin.length?Math.sqrt(a.dessin[0].masse):1;
 const rang=a.dessin.map(e=>({v:e.v,h:Math.min(VIS[e.v][0]==='semis'?.6:VIS[e.v][0]==='filet'?.8:1,Math.max(.55,Math.sqrt(e.masse)/max))}));
 // repli : coupes ton sur ton seulement, aucune pièce inventée
 const gen=['g-ruban','g-de','g-rondelle','g-baton'];let n=Math.floor(tirage(graine(r.id+'/repli'),0)*4);
 if(rang.length===1)rang.push({v:gen[n],h:.9});
 else if(!rang.length)rang.push({v:gen[n],h:1},{v:'g-semis',h:.55},{v:gen[(n+1)%4],h:.9});
 return r._c={fond,rang,sucre:a.sucre,sale:a.sale,angle:[-18,-11,11,18][Math.floor(tirage(graine(r.id+'/cadre'),0)*4)],a}}

// ─── 6. Dessin ────────────────────────────────────────────────────────────────
const SERRE={rondelle:1.18,tranche:1,baton:.62,laniere:.82,lardon:1.02,de:1.86,coin:1.62,champignon:1.62,gousse:.84,feuille:1.16,quartier:1.5,fleurette:1.5,crevette:1.5,noix:1.5,olive:1.5};
let traces=0;
const fragment=(x,y,r,col,d,x0='')=>{traces++;const n=4+Math.floor(d(0)*2),a0=d(1)*6.283;let p='';for(let i=0;i<n;i++){const a=a0+i*6.283/n+(d(2+2*i)-.5)*.7,q=r*(.55+d(3+2*i)*.6);p+=(i?'L':'M')+f(x+Math.cos(a)*q*1.25)+' '+f(y+Math.sin(a)*q*.8)}return `<path d="${p}Z" fill="${col}"${x0}/>`};
/* o : {w,h, bandes (3), module (34), angle, debut, bande, entier, transp, sombre, persil (1), hache, trait} */
function planche(r,o){const C=composer(r),F=FONDS[C.fond],fond=o.sombre?F.s:F.c,enc=o.sombre?F.es:F.e;const{w,h}=o;const sc=o.sombre?.5:1;
 const rangs=C.rang.slice(0,o.bandes||3),n=rangs.length;const ang=o.angle??C.angle,A=ang*Math.PI/180,cs=Math.cos(A),sn=Math.sin(A);
 const L=w*cs+h*Math.abs(sn),H=w*Math.abs(sn)+h*cs;const reps=o.bande?Math.ceil(H/(o.bande*n*.8))+1:Math.max(1,Math.round(H/((o.module||34)*n*.9)));
 const seq=[];for(let k=0;k<reps;k++)seq.push(...rangs);const somme=seq.reduce((s,x)=>s+x.h,0);
 const tc=Math.max(1,Math.min(w,h)/(o.trait||62));let y=o.debut??-H/2,g='';const petit=w*h<16000;const budget=petit?90:260,budgetG=petit?150:420;
 const hors=(x,yy,R)=>{const X=x*cs-yy*sn,Y=x*sn+yy*cs;return X+R<-w/2||X-R>w/2||Y+R<-h/2||Y-R>h/2||(o.entier&&X-R<-w/2)};
 seq.forEach((e,i)=>{const bh=o.bande?o.bande*e.h:H*e.h/somme;if(y>H/2)return;const G=graine(r.id+'/r'+i);const yc=y+bh/2;const gen=e.v.startsWith('g-');
  const V=gen?[{'g-ruban':'filet','g-de':'de','g-rondelle':'rondelle','g-baton':'baton','g-semis':'semis'}[e.v],mel(fond,enc,o.sombre?.2:.2),mel(fond,enc,o.sombre?.11:.1),mel(fond,enc,.3),e.v==='g-rondelle'?'anneaux':'']:VIS[e.v];const t=V[0];
  if(t==='grain'||t==='hache'||t==='semis'){
   let q=t==='grain'?bh/(bh>44?7.4:5.2):t==='hache'?(o.hache||Math.max(2.2,bh/9)):Math.max(.8,bh/26);const dx0={grain:2.02,hache:1.62,semis:2.7}[t],dy0={grain:1.62,hache:1.22,semis:1.9}[t];
   const bud=t==='semis'?budgetG*(gen?.8:1.2):budgetG;let est=(L/(q*dx0))*(bh/(q*dy0));if(est>bud)q*=Math.sqrt(est/bud);const dx=q*dx0,dy=q*dy0;
   const nl=Math.max(1,Math.floor((bh-q*.6)/dy)),l0=yc-(nl-1)*dy/2,m=Math.ceil(L/2/dx)+1;
   for(let a=0;a<nl;a++)for(let j=-m;j<=m;j++){const k=rangGrille(j,a),d=z=>tirage(G,k*16+z);const X=(j+(a%2)/2)*dx,Y=l0+a*dy;if(hors(X,Y,q*1.5))continue;
    if(t==='hache')g+=fragment(X+(d(12)-.5)*q*.7,Y+(d(13)-.5)*q*.5,q*(.62+d(14)*.42),V[1+Math.floor(d(15)*2.4)],d);
    else if(t==='semis'){traces++;g+=`<circle cx="${f(X+(d(0)-.5)*dx*.8)}" cy="${f(Y+(d(1)-.5)*dy*.8)}" r="${f(q*(.45+d(2)*.75))}" fill="${d(3)<.25?V[1]:V[2]}"/>`}
    else{traces++;const cx=X+(d(0)-.5)*q*.6,cy=Y+(d(1)-.5)*q*.5;g+=`<ellipse cx="${f(cx)}" cy="${f(cy)}" rx="${f(q)}" ry="${f(q*.8)}" fill="${d(2)<.3?V[3]:V[2]}" stroke="${fond}" stroke-width="${f(tc*.8)}" transform="rotate(${f((d(3)-.5)*90)} ${f(cx)} ${f(cy)})"/>`}}
  }else if(t==='filet'){const a=bh*.13,lo=bh*(2.1+tirage(G,0)),ph=tirage(G,1)*6.283,e2=bh*.31,x0=o.entier?-w/2+e2*1.1:-L/2-4;let hautp='',bas='',mil='';const N=Math.min(60,Math.ceil(L/(lo/14)));for(let k=0;k<=N;k++){const x=x0+(L/2+4-x0)*k/N,s=Math.sin(x/lo*6.283+ph)*a;hautp+=(k?'L':'M')+f(x)+' '+f(yc+s-e2);bas=`L${f(x)} ${f(yc+s+e2)}`+bas;if(k>1)mil+=(k>2?'L':'M')+f(x)+' '+f(yc+s-e2*.36)}
   traces+=2;g+=`<path d="${hautp}${bas}Z" fill="${V[2]}" stroke="${V[1]}" stroke-width="${f(Math.max(1,bh*.05))}" stroke-linejoin="round"/><path d="${mil}" fill="none" stroke="${V[3]}" stroke-width="${f(Math.max(1,bh*.07))}" stroke-linecap="round"/>`}
  else{const R=bh*.5*.97;let pas=R*(SERRE[t]||1.4);const est=L/pas;if(est>budget/Math.max(1,n))pas*=est/(budget/Math.max(1,n));const dec=tirage(G,999983)*pas,m=Math.ceil(L/2/pas)+1;
   for(let j=-m-1;j<=m;j++){const k=rangPiece(j);const X=j*pas+dec,Y=yc+(tirage(G,k*4)-.5)*bh*.05;if(hors(X,Y,R*1.08))continue;traces+=3;g+=`<g transform="translate(${f(X)} ${f(Y)})">${forme(V,R,fond,tc,tirage(G,k*4+1)-.5)}</g>`}}
  y+=bh});
 const pl=C.sucre?['#FFFFFF','#FFF6E6']:C.sale?F.h:[mel(fond,enc,.22),mel(fond,enc,.36)];const nf=Math.min(120,Math.round((o.persil??1)*w*h/(petit?640:1500)));const rf=Math.max(1.4,Math.min(4.4,Math.sqrt(w*h)/44));const GP=graine(r.id+'/pluches');let per='';
 if(Math.min(w,h)>=24)for(let i=0;i<nf;i++){const d=z=>tirage(GP,i*16+z);per+=fragment((d(12)-.5)*w,(d(13)-.5)*h*(o.debut!=null?.62:1)+(o.debut!=null?h*.19:0),rf*(.5+d(14)*.8),pl[d(15)<.6?0:1],d)}
 const id='p'+(uid++);return `<svg class="pl" width="${w}" height="${h}" viewBox="${-w/2} ${-h/2} ${w} ${h}" aria-hidden="true"><defs><clipPath id="${id}"><rect x="${-w/2}" y="${-h/2}" width="${w}" height="${h}"/></clipPath></defs><g clip-path="url(#${id})">${o.transp?'':`<rect x="${-w/2}" y="${-h/2}" width="${w}" height="${h}" fill="${fond}"/>`}<g transform="rotate(${ang})">${g}</g>${per}</g></svg>`}
