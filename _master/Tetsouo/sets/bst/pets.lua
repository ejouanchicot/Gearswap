---  ═══════════════════════════════════════════════════════════════════════════
---   BST Pets - Jug Pet Broth Set Definitions (25 pets)
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry maps a jug pet name to the corresponding broth ammo. Matches
---   BST_PET_DATA.lua. Loaded into the global `sets` table at job startup:
---
---     for name, pet_set in pairs(Pets) do
---         sets[name] = pet_set
---     end
---
---   @file    Tetsouo/sets/bst/pets.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Pets = {}

Pets['Amiable Roche (Fish)']         = {ammo = 'Airy Broth'}
Pets['Jovial Edwin (Crab)']          = {ammo = 'Pungent Broth'}
Pets['Fluffy Bredo (Acuex)']         = {ammo = 'Venomous Broth'}
Pets['Sultry Patrice (Slime)']       = {ammo = 'Putrescent Broth'}
Pets['Fatso Fargann (Leech)']        = {ammo = 'C. Plasma Broth'}
Pets['Generous Arthur (Slug)']       = {ammo = 'Dire Broth'}
Pets['Blackbeard Randy (Tiger)']     = {ammo = 'Meaty Broth'}
Pets['Rhyming Shizuna (Sheep)']      = {ammo = 'Lyrical Broth'}
Pets['Pondering Peter (Rabbit)']     = {ammo = 'Vis. Broth'}
Pets['Vivacious Vickie (Raaz)']      = {ammo = 'Tant. Broth'}
Pets['Choral Leera (Colibri)']       = {ammo = 'Glazed Broth'}
Pets['Daring Roland (Hippogryph)']   = {ammo = 'Feculent Broth'}
Pets['Swooping Zhivago (Tulfaire)']  = {ammo = 'Windy Greens'}
Pets['Warlike Patrick (Lizard)']     = {ammo = 'Livid Broth'}
Pets['Suspicious Alice (Eft)']       = {ammo = 'Furious Broth'}
Pets['Brainy Waluis (Funguar)']      = {ammo = 'Crumbly Soil'}
Pets['Sweet Caroline (Mandragora)']  = {ammo = 'Aged Humus'}
Pets['Bouncing Bertha (Chapuli)']    = {ammo = 'Bubbly Broth'}
Pets['Threestar Lynn (Ladybug)']     = {ammo = 'Muddy Broth'}
Pets['Headbreaker Ken (Fly)']        = {ammo = 'Blackwater Broth'}
Pets['Energized Sefina (Beetle)']    = {ammo = 'Gassy Sap'}
Pets['Anklebiter Jedd (Diremite)']   = {ammo = 'Crackling Broth'}
Pets['Left-Handed Yoko (Mosquito)']  = {ammo = 'Heavenly Broth'}
Pets['Cursed Annabelle (Antlion)']   = {ammo = 'Creepy Broth'}
Pets['Weevil Familiar (Weevil)']     = {ammo = 'T. Pristine Sap'}

return Pets
