// GearSwap Atelier · the Push button of a set with pieces on trial (the trial's bar, the search window's foot): Push,
// Push to a version that does not exist yet (Full is the weaponskill set itself: said on the button), or open the
// version that already exists. Without the game linked it is there but greyed, saying why. The rules are the old
// page's pushButton (trial.js); the buttons keep the attributes its handlers read (data-pushopen, data-veropen:
// events.js), where to write is push.js pushTarget.
//
// @file    atelier/src/screens/sets/push.ts
// @author  ejouanchicot

export interface PushBtn { open: boolean; disabled: boolean; title: string | null; labelHtml: string }

/** The Push button of a set (pushButton); live: the game can write the file */
export function pushBtnView(s: LegacyAny, live: boolean): PushBtn {
  const tg = pushTarget(s);
  if (tg.exists) return {open: true, disabled: false, title: t('pushVerOpenTip', {v: tg.tier}), labelHtml: t('pushVerOpen', {v: tg.tier})};
  // Full is the weaponskill set itself (GearSwap reads no .Full): said on the button
  const full = buffTier() === 'Full' && TIERED.test(s.path) && !/\.(Group|Solo|Trust)$/.test(s.path);
  const labelHtml = tg.create ? t('pushToVer', {v: tg.tier}) : full ? t('pushToFull') : t('pushBtn');
  // the game writes into the files of the job it has loaded: another job there is said, not "the game is off"
  const tip = !live ? t('pushNeedsGame') : tg.create ? t('pushToVerTip', {v: tg.tier}) : full ? t('pushToFullTip') : '';
  return {open: false, disabled: !live, title: tip || null, labelHtml};
}
