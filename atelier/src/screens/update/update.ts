// GearSwap Atelier · the update screen (the ⬆ button of the top bar, or //gs c upgrade in game): the version installed
// and the latest one, what installing it changes, the release's notes, and going back to the version before.
// The rules are the old page's update.js (its state UPD, the clicks data-updopen, data-updcheck, data-updapply,
// data-updundo) over update_core.js, the files going through AtelierLink; shown as a page of the Settings (S._cfg with S._upd).
//
// @file    atelier/src/screens/update/update.ts
// @author  ejouanchicot

export interface UpdateView {
  title: string; back: string; lede: string; safe: string;
  have: {label: string; v: string}; latest: {label: string; v: string};
  busy: boolean; step: string;
  check: string;
  plan: null | {line: string; changed: string; kept: string; apply: string};
  notes: null | {title: string; blocks: NoteBlock[]; more: string; url: string};
  undo: null | {label: string; why: string};
  msg: string; msgCls: string;
}

const listOf = (paths: string[]): string => paths.slice(0, 8).join(', ') + (paths.length > 8 ? ` (+${paths.length - 8})` : '');

/** A release's notes in the page's language: its "## Français" or "## English" part (a release's notes are
 *  written in both), the whole text when that part is missing */
export function notesIn(text: string, lang: string): string {
  const want = lang === 'en' ? 'english' : 'français';
  const parts = text.split(/^##[ \t]+/m);
  const mine = parts.find(p => (p.split(/\r?\n/, 1)[0] ?? '').trim().toLowerCase() === want);
  return mine ? mine.slice(mine.search(/\r?\n/) + 1).trim() : text;
}

/** A piece of a line of the notes: plain, **bold** or `code` */
export interface NoteRun { text: string; bold?: boolean; code?: boolean }
/** A block of the notes: a heading (a "###" line, or a line all in bold), a paragraph or a list */
export type NoteBlock = {k: 'h'; runs: NoteRun[]} | {k: 'p'; runs: NoteRun[]} | {k: 'ul'; items: NoteRun[][]};

function noteRuns(line: string): NoteRun[] {
  return line.split(/(`[^`]+`|\*\*[^*]+\*\*)/).filter(Boolean).map(s =>
    s.startsWith('`') && s.endsWith('`') && s.length > 2 ? {text: s.slice(1, -1), code: true}
      : s.startsWith('**') && s.endsWith('**') && s.length > 4 ? {text: s.slice(2, -2), bold: true} : {text: s});
}

/** The notes' Markdown as GitHub writes it, cut into blocks the page draws itself (no HTML taken from the text):
 *  headings, paragraphs, "- " lists, **bold** and `code`; anything else stays plain text */
export function noteBlocks(text: string): NoteBlock[] {
  const out: NoteBlock[] = [];
  let para: string[] = [];
  const flush = () => { if (para.length) out.push({k: 'p', runs: noteRuns(para.join(' '))}); para = []; };
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    const head = line.match(/^#{1,6}\s+(.*)$/) || line.match(/^\*\*([^*]+)\*\*:?$/);
    const item = line.match(/^[-*]\s+(.*)$/);
    if (!line) flush();
    else if (head) { flush(); out.push({k: 'h', runs: noteRuns(head[1] ?? '')}); }
    else if (item) {
      flush();
      const last = out[out.length - 1];
      if (last && last.k === 'ul') last.items.push(noteRuns(item[1] ?? '')); else out.push({k: 'ul', items: [noteRuns(item[1] ?? '')]});
    } else para.push(line);
  }
  flush();
  return out;
}

/** The update screen, or null when it is not the one shown */
export function updateView(): UpdateView | null {
  if (!(S._cfg && S._upd) || (S._pkg && typeof renderPackages === 'function')) return null;
  const U = UPD, busy = U.state === 'busy', p = U.plan, rel = U.rel;
  const step = U.step ? t('updStep_' + U.step.what, {n: U.step.n, m: U.step.m}) : '';
  const msg = U.msg || {git: t('updGit'), none: t('updNoRelease'), uptodate: t('updUpToDate')}[U.state as string] || '';
  return {title: t('updTitle'), back: t('updBack'), lede: t('updLede'), safe: t('updSafe'),
    have: {label: t('updHave'), v: U.inst ? (U.inst.version || t('updNone')) : t('updUnknown')},
    latest: {label: t('updLatest'), v: rel ? rel.version : U.state === 'none' ? t('updNone') : t('updUnknown')},
    busy, step, check: busy && !p ? t('updChecking') : t('updCheck'),
    plan: U.state === 'ready' && p ? {
      line: t('updReady', {n: p.add.length + p.update.length + p.remove.length, a: p.add.length, u: p.update.length, r: p.remove.length}),
      changed: p.changed.length ? t('updChanged', {l: listOf(p.changed)}) : '',
      kept: p.kept.length ? t('updKept', {l: listOf(p.kept)}) : '',
      apply: busy ? t('updApplying') : t('updApply', {v: rel.version})} : null,
    notes: rel && rel.notes && (U.state === 'ready' || U.state === 'done') ? {title: t('updNotes'), blocks: noteBlocks(notesIn(rel.notes, S.lang)), more: t('updMore'), url: rel.url} : null,
    undo: U.last && U.state !== 'git' && !busy ? {label: t('updUndo', {v: U.last.from || '?'}),
      why: t('updUndoWhy', {from: U.last.from || '?', to: U.last.to, at: String(U.last.at || '').slice(0, 16).replace('T', ' ')})} : null,
    msg, msgCls: U.msgCls || (U.state === 'git' ? 'kwarn' : '')};
}
