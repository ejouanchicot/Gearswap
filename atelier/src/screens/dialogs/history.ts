// GearSwap Atelier · the history of what the page wrote to GearSwap's files: a fold an entry (what it did, the job, the
// set, when, Undo while it can still be undone), the file, the set deleted, a line a slot changed.
// The rules are the old page's openHistory (push.js): the list is the game's (/push_history). A field ending in Html is
// one of the old page's texts it wrote unescaped. Undo keeps the attribute its handler reads (data-pushundo).
//
// @file    atelier/src/screens/dialogs/history.ts
// @author  ejouanchicot

export interface HistEntry {
  undone: boolean; kind: string; tag: string; job: string; path: string; at: string;
  state: {k: 'undone'; text: string} | {k: 'undo'; id: unknown; html: string} | {k: 'later'; title: string; html: string};
  file: string; deleted: null | {text: string; html: string};
  changes: Array<{slotHtml: string; before: string; after: string}>;
}
export interface HistoryView { toast: string; entries: HistEntry[]; emptyHtml: string }

/** The history's body (openHistory), the game's list read */
export function historyView(list: LegacyAny[], toast: string): HistoryView {
  const kind = (e: LegacyAny) => e.config ? 'config' : e.deleted ? 'delete' : e.created ? 'create' : 'pieces';
  return {toast, emptyHtml: t('histEmpty'), entries: list.map(e => ({undone: !!e.undone, kind: kind(e), tag: t('histKind_' + kind(e), {n: (e.changes || []).length}),
    job: e.job, path: shortPath(e.path), at: e.at,
    state: e.undone ? {k: 'undone' as const, text: t('histUndone', {d: e.undone})} : e.undoable ? {k: 'undo' as const, id: e.id, html: t('histUndo')}
      : {k: 'later' as const, title: t('histLaterTip'), html: t('histLater')},
    file: e.file, deleted: e.deleted ? {text: e.deleted.map(shortPath).join(' · '), html: ' ' + t('histDeleted')} : null,
    changes: (e.changes || []).map((c: LegacyAny) => ({slotHtml: (SLOT_NAMES[(S as LegacyAny).lang] || {})[c.slot] || c.slot, before: c.before || '', after: c.after || t('histInherit')}))}))};
}
