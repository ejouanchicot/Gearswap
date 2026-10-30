"""Write atelier/app/js/game_icons.js: the game-icons.net icons the options screen uses, as SVG bodies (no network at
run time). Source: the npm package @iconify-json/game-icons (CC BY 3.0, game-icons.net). Re-run after adding a name:
    npm pack @iconify-json/game-icons && tar -xzf iconify-json-game-icons-*.tgz   (in a scratch folder)
    GI_PACKAGE=<that folder>/package python scripts/atelier/gen_game_icons.py
@author ejouanchicot"""
import json, os, sys
SRC = os.environ.get('GI_PACKAGE') or sys.exit('GI_PACKAGE: the unpacked package folder of @iconify-json/game-icons')
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'atelier', 'app', 'js', 'game_icons.js')
NAMES = ['checked-shield', 'magic-potion', 'heart-plus', 'meditation', 'heart-bottle', 'angel-wings', 'sunbeams', 'on-target',
         'crossed-swords', 'silenced', 'padlock', 'open-treasure-chest', 'jump-across', 'sprint', 'shield', 'magic-shield',
         'hourglass', 'gamepad', 'keyboard', 'cycle', 'cog',
         'shield-reflect', 'sword-brandish', 'bullseye', 'invisible', 'rune-stone', 'upgrade', 'rolling-dices', 'dice-six-faces-six',
         'revolver', 'ring', 'crystal-ball', 'orb-wand', 'sun', 'moon', 'stairs-goal', 'magic-portal', 'poison-bottle', 'lightning-helix',
         'magic-palm', 'fire-ray', 'muscle-up', 'spiked-shell', 'tornado', 'magic-swirl', 'spell-book', 'open-book', 'chest-armor', 'bookmark',
         'gears', 'armor-vest', 'tied-scroll', 'backpack', 'tv', 'two-shadows', 'plug', 'belt', 'chat-bubble', 'gear-hammer', 'standing-potion']
icons = json.load(open(os.path.join(SRC, 'icons.json'), encoding='utf-8'))
info = json.load(open(os.path.join(SRC, 'info.json'), encoding='utf-8'))
size = icons.get('width', 512)
out = {}
for n in NAMES:
    if n not in icons['icons']:
        sys.exit('missing ' + n)
    out[n] = icons['icons'][n]['body']
authors = info.get('author', {}).get('name', 'game-icons.net')
text = ("// GearSwap Atelier · game_icons.js: the icons of the options screen (Configuration), from game-icons.net\n"
        f"// ({authors}, {info['license']['title']}: {info['license']['url']}), copied from the npm package\n"
        "// @iconify-json/game-icons so the page needs no network. Written by a script: add a name there, never by hand.\n"
        "// (loaded after player_words.js: see atelier/src/legacy/files.ts)\n"
        f"const GAME_ICONS = {{size: {size}, credit: 'game-icons.net (CC BY 3.0)', icons: " + json.dumps(out, ensure_ascii=False) + "};\n")
open(OUT, 'w', encoding='utf-8', newline='\n').write(text)
print('ok', len(out), 'icons,', len(text), 'bytes')
