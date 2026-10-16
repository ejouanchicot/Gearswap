// Differences every converted character shows on purpose: our shared systems doing
// something his file did by hand or not at all (compare_probes.js reads this list).
module.exports = [
  {label: '^(spell|ws):', line: "waist: .*(Orpheus's Sash|Hachirin-no-Obi)",
    why: "Obi / Orpheus: our system computes both bonuses (day, weather, distance) and keeps the set's belt when neither wins (shared/utils/equipment/elemental_belt)"},
  {label: "Roll", line: "ring: .* -> Luzaf's Ring",
    why: "Phantom Roll: our COR wears Luzaf's Ring for the larger area"},
  {label: '^spell:(Cure|Curaga)', line: 'Target full HP',
    why: 'Cure tier: our CureManager casts the tier the missing HP needs (a full target here gets the lowest)'},
  {label: '^spell:Phalanx II', line: 'Downgrading Phalanx II',
    why: 'Phalanx II on yourself: our RDM casts Phalanx (stronger on self)'},
  {label: ' \\+Silence$', line: '.',
    why: 'silenced: our PrecastGuard stops the spell (and uses Echo Drops / Remedy when you carry them); his GearSwap sent it and changed gear for nothing'},
  {label: '^spell:', line: 'Downgrading',
    why: 'spell tier: our TierRefiner casts a lower tier when MP or the recast does not allow the one asked'},
  {label: '^spell:', line: 'blm_functions\.lua',
    why: 'BLM with /SCH: our BLM puts Dark Arts up before a nuke (auto option blm_dark_arts, on by default), then casts the nuke'},
  {label: '^spell:Impact', line: '^mid body: .* -> Crepuscular Cloak',
    why: 'Impact: our system keeps the cloak Impact needs on; his rule (Spaekona body under 500 MP) took it off and the spell failed'},
  {label: '^spell:Dispelga', line: 'main: .* -> Daybreak',
    why: 'Dispelga: our system holds Daybreak for the cast (the spell needs it)'},
];
