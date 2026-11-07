<!--
  GearSwap Atelier · the job's HP reference (stat_enh.js hpRefView): its rule and its set, on the stats optimizer and,
  on a job whose reference is one of its engaged or weaponskill sets (a WAR), on theirs too, with the band the set keeps.

  @file    atelier/src/screens/optimizer/HpRef.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  let {hr, band = ''}: {hr: ReturnType<typeof hpRefView>; band?: string} = $props();
</script>

<div class="ophpref" title={hr.tip}><span class="ophpk">{hr.title}</span><span class="verseg ophpseg" role="group">{#each hr.rules as r (r.v)}<button data-hpref-rule={r.v} aria-pressed={r.pressed}>{r.label}</button>{/each}</span>{#if hr.sets}<select class="buffsel ophpsel" data-hpref-set aria-label={hr.title} use:selSync={(hr.sets.find(x => x.selected) || {value: ''}).value}>{#each hr.sets as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</select>{/if}</div>{#if band}<p class="muted small">{band}</p>{/if}
