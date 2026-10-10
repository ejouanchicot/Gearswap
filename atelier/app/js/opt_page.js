// GearSwap Atelier · opt_page.js: the optimizer on a page of its own, opened from a set ("Optimize this set"). One screen:
// a line on top (back, the set, the buffs profile and target, the search buttons), then two columns: what is looked for
// (objective, its settings, where to look and the floors) and the result (the objective's figure, the same detailed table
// for every objective, the pieces changed, what to do with them). An engaged set may be judged over a whole fight,
// weaponskills and skillchains in (atelier/cycle.js, FFXI.opt.cycle: EXPERIMENTAL, offered only when that file is there)
// (loaded by atelier.html after ws_page.js: see the list there)

Object.assign(T.fr, {optSearch_fast: 'Recherche rapide', optSearch_classic: 'Recherche classique', optSearchTip: 'Rapide : garde en mémoire ce qui est déjà calculé et écarte les pièces qui ne peuvent jamais gagner (une autre pièce du même emplacement fait au moins aussi bien sur tout ce que l’objectif compte). Classique : l’ancienne recherche, pour comparer.',
  opHow: 'Méthode', optOpenBtn: 'Optimiser ce set →', orShow: 'Voir la recherche',
  optBack: '← Retour au set', optPageTitle: 'Optimiseur', engObj_cycle: 'Dégâts sur un combat · TEST',
  opWhat: 'Ce qu’on cherche', opResult: 'Résultat', opSearch: 'Recherche', opChanges: 'Pièces changées', opWsTp: 'TP de la WS',
  opNoTry: 'Lance une recherche : l’essai s’affiche ici, comparé à ton set.', opNow: 'Ton set', opFight: 'Dégâts sur un combat',
  objD_tp_real: 'arriver le plus vite à la WS, coup par coup', objD_tp_time: 'arriver vite à la WS, au TP moyen',
  objD_dps: 'frapper le plus fort, sans la WS', objD_tp_round: 'le plus de TP chaque round',
  objD_cycle: 'auto-attaque, WS, skillchains, Aftermath', objD_damage: 'la WS la plus forte à ce TP',
  objD_damage_avg: 'la WS la plus forte sur la plage', objD_tp_return: 'le plus de TP rendu par la WS', objD_jump: 'un round d’attaque dans son set',
  cycWsLbl: 'WS', cycNoWs: 'Aucun set de WS pour l’arme de ce set.', cycAmLbl: 'Aftermath 3 entretenu', cycHitsLbl: 'Coups reçus',
  cycHitsMe: 'Moi (solo, ~5,8 TP/s)', cycHitsTank: 'Un tank (groupe)', cycTimedLbl: 'Berserk, Aggressor, Warcry relancés',
  cycNoRule: 'Règle TP Bonus pas reçue du jeu : WS sans Moonshade ni pièces TP.', cycMelee: 'Auto-attaque', cycWs: 'WS', cycSc: 'Skillchains',
  cycV_eq: 'Équivalent : garde ton set', cycV_try: 'À essayer en jeu', cycV_better: 'Meilleur, à confirmer en jeu', cycV_worse: 'Moins bon que ton set',
  opRounds: '{n} rounds', opRoundsLbl: 'Rounds jusqu’à la WS', opGauge: '{r} rounds de {tp} TP pour atteindre {at}', opMean: 'moy. {n} rounds',
  opFHits: 'Coups qui touchent par round', opFDmg: 'Dégâts par coup', opFRound: 'Durée d’un round', opFTpHit: 'TP par coup', opCurve: 'Dégâts selon le TP', cycTpHit: 'TP par coup', cyc2r: 'Retour au seuil en 2 rounds', cycTpWs: 'TP au moment de la WS', cycChain: 'WS qui ferment une skillchain', cycWsMin: 'WS par minute',
  opHelp: 'Le résultat compare l’essai (les pièces que la recherche propose, en couleur dans le set) à ton set tel qu’il est dans le fichier. ★ = la ligne de l’objectif ; en doré, le meilleur des deux ; en rouge, sous un plancher. Verdict : sous 2 % d’écart, équivalent ; de 2 à 5 %, à essayer ; au-delà, meilleur ou moins bon. Dégâts sur un combat (TEST) : précision ±4 % mesurée en jeu le 2026-10-04 ; une WS qui revient en 3 rounds rate la fenêtre de skillchain (10 s, puis 9 s).',
  engDone_cycle: 'Optimisé : dégâts sur un combat {a} → {b} ({g} %), {n} pièce(s) changée(s) dans ton essai · DT+PDT {p} · DT+MDT {m} · Subtle Blow {sb}.'});
