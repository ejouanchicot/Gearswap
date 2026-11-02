<!--
  GearSwap Atelier · a weapon cycle in the job's settings (cycle.ts): its weapons as tiles in the order the key goes
  through them, moved by dragging or by their arrows, taken out by ✕; under them the weapons to add, filtered as one
  types. The buttons keep the attributes weapon_cycles.js wcClick reads (data-wcup, data-wcdown, data-wcx, data-wcadd,
  data-wcreset); a drop calls wcMove.

  @file    atelier/src/screens/config/CycleEdit.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {CycleView} from './cycle';

  let {c}: {c: CycleView} = $props();
  let q = $state('');
  // the weapons to add, folded under a button (the cycle alone fits without scrolling)
  let addOpen = $state(false);
  let from = $state(-1), over = $state(-1);
  const drop = (to: number) => { const f = from; from = -1; over = -1; if (f >= 0 && f !== to) wcMove(c.mode, f, to); };
</script>

<section class="wce">
  <div class="wce-h" title={c.note}><b>{c.title}</b><span>{c.count}</span><i></i>{#if c.reset}<button type="button" class="linkbtn" data-wcreset={c.mode} title={c.reset.tip}>{c.reset.label}</button>{/if}<button type="button" class="wce-open" class:on={addOpen} aria-expanded={addOpen} onclick={() => addOpen = !addOpen}>{addOpen ? '−' : '+'} {c.add}</button></div>
  <div class="wce-row">
    {#each c.tiles as w, i (w.value)}
      {#if i}<span class="wce-ar" aria-hidden="true">→</span>{/if}
      <div class="wce-t" class:start={w.start} class:drag={from === i} class:over={over === i && from !== i} draggable="true" role="listitem"
        ondragstart={(e) => { from = i; e.dataTransfer?.setData('text/plain', w.value); }} ondragend={() => { from = -1; over = -1; }}
        ondragover={(e) => { e.preventDefault(); over = i; }} ondragleave={() => { if (over === i) over = -1; }} ondrop={(e) => { e.preventDefault(); drop(i); }}>
        <span class="wce-n">{i + 1}</span>
        <span class="wce-i">{@html w.iconHtml}</span>
        <b title={w.item}>{w.item}</b>
        <small class:warn={w.warn}>{w.tag}</small>
        <span class="wce-b">
          <button type="button" data-wcup={c.mode + '|' + w.value} disabled={w.first} title={c.tips.up}>◀</button>
          <button type="button" data-wcdown={c.mode + '|' + w.value} disabled={w.last} title={c.tips.down}>▶</button>
          <button type="button" class="x" data-wcx={c.mode + '|' + w.value} disabled={c.tiles.length < 2} title={c.tips.out}>✕</button>
        </span>
      </div>
    {/each}
    <span class="wce-loop">{c.loop}</span>
  </div>
  {#if addOpen}<div class="wce-add">
    <label><input type="search" placeholder={c.addPh} bind:value={q}></label>
    {#if c.picks.length}
      <div class="wce-groups">{#each c.groups as g (g.title)}{@const shown = g.picks.filter(p => !q.trim() || p.name.toLowerCase().includes(q.trim().toLowerCase()))}{#if shown.length}<div class="wce-g"><span class="wce-gt">{g.title}<small>{shown.length}</small></span><div class="wce-picks">{#each shown as p (p.name)}<button type="button" data-wcadd={c.mode + '|' + p.name} title={p.tip}>{@html p.iconHtml}<span>{p.name}</span>{#if p.back}<em>{c.backTag}</em>{/if}</button>{/each}</div></div>{/if}{/each}</div>
    {:else}<p>{c.none}</p>{/if}
  </div>{/if}
</section>
