# Job and subjob changes

What happens when you change job, and why you rarely need to do anything.

## Main job change

GearSwap itself loads the new job's file (`<YourName>_<JOB>.lua`). The old
file removes its keys; the new one sets its keys, HUD, macro book (about
1.5 s later) and lockstyle (8 s later).

## Subjob change

The job file stays loaded, but the setup reloads it 0.5 s later (a full
`gs reload`) so every system starts clean for the new subjob. Before the
reload it stops movement tracking, the midcast watchdog and the HUD.

Several changes in quick succession give **one** reload, for the last one.
A back-and-forth (WAR/SAM to WAR/DNC and back) still reloads. When the main
job also differs, the wait is 3.0 s instead of 0.5 s.

## Wrong job file

GearSwap picks the job file from your job-change request, not from the
server's answer. If the two ever disagree (refused or reordered change), a
check every 5 seconds notices the mismatch and reloads the right file after
two confirmations.

## What survives a load

- Every mode goes back to its default, except Auto Medicine.
- Your keys, the HUD position and the settings in `config/` are read again.
- A slot locked by Doom, craft, the wardrobe organizer or a warp ring stays
  locked across the load; the matching command releases it
  (`//gs c uncraft`, `//gs c wo recover`, `//gs c warp fix`).

## Troubleshooting

| Symptom | Try |
|---|---|
| Keys dead after a change | Wait a few seconds (the job's keys are sent again 2 s after each load), then `//gs c reload` |
| HUD shown twice or stale | `//gs c ui` twice, or `//gs c reload` |
| Lockstyle applied several times | Harmless after quick changes |
| Still wrong | `//lua reload gearswap` |

`//gs c debugjobchange` prints what the job-change system does, for a bug
report.