Object.assign(T.en, {optSearch_fast: 'Fast search', optSearch_classic: 'Classic search', optSearchTip: 'Fast: reuses what it already calculated and skips the pieces that can never win (another piece for the slot is at least as good on everything the objective counts). Classic: the previous search, for comparison.',
  opHow: 'Method', optOpenBtn: 'Optimize this set →', orShow: 'Show the search',
  optBack: '← Back to the set', optPageTitle: 'Optimizer', engObj_cycle: 'Damage over a fight · TEST',
  opWhat: 'What to optimize', opResult: 'Result', opSearch: 'Search', opChanges: 'Pieces changed', opWsTp: 'Weaponskill TP',
  opNoTry: 'Run a search: the draft appears here, compared with your set.', opNow: 'Your set', opFight: 'Damage over a fight',
  objD_tp_real: 'reach the weaponskill fastest, hit by hit', objD_tp_time: 'reach the weaponskill fast, at average TP',
  objD_dps: 'hit hardest, weaponskill excluded', objD_tp_round: 'the most TP per round',
  objD_cycle: 'melee, weaponskills, skillchains, Aftermath', objD_damage: 'the strongest weaponskill at this TP',
  objD_damage_avg: 'the strongest weaponskill over the range', objD_tp_return: 'the most TP returned by the weaponskill', objD_jump: 'an attack round in its own set',
  cycWsLbl: 'Weaponskill', cycNoWs: 'No weaponskill set for this set’s weapon.', cycAmLbl: 'Aftermath Lv.3 kept', cycHitsLbl: 'Hits taken',
  cycHitsMe: 'Me (solo, ~5.8 TP/s)', cycHitsTank: 'A tank (party)', cycTimedLbl: 'Berserk, Aggressor, Warcry reused',
  cycNoRule: 'No TP Bonus rule from the game: weaponskills without Moonshade or TP pieces.', cycMelee: 'Melee', cycWs: 'Weaponskills', cycSc: 'Skillchains',
  cycV_eq: 'Same: keep your set', cycV_try: 'Worth a try in game', cycV_better: 'Better, to confirm in game', cycV_worse: 'Worse than your set',
  opRounds: '{n} rounds', opRoundsLbl: 'Rounds to the weaponskill', opGauge: '{r} rounds of {tp} TP to reach {at}', opMean: 'avg {n} rounds',
  opFHits: 'Hits landed per round', opFDmg: 'Damage per hit', opFRound: 'Round time', opFTpHit: 'TP per hit', opCurve: 'Damage by TP', cycTpHit: 'TP per hit', cyc2r: 'Back to the TP in 2 rounds', cycTpWs: 'TP at the weaponskill', cycChain: 'Weaponskills closing a skillchain', cycWsMin: 'Weaponskills per minute',
  opHelp: 'The result compares the draft (the pieces the search suggests, colored in the set) with your set as written in the file. ★ = the objective’s row; gold = the better of the two; red = under a limit. Verdict: under 2 %, the same; 2 to 5 %, worth a try; beyond that, better or worse. Damage over a fight (TEST): ±4 % as measured in game on 2026-10-04; a weaponskill that comes back in 3 rounds misses the skillchain window (10 s, then 9 s).',
  engDone_cycle: 'Optimized: damage over a fight {a} → {b} ({g} %), {n} piece(s) changed in your draft · DT+PDT {p} · DT+MDT {m} · Subtle Blow {sb}.'});

/* ---- opened from a set ---- */
const optViewKey = s => S.char + '|' + S.job + '|' + s.path;
const optPageOpen = s => !!s && S.optView === optViewKey(s);

/* ---- the page ---- */
const opNum = (v, n = 0) => (+v).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: n, maximumFractionDigits: n});
function optPageHTML(s, ws){
  const kind = ws ? 'ws' : isJumpSet(s.path) ? 'jump' : roundSet(s) ? 'eng' : 'stat', act = ws ? 'optws' : kind === 'stat' ? 'optstat' : 'opteng';
  const b = buffState();
  const go = S._optBusy ? `<span class="optprog">${t('optStart')}</span>${searchParked() ? `<button class="btn" data-orshow>${t('orShow')}</button>` : ''}<button class="btn ghost" data-optstop>${t('optStop')}</button>`
    : optGoButtons(act) + (kind === 'jump' || kind === 'stat' ? '' : `<button class="btn ghost" data-tiercost title="${esc(t(ws ? 'tcTip' : 'tcTipEng'))}">${t('tcBtn')}</button>`);
  const head = `<header class="ophead"><button class="btn ghost" data-optback>${t('optBack')}</button><h2 class="display">${t('optPageTitle')}</h2>` +
    `<span class="opset">${esc(shortPath(s.path))}</span><span class="muted small">${esc(buffTier())} · ${esc(enemyKey(b.enemy))}</span>` +
    `<span class="sp"></span><div class="opgo">${go}</div></header>`;
  if (!engineReady()) return `<article class="detail oppage">${head}<p class="tpnote">${t('optNoEngine')}</p></article>`;
  // a set judged by its stats (idle, Enmity, Phalanx, Fast Cast...): stat_opt.js
  const what = kind === 'stat' ? statWhatHTML(s) : opWhatHTML(s, kind), result = kind === 'stat' ? statResultHTML(s) : opResultHTML(s, kind);
  return `<article class="detail oppage">${head}<div class="opcols"><section class="opcol">${what}</section>` +
    `<section class="opcol">${result}</section></div></article>`;
}

