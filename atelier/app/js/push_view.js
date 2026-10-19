// GearSwap Atelier · push_view.js: what the windows of push.js show before writing (push, delete, new set). In plain
// words first: the pieces that go into the set, slot by slot, each with the game's icon, and what protects the
// player's file. The file's name and its lines before and after (atelier/src/screens/dialogs/pushview.ts diffLines) are one fold below, for who wants them;
// the fold stays as it was left (S.pushTech).

Object.assign(T.fr, {pushTitle: 'Enregistrer dans GearSwap', pushGo: 'Enregistrer', addGo: 'Créer le set',
  pvPush: 'Ces pièces vont dans ton set {p} :', pvPushNew: 'Une version {v} de ton set {p} va être créée, avec ces pièces :',
  pvEmptied: 'laissé vide', pvInherit: 'reprend la pièce de {b}', pvInheritAny: 'reprend la pièce du set de base',
  pvSafe: 'Rien n’est perdu : une copie de ton fichier est gardée, et tu peux annuler depuis l’historique. GearSwap se recharge tout seul après.',
  pvDel: 'Le set {p} va être retiré de ton GearSwap.', pvDelAlso: 'Ses versions partent avec lui : {l}.',
  pvDelSafe: 'Une copie de ton fichier est gardée, et tu peux annuler depuis l’historique. Ce qui portait ce set prendra le set plus général. GearSwap se recharge tout seul après.',
  pvAdd: 'Un set {p} va être créé, vide pour l’instant : tu le remplis ensuite depuis la page.',
  pvTech: 'Détail technique : le fichier et les lignes modifiées', pvFile: 'Fichier : {f}'});
Object.assign(T.en, {pushTitle: 'Save to GearSwap', pushGo: 'Save', addGo: 'Create the set',
  pvPush: 'These pieces go into your set {p}:', pvPushNew: 'A {v} version of your set {p} will be created, with these pieces:',
  pvEmptied: 'left empty', pvInherit: 'takes the piece of {b} again', pvInheritAny: 'takes the base set’s piece again',
  pvSafe: 'Nothing is lost: a copy of your file is kept, and the history can undo it. GearSwap reloads by itself afterwards.',
  pvDel: 'The set {p} will be taken out of your GearSwap.', pvDelAlso: 'Its versions go with it: {l}.',
  pvDelSafe: 'A copy of your file is kept, and the history can undo it. Whatever wore this set will take the more general one. GearSwap reloads by itself afterwards.',
  pvAdd: 'A set {p} will be created, empty for now: you fill it from the page afterwards.',
  pvTech: 'Technical detail: the file and the lines changed', pvFile: 'File: {f}'});

// The windows themselves are drawn by the Svelte application (atelier/src/screens/dialogs/pushview.ts); the fold's
// state is kept here
document.addEventListener('toggle', e => {
  if (e.target.matches && e.target.matches('[data-pushtech]')) { S.pushTech = e.target.open; save(); }
}, true);
