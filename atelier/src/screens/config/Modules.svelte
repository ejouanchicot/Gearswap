<!--
  GearSwap Atelier · the Settings part of the job's settings (modules.ts), in the frame of the three parts
  (ProFrame.svelte; SPEC notes/docs-perso/config-pro-2026-10-30): a section a subject, a line an option (its icon, its
  name, a plain sentence, its control), the job's refill and the HUD's colours as sections of their own. The controls keep the
  attributes the old page's handlers read (modules.js, module_ux.js, reg_special.js: data-modtheme, data-regsel,
  data-modsave, data-modundo, data-modrevert, data-modstd, data-modqclear, data-hudcolor*, data-hudresetall, data-refill*; the search box
  #modq); a setting's control is ModCtl.svelte.

  @file    atelier/src/screens/config/Modules.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import ModCtl from './ModCtl.svelte';
  import ProFrame from './ProFrame.svelte';
  import type {ModulesView, RegRow, RegCard, RefillSpecial, HudColors} from './modules';

  let {view}: {view: ModulesView} = $props();
</script>

{#snippet gauge(r: RegRow)}{@const gg = r.gauge!}<div class="rgauge" data-gauge={gg.attr} class:off={gg.off}><div class="rgbar">{#each gg.parts as p, i (i)}<span class="rgpart" style="flex:{p.flex}" title={p.tip}><b>{p.label}</b>{#if i < gg.parts.length - 1 && !gg.off}<i class="rghandle" data-gaugeat={i} title={p.tip}></i>{/if}</span>{/each}</div><div class="rgticks">{#each gg.parts as p, i (i)}<span style="flex:{p.flex}">{p.from}</span>{/each}<span class="rgend">{gg.end}</span></div></div><details class="rgfix"><summary>{gg.fix}</summary><ModCtl c={r.ctl} /></details>{/snippet}
{#snippet opt(r: RegRow)}<div class="cfg-r" class:sel={r.sel} class:chg={r.changed} class:tall={r.tall || !!r.gauge} data-regsel={r.key}>
  <span class="cfg-ri">{@html r.iconHtml}</span>
  <div class="cfg-rt"><b>{r.label}</b>{#if r.sub}<span>{r.sub}</span>{/if}</div>
  <div class="cfg-c">{#if r.gauge}{@render gauge(r)}{:else}<ModCtl c={r.ctl} />{/if}</div>
</div>{/snippet}
{#snippet refill(s: RefillSpecial)}<div class="rfnow"><small>{s.now}</small><div class="rfitems">{#each s.items as it, i (i)}<span class="rfitem">{@html it.icoHtml}{it.label}<b>×{it.count}</b></span>{:else}<i>{s.empty}</i>{/each}</div></div>
  <div class="rfmodes"><span class="aseg">{#each s.modes as m (m.attr)}<button type="button" class:on={m.on} data-refillmode={m.attr} title={m.tip}>{m.label}</button>{/each}</span></div>
  {#if s.list}<div class="rflist"><ModCtl c={s.list.ctl} /></div>{:else if s.addExtra}<div class="rfadd"><button type="button" class="modaddbtn" data-refillmode={s.addExtra.attr}>{s.addExtra.label}</button></div>{/if}
  <div class="rfsubs"><b title={s.subs.tip}>{s.subs.title}</b>
    {#each s.subs.rows as sr (sr.del)}<div class="rfsub"><div class="rfsubh"><span>{sr.label}</span><button type="button" class="medel" data-refilldelsub={sr.del} title={sr.delTip} aria-label={sr.delTip}>×</button></div>{#if sr.row}<div class="rctl"><ModCtl c={sr.row.ctl} /></div>{:else}<small>{sr.summary}</small>{/if}</div>{/each}
    {#if s.subs.add}<select class="meadd" data-refilladdsub={s.subs.add.attr}><option value="">{s.subs.add.label}</option>{#each s.subs.add.options as o (o)}<option value={o}>/{o}</option>{/each}</select>{/if}</div>{/snippet}
{#snippet colors(s: HudColors)}<div class="hcol">{#each s.parts as p (p.attr)}<label class="hcsw" title={p.label}><input type="color" value={p.hex} data-hudcolor={p.attr}><span>{p.label}</span>{#if p.auto}<em>{p.auto}</em>{/if}{#if p.reset}<button type="button" data-hudcolorreset={p.reset} title={p.resetTip} aria-label={p.resetTip}>↺</button>{/if}</label>{/each}</div>
  {#if s.values.length}<div class="hcolt">{s.valuesTitle}</div><div class="hcol">{#each s.values as v (v.attr)}<label class="hcsw"><input type="color" value={v.hex} data-hudcolor={v.attr}><span>{v.label}</span></label>{/each}</div>{/if}{/snippet}
{#snippet section(c: RegCard)}<div class="cfg-sec"><span>{c.title}</span>{#if c.small}<small>{c.small}</small>{/if}{#if c.own}<em>{c.own}</em>{/if}</div>
  <div class="cfg-grp">{#if c.special}<div class="cfg-r tall special" class:sel={view.detail && view.detail.title === c.title} data-regsel={c.id}><div class="cfg-c">{#if c.special.k === 'colors'}{@render colors(c.special)}{:else}{@render refill(c.special)}{/if}</div></div>{:else}{#each c.rows as r (r.key)}{@render opt(r)}{/each}{/if}</div>{/snippet}

<ProFrame nav={view.nav} head={view.head} detail={view.detail} foot={view.foot} credit={view.credit}>
  {#if view.none}<p class="cfg-empty">{view.none}</p>{/if}
  {#if view.empty}<p class="cfg-empty">{view.empty}</p>{/if}
  {#if view.hud}
    <div class="hudstage"><div class="hudscreen"><small>{view.hud.title} · {view.hud.note}</small>{#if view.hud.error}<p class="huderr">{view.hud.error}</p>{:else if view.hud.html}<div class="hudtext" style={view.hud.style}>{@html view.hud.html}</div>{:else}<p class="hudwait">…</p>{/if}
      <p class="hudhint">{view.hud.hint}{#if view.hud.reset} <button type="button" class="rgo" {...view.hud.reset.attrs}>{view.hud.reset.label}</button>{/if}</p></div>
      <div class="hudside">{#each view.sections.filter(c => c.id.startsWith('hud|') && !c.special) as c (c.id)}{@render section(c)}{/each}</div></div>
    {#each view.sections.filter(c => !c.id.startsWith('hud|') || c.special) as c (c.id)}{@render section(c)}{/each}
  {:else}{#each view.sections as c (c.id)}{@render section(c)}{/each}{/if}
</ProFrame>