/* ---- left: what is looked for ---- */
const opObjKey = kind => kind === 'ws' ? 'obj' : 'engObj';
function opObjList(kind){
  if (kind === 'ws') return ['damage', 'damage_avg', 'tp_return'];
  if (kind === 'jump') return ['jump'];
  return ENG_OBJS.concat(cycleReady() ? ['cycle'] : []);
}
function opObj(kind){
  const o = S.optOpts || {}, list = opObjList(kind), cur = kind === 'ws' ? o.obj : o.engObj;
  return kind === 'jump' ? 'jump' : list.includes(cur) ? cur : list[0];
}
function opObjLabel(kind, k){
  const o = S.optOpts || {}, [a, b] = avgRange(o);
  if (kind === 'ws') return t('optObj_' + k, {tp: S.wsTp || 3000, a, b});
  return k === 'jump' ? t('jumpObj') : t('engObj_' + k);
}
function opWhatHTML(s, kind){
  const o = S.optOpts = Object.assign({obj: 'damage', pdt: -50, mdt: -21, sb: 0, hit: 0, engObj: 'tp_real', engAt: 1000}, S.optOpts || {});
  const cur = opObj(kind), key = opObjKey(kind);
  const objs = `<div class="opobjs" role="radiogroup">${opObjList(kind).map(k => `<button class="opobj ${k === cur ? 'on' : ''}" role="radio" aria-checked="${k === cur}" ` +
    `data-objtip="${esc(t('objTip_' + k, {tp: S.wsTp || 3000, a: avgRange(o)[0], b: avgRange(o)[1]}))}" ` +
    `${kind === 'jump' ? 'disabled' : `data-optobj="${key}" data-v="${k}"`}><b>${esc(opObjLabel(kind, k))}</b><span>${esc(t('objD_' + k))}</span></button>`).join('')}</div>`;
  const help = S._help === 'optpage' ? `<p class="wshelp">${esc(t(kind === 'ws' ? 'optWhy' : kind === 'jump' ? 'jumpWhy' : 'engWhy', {tp: S.wsTp || 3000}))} ${esc(optSettingsHelp(kind === 'ws'))} ${esc(t('opHelp'))}</p>` : '';
  // the limits first: what a result may never go past is read before what it maximises
  const lim = (k, label) => opLimitHTML(`data-optopt="${k}"`, label, o[k]);
  const limits = opLimitsHTML(t('opLimits'), [lim('pdt', 'DT+PDT ≤'), lim('mdt', 'DT+MDT ≤'), lim('sb', 'Subtle Blow ≥')].concat(kind === 'ws' ? [lim('hit', t('optHitLbl'))] : []));
  return `${limits}<h3 class="ophd">${t('opWhat')} ${helpBtn('optpage')}</h3>${help}${objs}${opParamsHTML(s, kind, cur)}${opSearchHTML(o, kind === 'ws')}`;
}
// The objective's own settings: the TP the weaponskill goes at, the TP range, how a whole fight is played
function opParamsHTML(s, kind, cur){
  const o = S.optOpts || {}, f = [];
  if (kind === 'ws' && cur !== 'damage_avg') f.push(`<label class="opf">${t('opWsTp')} <input type="number" class="tpin" step="250" min="1000" max="3000" value="${esc(S.wsTp || 3000)}"></label>`);
  if (kind === 'ws' && cur === 'damage_avg') { const [a, b] = avgRange(o);
    f.push(`<label class="opf">${t('opWsTp')} ${t('optFrom')} <input type="number" step="250" min="1000" max="3000" data-optopt="tpFrom" value="${a}"></label>`,
      `<label class="opf">${t('optTo')} <input type="number" step="250" min="1000" max="3000" data-optopt="tpTo" value="${b}"></label>`); }
  if (kind === 'eng' && ['tp_real', 'tp_time', 'cycle'].includes(cur))
    f.push(`<label class="opf">${t('engAtLbl')} <input type="number" step="100" min="1000" max="3000" data-optopt="engAt" value="${esc(o.engAt)}"> TP</label>`);
  if (kind === 'eng' && cur === 'cycle') {
    const list = cycleWsSets(s), w = cycleWsSet(s);
    f.push(list.length ? `<label class="opf">${t('cycWsLbl')} <select class="buffsel" data-cycws="${esc(s.path)}">${list.map(x => `<option value="${esc(x.path)}" ${w && w.path === x.path ? 'selected' : ''}>${esc(shortPath(x.path).replace(/^precast\.WS\.?/, ''))}</option>`).join('')}</select></label>`
      : `<span class="kwarn">${esc(t('cycNoWs'))}</span>`);
    f.push(`<label class="opf">${t('cycHitsLbl')} <select class="buffsel" data-optopt="cycHits">${['me', 'tank'].map(k => `<option value="${k}" ${(o.cycHits || 'me') === k ? 'selected' : ''}>${t(k === 'me' ? 'cycHitsMe' : 'cycHitsTank')}</option>`).join('')}</select></label>`);
    const chk = (k, label) => `<label class="opf"><input type="checkbox" data-optopt="${k}" ${(o[k] ?? true) ? 'checked' : ''}> ${esc(label)}</label>`;
    f.push(chk('cycAm', t('cycAmLbl')), chk('cycTimed', t('cycTimedLbl')));
  }
  return f.length ? `<div class="opparams">${f.join('')}</div>` : '';
}
/* ---- the left column's shared blocks: limits, search, switches ---- */
// A limit as a tile: its name above, its sign and its value below ("DT+PDT ≤" gives DT+PDT, then ≤ and the number).
// attr: the input's own attribute (data-optopt="pdt" here, data-statfloor="hp" in stat_opt.js)
function opLimitHTML(attr, label, value){
  const m = String(label).match(/^(.*?)\s*([≤≥])\s*$/), name = m ? m[1] : label;
  return `<label class="oplim" title="${esc(label)}"><span class="oplimn">${esc(name)}</span><span class="oplimv">${m ? `<i>${m[2]}</i>` : ''}` +
    `<input type="number" step="1" ${attr} value="${esc(value)}"></span></label>`;
}
// The limits block, at the top of the column: seen before anything else. More than four tiles (the stats
// optimizer's minimums) go two across, their longer names on two lines
function opLimitsHTML(title, tiles, extra = ''){
  const shown = tiles.filter(Boolean);
  return `<h3 class="ophd" ${extra}>${esc(title)}</h3><div class="oplimits ${shown.length > 4 ? 'many' : ''}">${shown.join('')}</div>`;
}
// The search's settings, in tabs: the pieces it may use, how it works them out, the special pieces. A new setting is a
// line in OP_SWITCH (its label, its tip) and its key in a tab here; what it changes reads S.optOpts.<key>. `menu`: the
// tab's menu (an S.optOpts key, its label, its values and their text prefix); `count`: the tab's name says how many
// of its switches are on (special pieces: off for most players, so seen without opening the tab)
const OP_TABS = [
  {id: 'pieces', title: 'opTabPieces', menu: {key: 'where', label: 'optWhereLbl', values: ['mine', 'mine_max', 'all'], text: 'optWhere_', dflt: 'mine'},
    keys: ['wardOnly', 'freeWeapons']},
  // the fast search (memory, pieces that can never win left out) or the classic one, kept to go back to
  {id: 'calc', title: 'opTabCalc', menu: {key: 'search', label: 'opHow', values: ['fast', 'classic'], text: 'optSearch_', dflt: 'fast', tip: 'optSearchTip'},
    keys: ['fullSpeed']},
  {id: 'special', title: 'opTabSpecial', keys: ['hoxne', 'vim'], count: true}];
const OP_SWITCH = {
  wardOnly: {label: 'optWard'},
  freeWeapons: {label: 'freeWeapons', tip: ws => t(ws ? 'freeWeaponsWsTip' : 'freeWeaponsTip')},
  fullSpeed: {label: 'fullSpeed', tip: () => t('fullSpeedTip', {n: OPT_CORES})},
  hoxne: {label: 'optHoxne', tip: () => t('optHoxneTip')},
  vim: {label: 'optVim', tip: () => t('optVimTip')}};
