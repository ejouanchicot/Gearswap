<!--
  GearSwap Atelier · the list of the job's sets on the left (setlist.ts), for the Sets screen, Buffs & target and My
  character's stats, drawn as a game menu: the search, the families' menu (one family shown at a time, data-listfam),
  the family's title, its sets, "Tout optimiser" at the foot. The rows keep the attributes the old page's handlers read
  (events.js data-pick / data-vpick, data-wskill, data-aliasfold, data-listall, data-optsets; list_prefs.js data-listfam,
  the drag of data-rowpath rows and onto data-owngrp entries, the row actions, data-listedit / data-listhide /
  data-listdel), and the list is resized by its grip (list_prefs.js listgrip).

  @file    atelier/src/screens/sets/SetList.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import MogNote from '../../components/MogNote.svelte';
  import ListHead from './ListHead.svelte';
  import type {SetListView} from './setlist';

  let {view}: {view: SetListView} = $props();
</script>

<aside class="setlist ofsets" class:dense={view.dense}><ListHead view={view.head} /><nav class="famnav">{#each view.fams as f (f.key)}<button class="famtab {f.own ? 'own' : ''} {f.here ? 'here' : ''}" data-listfam={f.key} data-owngrp={f.own ? f.key : undefined} draggable={f.drag ? 'true' : undefined} aria-current={f.on} title={f.tip}>{@html f.iconHtml}<span>{f.label}</span><small>{f.n}</small></button>{/each}{#if view.newGroupHtml}<div class="famnew">{@html view.newGroupHtml}</div>{/if}</nav>{#if view.title}{@const tt = view.title}<div class="famtitle">{#if tt.editHtml}{@html tt.editHtml}{:else}<h4>{tt.label}</h4>{#each tt.acts as a, i (i)}<button class="ract" {...a.attrs} title={a.tip}>{a.sign}</button>{/each}{/if}</div>{/if}<div class="scroll">{#if view.empty}<div class="empty-list"><MogNote pose="sorry" html={view.empty.html} /></div>{:else}{#each view.entries as e, i (i)}{#if e.k === 'row'}<div class={e.cls} aria-current={e.current} draggable="true" data-rowpath={e.path}><button class="tname" data-pick={e.pick} data-vpick={e.vpick} title={e.title}><b>{e.name}</b></button><span class="rowmarks">{#if e.tried}<i class="rowtry" title={view.triedTitle}></i>{/if}{@html e.marksHtml}</span>{#if e.code !== null}<code>{e.code}</code>{/if}{#if e.vers}<span class="rowvers" role="group" title={view.versTitle}>{#each e.vers as v (v.vpick)}<button data-pick={v.pick} data-vpick={v.vpick} aria-pressed={v.on}>{v.label}</button>{/each}</span>{/if}</div>{@html e.pickerHtml}{:else if e.k === 'famsub'}<p class="famsub">{e.label}</p>{:else if e.k === 'wskill'}<button class="wskill {e.here ? 'here' : ''}" data-wskill={e.key} aria-expanded={e.open}><span>{e.label}</span><span>{e.count}</span></button>{:else if e.k === 'aliasfold'}<button class="aliasfold" data-aliasfold={e.path} aria-expanded={e.open} title={e.title}>{e.label}</button>{:else if e.k === 'alias'}<button class="setrow var alias" data-pick={e.pick} data-vpick={e.vpick} title={e.title}><b>{e.label}</b><code>= {e.of}</code></button>{:else}{@html e.html}{/if}{/each}{/if}{#if view.hidden}<p class="acchid" title={view.hidden.title}>{view.hidden.text} <button class="linkbtn" data-listall>{view.hidden.button}</button></p>{/if}</div>{#if view.optAll}<div class="listfoot"><button class="btn optsetsbtn" data-optsets title={view.optAll.tip}>{view.optAll.label}</button></div>{/if}<i class="listgrip" title={view.grip}></i></aside>
