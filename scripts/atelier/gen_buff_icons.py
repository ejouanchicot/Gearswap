"""Write atelier/app/js/buff_icons.js: the game's status icons of the buffs Buffs & target shows (a song's family, a
roll, a bubble's effect, Protect, Food...), as data URIs so the page needs no file beside it. Source: the 32x32 icons of
AioHUD (addons/AioHUD/assets/buffIcons/<buff id>.png, from XivParty) and Windower's res/buffs.lua for each name's id,
in 64 colours (Pillow).
Re-run after adding a name:
    python scripts/atelier/gen_buff_icons.py
@author ejouanchicot"""
import base64, io, os, re, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
WINDOWER = os.path.normpath(os.path.join(HERE, '..', '..', '..', '..', '..'))
ICONS = os.path.join(WINDOWER, 'addons', 'AioHUD', 'assets', 'buffIcons')
RES = os.path.join(WINDOWER, 'res', 'buffs.lua')
OUT = os.path.join(HERE, '..', '..', 'atelier', 'app', 'js', 'buff_icons.js')

# the names atelier/src/screens/combat/member.ts asks for (buffIconName); every "... Roll" is added
NAMES = ['March', 'Minuet', 'Madrigal', 'Etude', 'Ballad', 'Paeon', 'Prelude', 'Mambo', 'Carol', 'Minne', 'Mazurka', 'Scherzo',
         'Aria', 'Hymnus', 'Threnody', 'Lullaby', 'Nocturne', 'Elegy', 'Requiem',
         'Attack Boost', 'Haste', 'Accuracy Boost', 'Magic Atk. Boost', 'Magic Acc. Boost', 'STR Boost', 'DEX Boost', 'VIT Boost',
         'AGI Boost', 'INT Boost', 'MND Boost', 'CHR Boost', 'Defense Down', 'Evasion Down', 'Magic Def. Down', 'Magic Evasion Down',
         'Defense Boost', 'Refresh', 'Regen', 'Magic Evasion Boost', 'Magic Def. Boost', 'Evasion Boost', 'Attack Down', 'Accuracy Down',
         'Protect', 'Shell', 'Food', 'Aftermath: Lv.3', 'Dia', 'Bio', 'Enfire', 'Phalanx', 'Flurry', 'Auspice', 'Enlight',
         'Soul Voice', 'Clarion Call', 'Marcato', 'Blaze of Glory', 'Ecliptic Attrition', 'Bolster', 'Haste Samba', 'Building Flourish',
         'Saboteur', 'Composure', 'Firestorm', 'Hailstorm', 'Windstorm', 'Sandstorm', 'Thunderstorm', 'Rainstorm', 'Aurorastorm', 'Voidstorm',
         'Warcry', 'Berserk', 'Aggressor', 'Majesty', 'Sentinel', 'Rampart', 'Palisade', 'Defender', 'Enmity Boost', 'Last Resort', 'Hasso', 'Seigan', 'Third Eye', 'Divine Emblem', 'Fealty', 'Endark', 'Souleater', 'Restraint', 'Blood Rage', 'Retaliation', 'Impetus', 'Footwork', 'Boost', 'Focus', 'Dodge', 'Counterstance', 'Swordplay', 'Embolden', 'Vallation', 'Valiance', 'Pflug', 'Battuta', 'Liement', 'Gambit', 'Rayke', 'Saber Dance', 'Fan Dance', 'Climactic Flourish', 'Striking Flourish', 'Ternary Flourish', 'Sneak Attack', 'Trick Attack', 'Feint', 'Conspirator', 'Velocity Shot', 'Sharpshot', 'Barrage', 'Double Shot', 'Triple Shot', 'Innin', 'Yonin', 'Futae', 'Spirit Surge', 'Fly High', 'Diabolic Eye', 'Nether Void', 'Arcane Circle', 'Ancient Circle', 'Holy Circle', 'Warding Circle', 'Meikyo Shisui', 'Sekkanoki', 'Chainspell', 'Manafont', 'Elemental Seal', 'Ebullience', 'Rapture', 'Perpetuance', 'Immanence', 'Overdrive', 'Unleash', 'Killer Instinct', 'Unbridled Learning', 'Diffusion', 'Efflux', 'Burst Affinity', 'Chain Affinity', 'Snake Eye', 'Triple Shot', 'Astral Conduit', 'Entrust', 'Dematerialize', 'Theurgic Focus', 'Lasting Emanation', 'Light Arts', 'Dark Arts', 'slow', 'paralysis', 'weight', 'silence', 'poison']

if not os.path.isdir(ICONS) or not os.path.isfile(RES):
    sys.exit('needs ' + ICONS + ' and ' + RES)
ids = {}
for m in re.finditer(r'\[(\d+)\]\s*=\s*\{id=\d+,en="([^"]+)"', open(RES, encoding='utf-8').read()):
    i, name = int(m.group(1)), m.group(2)
    if name not in ids and os.path.isfile(os.path.join(ICONS, f'{i}.png')):
        ids[name] = i
names = NAMES + sorted(n for n in ids if n.endswith(' Roll'))
out, missing = {}, []
for n in names:
    if n not in ids:
        missing.append(n)
        continue
    # 64 colours, optimized: under 1 KB an icon, from 4 to 13 (the page carries them all)
    buf = io.BytesIO()
    Image.open(os.path.join(ICONS, f'{ids[n]}.png')).convert('RGBA').quantize(colors=64, method=Image.Quantize.FASTOCTREE).save(buf, 'PNG', optimize=True)
    data = buf.getvalue()
    out[n] = 'data:image/png;base64,' + base64.b64encode(data).decode()
lines = ',\n'.join(f'  {n!r}: {v!r}' for n, v in out.items())
text = ("// GearSwap Atelier · buff_icons.js: the game's status icons of the buffs Buffs & target shows, by their name in\n"
        "// Windower's res/buffs.lua (atelier/src/screens/combat/member.ts buffIconName). Written by\n"
        "// scripts/atelier/gen_buff_icons.py from AioHUD's icons: add a name there, never by hand.\n"
        "// (loaded in the order of atelier/src/legacy/files.ts)\n"
        "const BUFF_ICONS = {\n" + lines + "\n};\n")
open(OUT, 'w', encoding='utf-8', newline='\n').write(text)
print('ok', len(out), 'icons,', len(text), 'bytes', ('; missing: ' + ', '.join(missing)) if missing else '')