// One switch; noWeapons: free weapons offered off, with why
function opSwitchHTML(o, k, ws, noWeapons){
  const d = OP_SWITCH[k], off = k === 'freeWeapons' && noWeapons, tip = off ? noWeapons : d.tip ? d.tip(ws) : '';
  return `<label class="opsw ${off ? 'off' : ''}" ${tip ? `title="${esc(tip)}"` : ''}><input type="checkbox" ${off ? 'disabled' : `data-optopt="${k}" ${o[k] ? 'checked' : ''}`}>` +
    `<span>${esc(t(d.label))}</span></label>`;
}
// labelled and in the text's colour (a bare grey menu read as a switched-off one, 2026-10-05)
function opMenuHTML(o, m){
  const opts = m.values.map(v => `<option value="${v}" ${(o[m.key] || m.dflt) === v ? 'selected' : ''}>${t(m.text + v)}</option>`).join('');
  const tip = m.tip ? `title="${esc(t(m.tip))}"` : '';
  return `<div class="opsels"><span ${tip}>${esc(t(m.label))}</span><select class="buffsel" data-optopt="${m.key}" ${tip}>${opts}</select></div>`;
}
// The slots locked on the set shown (trial.js): the search leaves them as they are
function opLocksHTML(){
  const s = ui2CurrentSet(data()), list = s ? lockedSlots(s) : [];
  const locks = list.length ? `<p class="oplocks">${esc(t('locksLine', {n: list.length, l: list.map(x => SLOT_NAMES[S.lang][x] || x).join(', ')}))} <button class="linkbtn" data-locksclear>${esc(t('locksClear'))}</button></p>` : '';
  // the pieces left out of the searches for this character: one click on a name allows it again
  const out = Object.keys(excludedOf()).sort();
  const excl = out.length ? `<p class="oplocks">${esc(t('exclLine'))} ${out.map(n => `<button class="opexcl" data-unexclude="${esc(n)}" title="${esc(t('exclBack', {p: n}))}">${esc(n)} ×</button>`).join(' ')}` +
    (out.length > 1 ? ` <button class="linkbtn" data-exclclear>${esc(t('exclClear'))}</button>` : '') + `</p>` : '';
  return locks + excl;
}
// The search block: its tabs, then the open tab's menu and switches
function opSearchHTML(o, ws, noWeapons){
  const cur = OP_TABS.find(x => x.id === S._opTab) || OP_TABS[0];
  const tabs = OP_TABS.map(x => { const on = x.count ? x.keys.filter(k => o[k]).length : 0;
    return `<button data-optab="${x.id}" aria-pressed="${x === cur}">${esc(t(x.title))}${on ? `<small class="opon">${on}</small>` : ''}</button>`; }).join('');
  return `<h4 class="ophd2">${t('opSearch')}</h4><div class="seg optabs" role="group">${tabs}</div>` +
    `<div class="optab">${cur.menu ? opMenuHTML(o, cur.menu) : ''}<div class="opsws">${cur.keys.map(k => opSwitchHTML(o, k, ws, noWeapons)).join('')}</div>` +
    (cur.id === 'special' ? `<p class="muted small">${esc(t('opSpecialWhy'))}</p>` : '') + (cur.id === 'pieces' ? opLocksHTML() : '') + `</div>`;
}

