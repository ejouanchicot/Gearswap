<!--
  GearSwap Atelier · the played jobs on the left of a tab (the job's settings...): by master level then by role, the
  shown one marked; a click changes job and keeps the tab (the old page's handler: events.js data-jobkeep).
  It was the old page's jobListHTML (sets_view.js).

  @file    atelier/src/screens/config/JobList.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';

  interface Row { job: string; name: string; role: string; dim: boolean; current: boolean; title: string; emblem: string; badge: string }
  interface Group { key: string; label: string; count: number; role: string | null; master: boolean; rows: Row[] }

  // read again at each redraw of the old page: the shown job, the master levels of a new export, the language
  const groups = $derived.by((): Group[] => {
    legacy.version;
    const row = ([job, name, role]: [string, string, string], dim: boolean): Row => ({job, name, role, dim, current: S.job === job,
      title: t(dim ? 'ttJobRowNo' : 'ttJobRow', {j: name}), emblem: emblem(job), badge: jobBadge(job)});
    const all = jobGroups();
    if (all[0] && all[0].label === null) {
      const jobs = all[0].jobs;
      return ROLES.map(r => ({key: r, label: t('roles.' + r), role: r, master: false, rows: jobs.filter(j => j[2] === r).map(j => row(j, false))}))
        .filter(g => g.rows.length).map(g => ({...g, count: g.rows.length}));
    }
    return all.map(g => ({key: g.label || '', label: g.label || '', role: null, master: !!g.master, count: g.jobs.length, rows: g.jobs.map(j => row(j, !g.master))}));
  });
</script>

<aside class="setlist joblist"><div class="scroll">
  {#each groups as g (g.key)}
    <div class="fam static" class:mastergrp={g.master} style:--role={g.role ? ROLE_COLOR[g.role] : null}><span>{g.label}</span><span>{g.count}</span></div>
    {#each g.rows as r (r.job)}
      <button class="setrow jobrow" class:dim={r.dim} data-jobkeep={r.job} aria-current={r.current} style:--role={ROLE_COLOR[r.role]} title={r.title}>{@html r.emblem}<b>{r.job}</b><small>{r.name}</small>{@html r.badge}</button>
    {/each}
  {/each}
</div></aside>
