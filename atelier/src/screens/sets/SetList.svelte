<!--
  GearSwap Atelier · the list of the job's sets on the left (setlist.ts), for the Sets screen, Buffs & target and My
  character's stats. The rows keep the attributes the old page's handlers read (events.js data-pick / data-vpick,
  data-wskill, data-aliasfold, data-listall; list_prefs.js the drag of data-rowpath rows, the row actions, the
  categories' heads), and the list is resized by its grip (list_prefs.js listgrip).

  @file    atelier/src/screens/sets/SetList.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import MogNote from '../../components/MogNote.svelte';
  import ListHead from './ListHead.svelte';
  import type {SetListView} from './setlist';

  let {view}: {view: SetListView} = $props();
</script>

<aside class="setlist ofsets"><ListHead view={view.head} /><div class="scroll">{@html view.ownHtml}{#if view.empty}<div class="empty-list"><MogNote pose="sorry" html={view.empty.html} /></div>{:else}{#each view.entries as e, i (i)}{#if e.k === 'row'}<div class={e.cls} aria-current={e.current} draggable="true" data-rowpath={e.path}><button class="tname" data-pick={e.pick} data-vpick={e.vpick} title={e.title}><b>{e.name}</b></button><span class="rowmarks">{#if e.ver}<small class="rowver">{e.ver}</small>{/if}{#if e.tried}<i class="rowtry" title={view.triedTitle}></i>{/if}{@html e.marksHtml}</span>{#if e.code !== null}<code>{e.code}</code>{/if}</div>{@html e.pickerHtml}{:else if e.k === 'wskill'}<button class="wskill {e.here ? 'here' : ''}" data-wskill={e.key} aria-expanded={e.open}><span>{e.label}</span><span>{e.count}</span></button>{:else if e.k === 'aliasfold'}<button class="aliasfold" data-aliasfold={e.path} aria-expanded={e.open} title={e.title}>{e.label}</button>{:else if e.k === 'alias'}<button class="setrow var alias" data-pick={e.pick} data-vpick={e.vpick} title={e.title}><b>{e.label}</b><code>= {e.of}</code></button>{:else}{@html e.html}{/if}{/each}{/if}{#if view.hidden}<p class="acchid" title={view.hidden.title}>{view.hidden.text} <button class="linkbtn" data-listall>{view.hidden.button}</button></p>{/if}</div><i class="listgrip" title={view.grip}></i></aside>