/* ---- right: the result ---- */
// A set's figures (the try as shown, or plain: the file's set), kept while nothing they read changes
function opFigures(s, kind, plain){
  const pieces = plain ? withoutTrial(() => withWeapons(s).pieces) : withWeapons(s).pieces;
  const key = JSON.stringify([kind, S.char, S.job, s.path, pieces, buffState(), S.optOpts, S.wsTp]);
  S._opFig = S._opFig || {};
  if (key in S._opFig) return S._opFig[key];
  let f = null;
  try {
    if (kind === 'ws') {
      const ctx = optContext(s), p = optPieces(pieces), tp = +(S.wsTp || 3000), r = FFXI.opt.ws(ctx, p, tp);
      if (r) { const h = FFXI.opt.hits(ctx, p, {tp}) || {}, tps = avgTps(S.optOpts || {});
        const curve = [1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000].map(x => [x, (FFXI.opt.ws(ctx, p, x) || [0, [0]])[1][0]]);
        f = {damage: r[1][0], tpBack: r[1][1], first: h.first, rest: h.rest, def: FFXI.opt.defense(FFXI.opt.gearset(ctx, p), ctx.sbBuff), curve,
          avg: tps.reduce((n, x) => n + ((FFXI.opt.ws(ctx, p, x) || [0, [0]])[1][0]), 0) / tps.length}; }
    } else {
      const r = engRound(s, plain);
      if (r) f = {r, def: r.def, c: kind === 'eng' && isCycle() ? cycleOf(s, plain) : null};
    }
  } catch (e) { f = null; }
  if (Object.keys(S._opFig).length > 60) S._opFig = {};
  return (S._opFig[key] = f);
}
// The lines of the table: every figure of the family, the objective's first (low: smaller is better)
function opRows(kind, obj){
  const o = S.optOpts || {}, pc = v => opNum(100 * v) + ' %', s2 = v => v.toFixed(2) + ' s', [a, b] = avgRange(o);
  let rows;
  if (kind === 'ws') rows = [
    {id: 'damage', label: t('wsvDmg', {tp: S.wsTp || 3000}), get: f => f.damage, fmt: fmtDmg},
    {id: 'damage_avg', label: t('wsvAvg', {a, b}), get: f => f.avg, fmt: fmtDmg},
    {id: 'tp_return', label: t('wsvTp'), get: f => f.tpBack, fmt: v => opNum(v)},
    {id: 'hit1', label: t('wsvHit1'), get: f => f.first, fmt: v => Math.floor(v) + ' %'},
    {id: 'hit2', label: t('wsvHit2'), get: f => f.rest, fmt: v => Math.floor(v) + ' %', floor: +o.hit ? v => v >= +o.hit : null}];
  else rows = [
    {id: 'cycle', label: t('opFight') + ' /s', get: f => f.c ? f.c.dps : null, fmt: v => opNum(v)},
    {id: 'tp_real', label: t('rdvReal'), get: f => f.r.real ? f.r.real.time : f.r.time, fmt: s2, low: true},
    {id: 'tp_time', label: t('rdvAvg'), get: f => f.r.time, fmt: s2, low: true},
    {id: 'dps', label: 'DPS', get: f => f.r.dps, fmt: fmtDmg},
    {id: 'tp_round', label: t('cmpEngTp'), get: f => f.r.tp, fmt: v => opNum(v)},
    {id: 'jump', label: t('cmpEngTp'), get: f => kind === 'jump' ? f.r.tp : null, fmt: v => opNum(v)},
    {id: 'tphit', label: t('cycTpHit'), get: f => f.r.detail ? f.r.detail.tpPerHit : null, fmt: v => opNum(v)},
    {id: 'attacks', label: t('rdvAttacks'), get: f => f.r.attacks ? f.r.attacks.swings : null, fmt: v => v.toFixed(2)},
    {id: 'landed', label: t('rdvLanded'), get: f => f.r.attacks ? f.r.attacks.hits : null, fmt: v => v.toFixed(2)},
    {id: 'r2', label: t('cyc2r'), get: f => f.c ? f.c.check.twoRounds : null, fmt: pc},
    {id: 'tpws', label: t('cycTpWs'), get: f => f.c ? f.c.check.tpAtWs : null, fmt: v => opNum(v)},
    {id: 'chain', label: t('cycChain'), get: f => f.c ? f.c.chainShare : null, fmt: pc},
    {id: 'wsmin', label: t('cycWsMin'), get: f => f.c ? f.c.wsPerMin : null, fmt: v => opNum(v, 1)}];
  rows = rows.concat([['pdt', 'DT+PDT', '≤', +o.pdt], ['mdt', 'DT+MDT', '≤', +o.mdt], ['sb', 'Subtle Blow', '≥', +o.sb]].map(([k, label, op, lim]) =>
    ({id: k, label: lim ? `${label} ${op} ${lim}` : label, get: f => f.def ? f.def[k] : null, fmt: v => String(Math.round(v)), low: op === '≤',
      floor: lim ? v => op === '≤' ? v <= lim : v >= lim : null})));
  const first = rows.find(r => r.id === obj);
  return first ? [first].concat(rows.filter(r => r !== first)) : rows;
}
function opResultHTML(s, kind){
  const obj = opObj(kind), now = opFigures(s, kind), was = trialCount(s) ? opFigures(s, kind, true) : null;
  if (!now) return `<h3 class="ophd">${t('opResult')}</h3><p class="tpnote">${esc(t(kind === 'eng' && obj === 'cycle' ? 'cycNoWs' : 'optNoEngine'))}</p>`;
  const rows = opRows(kind, obj).filter(r => r.get(now) != null || (was && r.get(was) != null)), main = rows[0];
  // the objective's figure, big, with the difference to your set and its verdict
  const v = main.get(now), w = was ? main.get(was) : null;
  const d = w ? 100 * (main.low ? w / v - 1 : v / w - 1) : null;
  const verdict = d == null ? '' : Math.abs(d) < 2 ? 'eq' : d <= -2 ? 'worse' : d < 5 ? 'try' : 'better';
  const big = `<div class="opbig"><div><span class="muted small">${esc(main.label)}${was ? ' · ' + t('rdvTry') : ''}</span><div class="opval"><b>${main.fmt(v)}</b>` +
    (d != null ? `<em class="${d >= 0 ? 'up' : 'down'}">${d >= 0 ? '+' : '−'}${opNum(Math.abs(d), 1)} %</em>` : '') + `</div>` +
    (was ? `<span class="muted small">${t('opNow')} : ${main.fmt(w)}</span>` : '') + `</div>` +
    (verdict ? `<span class="opverdict ${verdict}">${esc(t('cycV_' + verdict))}</span>` : '') + `</div>`;
  const bar = opVisualHTML(obj, main, now, was);
  const cell = (r, x, y) => { const a = r.get(x), b = y ? r.get(y) : null;
    if (a == null) return '<td>—</td>';
    const better = b != null && (r.low ? a < b - 1e-9 : a > b + 1e-9), bad = r.floor && !r.floor(a);
    return `<td class="${better ? 'better' : ''} ${bad ? 'short' : ''}">${r.fmt(a)}</td>`; };
  const table = `<table class="rdvs optable"><thead><tr><th></th>${was ? `<th>${t('rdvMine')}</th>` : ''}<th>${was ? t('rdvTry') : t('rdvMine')}</th></tr></thead><tbody>` +
    rows.map((r, i) => `<tr class="${i ? '' : 'obj'}"><th>${esc(r.label)}${i ? '' : ' ★'}</th>${was ? cell(r, was, now) : ''}${cell(r, now, was)}</tr>`).join('') + `</tbody></table>`;
  const notes = kind === 'eng' && obj === 'cycle' && cycleInput(s) && !cycleInput(s).tpRule ? `<p class="kwarn">${esc(t('cycNoRule'))}</p>` : '';
  const calc = kind !== 'ws' && now.r && now.r.detail ? roundCalcHTML(now.r.detail, now.r.real) : '';
  return `<h3 class="ophd">${t('opResult')}</h3>${big}${bar}<div class="opres">${table}<div class="opside">${opChangesHTML(s)}</div></div>` +
    `${trialRow(s) || `<p class="muted small">${esc(t('opNoTry'))}</p>`}${notes}${calc}`;
}
// The picture of the result, the one that shows why the objective's figure moves: a fight in its three parts; the rounds to
// the weaponskill as they fall (real time); the TP gauge filled round by round (mean time); the factors of the melee DPS or
// of the TP a round; the weaponskill's damage by TP (a curve); else the figure as a bar a set
function opVisualHTML(obj, main, now, was){
  const r = now.r, w = was && was.r;
  if (obj === 'cycle' && now.c) return opBarHTML(now.c, was && was.c);
  if (obj === 'tp_real' && r && r.real) return opRoundsHTML(r.real, w && w.real);
  if (obj === 'tp_time' && r && r.detail) return opGaugeHTML(r.detail, w && w.detail);
  if (obj === 'dps' && r && r.detail && r.attacks) return opFactorsHTML([
    {label: t('opFHits'), get: x => x.attacks.hits, fmt: v => v.toFixed(2)},
    {label: t('opFDmg'), get: x => x.dps * x.detail.timeRound / x.attacks.hits, fmt: v => opNum(v)},
    {label: t('opFRound'), get: x => x.detail.timeRound, fmt: v => v.toFixed(2) + ' s', low: true}], r, w);
  if ((obj === 'tp_round' || obj === 'jump') && r && r.detail && r.attacks) return opFactorsHTML([
    {label: t('opFHits'), get: x => x.attacks.hits, fmt: v => v.toFixed(2)},
    {label: t('opFTpHit'), get: x => x.detail.tpPerHit, fmt: v => opNum(v)}], r, w);
  if ((obj === 'damage' || obj === 'damage_avg') && now.curve) return opCurveHTML(now.curve, was && was.curve, obj);
  const v = main.get(now), wv = was ? main.get(was) : null, top = Math.max(v || 0, wv || 0) || 1;
  const better = (a, b) => b == null ? true : main.low ? a <= b : a >= b;
  const one = (x, other, label) => `<div class="cycrow"><span>${esc(label)}</span><div class="cycbar"><i class="${better(x, other) ? 'w' : 'g'}" style="width:${100 * x / top}%"></i></div><span class="num">${main.fmt(x)}</span></div>`;
  return `<div class="cycparts">${was ? one(wv, v, t('rdvMine')) : ''}${one(v, wv, was ? t('rdvTry') : t('rdvMine'))}</div>`;
}
// The TP gauge to the weaponskill, a mark a round: how many rounds of that TP it takes (the engine's mean)
function opGaugeHTML(d, was){
  const need = x => Math.max(0, x.at - x.start) / x.tpRound, top = Math.max(need(d), was ? need(was) : 0) || 1;
  const one = (x, label) => { const n = need(x);
    return `<div class="cycrow"><span>${esc(label)}</span><div class="cycbar tall gauge" style="--round:${100 / top}%"><i class="w" style="width:${100 * n / top}%"><b>${esc(t('opRounds', {n: opNum(n, 2)}))}</b></i></div>` +
      `<span class="num">${opNum(x.tpRound)} TP</span></div>`; };
  return `<div class="cycparts">${was ? one(was, t('rdvMine')) : ''}${one(d, was ? t('rdvTry') : t('rdvMine'))}` +
    `<p class="cyclegend"><span class="muted">${esc(t('opGauge', {r: opNum(need(d), 2), tp: opNum(d.tpRound), at: d.at}))}</span></p></div>`;
}
// What the objective's figure is made of: a line a factor, your set and the try, and the try's change as a bar from the
// middle (green to the right when better, red to the left when worse; ±25 % fills it)
function opFactorsHTML(list, now, was){
  return `<table class="opfac"><tbody>${list.map(f => { const b = f.get(now), a = was ? f.get(was) : null;
    const d = a ? 100 * (b / a - 1) * (f.low ? -1 : 1) : null, wd = d == null ? 0 : Math.min(50, Math.abs(d) * 2);
    return `<tr><th>${esc(f.label)}</th>${was ? `<td>${f.fmt(a)}</td>` : ''}<td>${f.fmt(b)}</td>` + (was ? `<td class="facbar"><span class="mid"></span>` +
      `<i class="${d >= 0 ? 'up' : 'down'}" style="width:${wd}%;${d >= 0 ? 'left:50%' : 'right:50%'}"></i></td><td class="${d >= 0 ? 'up' : 'down'}">${d >= 0 ? '+' : '−'}${opNum(Math.abs(d), 1)} %</td>` : '') + `</tr>`; }).join('')}</tbody></table>`;
}
// The weaponskill's damage from 1000 to 3000 TP, your set and the try, the TP chosen marked (or the range shaded)
function opCurveHTML(c, was, obj){
  const W = 400, H = 90, top = Math.max(...c.map(p => p[1]), ...(was || []).map(p => p[1])) || 1;
  const x = tp => 24 + (W - 48) * (tp - 1000) / 2000, y = v => H - 16 - (H - 24) * v / top;
  const line = (pts, cls) => `<polyline class="${cls}" points="${pts.map(p => x(p[0]).toFixed(1) + ',' + y(p[1]).toFixed(1)).join(' ')}"/>`;
  const [a, b] = avgRange(S.optOpts || {}), tp = +(S.wsTp || 3000);
  const mark = obj === 'damage_avg' ? `<rect class="band" x="${x(a)}" y="6" width="${Math.max(2, x(b) - x(a))}" height="${H - 24}"/>` : `<line class="mark" x1="${x(tp)}" x2="${x(tp)}" y1="6" y2="${H - 18}"/>`;
  const ticks = [1000, 1500, 2000, 2500, 3000].map(v => `<text x="${x(v)}" y="${H - 4}">${v}</text>`).join('');
  return `<div class="opcurve"><svg viewBox="0 0 ${W} ${H}" role="img" aria-label="${esc(t('opCurve'))}">${mark}${was ? line(was, 'was') : ''}${line(c, 'now')}${ticks}</svg>` +
    `<p class="cyclegend"><span class="muted">${esc(t('opCurve'))}</span>${was ? `<span><i class="g"></i>${esc(t('rdvMine'))}</span>` : ''}<span><i class="w"></i>${esc(was ? t('rdvTry') : t('rdvMine'))}</span></p></div>`;
}
// The rounds to the weaponskill as a bar a set: each part the chance of that many rounds
function opRoundsHTML(r, was){
  const n = Math.max(r.probs.length, was ? was.probs.length : 0);
  // inside a part: its rounds and chance when it has room, the rounds alone when less, the hover saying it all
  const part = (p, i) => p < .01 ? '' : `<i class="r${Math.min(i, 7)}" style="width:${100 * p}%" title="${esc(t('opRounds', {n: i + 1}))} · ${opNum(100 * p)} %">` +
    (p >= .25 ? `<b>${esc(t('opRounds', {n: i + 1}))} · ${opNum(100 * p)} %</b>` : p >= .07 ? `<b>${i + 1}</b>` : '') + `</i>`;
  const one = (x, label) => `<div class="cycrow"><span>${esc(label)}</span><div class="cycbar tall">${x.probs.map(part).join('')}</div>` +
    `<span class="num">${esc(t('opMean', {n: opNum(x.rounds, 2)}))}</span></div>`;
  const used = [...Array(n).keys()].filter(i => r.probs[i] >= .01 || (was && was.probs[i] >= .01));
  return `<div class="cycparts">${was ? one(was, t('rdvMine')) : ''}${one(r, was ? t('rdvTry') : t('rdvMine'))}` +
    `<p class="cyclegend"><span class="muted">${esc(t('opRoundsLbl'))}</span>${used.map(i => `<span><i class="r${Math.min(i, 7)}"></i>${i + 1}</span>`).join('')}</p></div>`;
}
// A fight's damage in three parts: melee, weaponskills, skillchains (your set above the try when there is one)
function opBarHTML(c, was){
  const one = (r, label) => { const tot = r.melee + r.ws + r.sc || 1;
    return `<div class="cycrow"><span>${esc(label)}</span><div class="cycbar"><i class="m" style="width:${100 * r.melee / tot}%"></i><i class="w" style="width:${100 * r.ws / tot}%"></i>` +
      `<i class="c" style="width:${100 * r.sc / tot}%"></i></div><span class="num">${opNum(r.dps)}</span></div>`; };
  const lg = (k, label, get) => `<span><i class="${k}"></i>${label} ${was ? opNum(get(was)) + ' → ' : ''}${opNum(get(c))}</span>`;
  return `<div class="cycparts">${was ? one(was, t('rdvMine')) : ''}${one(c, was ? t('rdvTry') : t('rdvMine'))}` +
    `<p class="cyclegend">${lg('m', t('cycMelee'), r => r.melee)}${lg('w', t('cycWs'), r => r.ws)}${lg('c', t('cycSc'), r => r.sc)}</p></div>`;
}
// The pieces the try changes: the slot, your piece, the try's
function opChangesHTML(s){
  const tr = S.trial[trialKey(s)] || {}, plain = withoutTrial(() => withWeapons(s).pieces);
  const list = SLOTS.filter(slot => tr[slot] && !heldAlready(s, slot, tr[slot]));
  if (!list.length) return '';
  return `<h4 class="ophd2">${t('opChanges')}</h4><ul class="opchg">${list.map(slot => `<li><span class="sl">${esc(SLOT_NAMES[S.lang][slot] || slot)}</span>` +
    `<span>${esc((plain[slot] || {}).name || '—')}</span><span class="to">→ ${esc(tr[slot].name || '—')}</span></li>`).join('')}</ul>`;
}

/* ---- the whole-fight objective (atelier/cycle.js) ---- */
const CYCLE_TIMED = ['Berserk', 'Aggressor', 'Warcry'];
// Measured on the Locus Ghost Crabs (2026-10-04): 32 TP a hit taken, ~0.18 hits a second
const CYCLE_TP_TAKEN = 5.8;
const cycleReady = () => !!(window.FFXI && FFXI.opt && FFXI.opt.cycle);
const isCycle = () => cycleReady() && (S.optOpts || {}).engObj === 'cycle';
// The weaponskill sets of the job that open with the engaged set's main weapon (its combat skill, and the weapon a
// weaponskill is locked to: Disaster is Laphria's, never Ukonvasara's; the same test as the weaponskill's weapons,
// ws_page.js heldChoices), the support tier's first
function cycleWsSets(s){
  const d = data(), main = (withWeapons(s).pieces.main || {}).name, skill = main && weaponSkills()[main];
  if (!d || !skill) return [];
  const opens = ws => { const lock = (wsInfoOf(ws).lock || '').toLowerCase(); return !lock || lock.includes(main.toLowerCase()); };
  const list = d.sets.filter(x => family(x.path, x.pieces) === 'ws' && wsOfSet(x) && wsSkills()[wsOfSet(x)] === skill && opens(wsOfSet(x)));
  // first the weaponskill sets of the engaged set's own version (Ukonvasara.Trust: the .Trust ones; the set itself: the
  // sets themselves), then the weapon's weaponskills in the job's order (export ws_by_weapon, from <JOB>_WS_CONFIG:
  // Ukko's Fury for Ukonvasara), then by name
  const tier = (s.path.match(/\.(Group|Solo|Trust)$/) || [])[1] || null, order = (mergedOf('ws_by_weapon') || {})[main] || [];
  const tierRank = x => { const v = (x.path.match(/\.(Group|Solo|Trust)$/) || [])[1] || null; return v === tier ? 0 : v ? 2 : 1; };
  const wsRank = x => { const i = order.indexOf(wsOfSet(x)); return i === -1 ? 99 : i; };
  return list.sort((a, b) => tierRank(a) - tierRank(b) || wsRank(a) - wsRank(b) || a.path.localeCompare(b.path));
}
// The weaponskill set the fight is worked out with: the one picked for this engaged set, else the first of the list
function cycleWsSet(s){
  const list = cycleWsSets(s), want = ((S.optOpts || {}).cycWsBy || {})[s.path];
  return list.find(x => x.path === want) || list[0] || null;
}
// O.cycle's input for an engaged set: its context, the weaponskill set's, how you play (plain data: it goes to the workers)
function cycleInput(s){
  const o = S.optOpts || {}, w = cycleWsSet(s);
  if (!w) return null;
  const b = liveBuffs(buffState()), r = tpAsk(w, withWeapons(w).pieces, null);
  // the game's rule counts a Warcry the page has on: the cycle times Warcry itself
  const warcry = S.job === 'WAR' && jaOn(b, 'Warcry') ? warcryTp(b) : 0;
  const rule = tpRuleOf(r, warcry);
  // only the abilities your job or subjob has (a BRD/DNC has no Berserk), Warcry the WAR's own only (as a subjob's it
  // has no Savagery TP Bonus the cycle counts)
  const mine = new Set(jasOf().filter(j => j.as === 'main' || j.as === 'sub').map(j => j.name));
  const timed = (o.cycTimed ?? true) ? CYCLE_TIMED.filter(n => mine.has(n) && (n !== 'Warcry' || S.job === 'WAR')) : [];
  return {engaged: engContextInput(s), ws: optContextInput(w), wsPieces: optPieces(withWeapons(w).pieces), at: +o.engAt || 1000,
    keepAm: o.cycAm ?? true, timed, tpRule: rule, tpTaken: (o.cycHits || 'me') === 'me' ? CYCLE_TP_TAKEN : 0, n: 300, seed: 7, cache: {}};
}
// One set over a fight, kept while nothing it reads changes (the page renders often)
function cycleOf(s, plain){
  const inp = cycleInput(s);
  if (!inp) return null;
  const pieces = optPieces(plain ? withoutTrial(() => withWeapons(s).pieces) : withWeapons(s).pieces);
  const key = JSON.stringify([inp.engaged, inp.ws, inp.wsPieces, inp.at, inp.keepAm, inp.timed, inp.tpRule, inp.tpTaken, pieces]);
  S._cyc = S._cyc || {};
  if (!(key in S._cyc)) {
    let r = null;
    try { r = FFXI.opt.cycle(Object.assign({}, inp, {pieces: {engaged: pieces, ws: inp.wsPieces}, n: 600})); } catch (e) { r = null; }
    if (Object.keys(S._cyc).length > 40) S._cyc = {};
    S._cyc[key] = r;
  }
  return S._cyc[key];
}
// the option that counts Hoxne Ampulla's enchantment (stats.js ENCHANT_KEPT)
Object.assign(T.fr, {optHoxne: 'Hoxne Ampulla active', optHoxneTip: 'Compte son enchantement (Double Attack +100 %, 30 minutes, 1000 gils l’utilisation) comme actif tant qu’elle est portée : l’optimiseur peut alors la choisir. Décoché, elle ne compte pour rien et n’est jamais proposée'});
Object.assign(T.en, {optHoxne: 'Hoxne Ampulla active', optHoxneTip: 'Counts its enchantment (Double Attack +100%, 30 minutes, 1000 gil per use) as active while it is worn: the optimizer may then pick it. Unchecked, it counts for nothing and is never suggested'});
// the left column's blocks (limits, search tabs)
// the option that counts Vim Torque's latent Regain (stats.js ENCHANT_KEPT)
Object.assign(T.fr, {optVim: 'Vim Torque actif', optVimTip: 'Compte le Regain latent du Vim Torque (+15) et du Vim Torque +1 (+20) comme actif tant qu’il est porté : l’optimiseur peut alors le choisir. L’effet marche arme sortie et te draine 50 HP par tick. Décoché, le collier ne compte que pour sa défense.'});
Object.assign(T.en, {optVim: 'Vim Torque active', optVimTip: 'Counts the latent Regain of Vim Torque (+15) and Vim Torque +1 (+20) as active while it is worn: the optimizer may then pick it. The effect works with your weapon drawn and drains 50 HP a tick. Unchecked, the neck piece counts for its defense only.'});
Object.assign(T.fr, {opLimits: 'Limites à respecter', opTabPieces: 'Pièces', opTabCalc: 'Calcul', opTabSpecial: 'Spéciaux',
  opSpecialWhy: 'Des pièces à effet particulier, comptées seulement quand tu les coches.'});
Object.assign(T.en, {opLimits: 'Limits', opTabPieces: 'Pieces', opTabCalc: 'Calculation', opTabSpecial: 'Special',
  opSpecialWhy: 'Pieces with a special effect, counted only when you check them.'});
// what each objective is, on hover (events.js showTip): one or two sentences, and what sets it apart from its neighbours
Object.assign(T.fr, {
  objTip_tp_real: 'Le set qui arrive le plus vite au TP de la WS, en comptant le hasard des coups round par round. Le plus proche du jeu. Ne regarde que la vitesse : à temps égal, le temps moyen départage.',
  objTip_tp_time: 'Le même but, calculé plus simplement : comme si chaque round donnait le TP moyen. À comparer au temps réel, qui compte le hasard des coups.',
  objTip_dps: 'Les dégâts par seconde de tes auto-attaques seules, sans la WS. Pour un set où ce sont les coups qui comptent, pas le TP.',
  objTip_tp_round: 'Le plus de TP gagné à chaque round d’attaque. La durée du round ne compte pas, contrairement aux deux « temps jusqu’à la WS ».',
  objTip_cycle: 'Les dégâts d’un combat entier : auto-attaques, WS, skillchains et Aftermath ensemble. En test : résultat à confirmer en jeu.',
  objTip_damage: 'Les dégâts de la WS lancée au TP choisi ({tp}). Pour une WS que tu lances toujours au même TP.',
  objTip_damage_avg: 'La moyenne des dégâts de la WS de {a} à {b} TP, tous les 250. Pour une WS que tu lances à des TP variables.',
  objTip_tp_return: 'Le plus de TP rendu par les coups de la WS, sans regarder ses dégâts : pour enchaîner la suivante plus vite.',
  objTip_jump: 'Le plus de TP sur le round d’attaque que Jump et High Jump font dans leur propre set.'});
Object.assign(T.en, {
  objTip_tp_real: 'The set that reaches the weaponskill\'s TP fastest, with the randomness of each hit counted round by round. The closest to the game. Speed only: at equal time, average time breaks the tie.',
  objTip_tp_time: 'The same goal, calculated more simply: as if every round gave the average TP. Compare it with real time, which counts the randomness of the hits.',
  objTip_dps: 'The damage per second of your auto-attacks alone, without the weaponskill. For a set where the hits matter, not the TP.',
  objTip_tp_round: 'The most TP gained each attack round. Round length does not count, unlike the two "time to WS" objectives.',
  objTip_cycle: 'The damage of a whole fight: auto-attacks, weaponskills, skillchains and Aftermath together. Experimental: confirm the result in game.',
  objTip_damage: 'The damage of the weaponskill used at the chosen TP ({tp}). For a weaponskill you always use at the same TP.',
  objTip_damage_avg: 'The average damage of the weaponskill from {a} to {b} TP, every 250. For a weaponskill you use at varying TP.',
  objTip_tp_return: 'The most TP returned by the weaponskill\'s hits, regardless of its damage: to get to the next one faster.',
  objTip_jump: 'The most TP from the attack round Jump and High Jump do in their own set.'});
