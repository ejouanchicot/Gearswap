"""Cut atelier/Img/cursor/Cursor.png (a sheet of 8 gloves on a transparent ground) into one image a glove, and write
the small copies the page uses (app/img/cursor/) and its mouse pointers (app/css/cursor.css). Run from atelier/,
after cursor_gloves_extra.py: python ../scripts/atelier/cursor_gloves.py"""
import base64
import glob
import io
import os
import re

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SRC = 'Img/cursor/Cursor.png'
# the gloves in reading order (top to bottom, left to right)
NAMES = ['point', 'press', 'open', 'fist', None, 'up', 'stop', 'thumb']   # None: the sheet's second fist, the same as the first

im = Image.open(SRC).convert('RGBA')
w, h = im.size
alpha = im.split()[3]
mask = alpha.point(lambda v: 255 if v > 24 else 0)


def spans(profile, gap=18):
    """Runs of non-empty columns or rows, split where `gap` empty ones follow each other."""
    out, start, empty = [], None, 0
    for i, v in enumerate(profile):
        if v:
            if start is None:
                start = i
            empty = 0
        elif start is not None:
            empty += 1
            if empty >= gap:
                out.append((start, i - empty + 1))
                start = None
    if start is not None:
        out.append((start, len(profile)))
    return out


px = mask.load()
rows = spans([any(px[x, y] for x in range(0, w, 3)) for y in range(h)])
boxes = []
for top, bottom in rows:
    band = mask.crop((0, top, w, bottom))
    bp = band.load()
    for left, right in spans([any(bp[x, y] for y in range(0, bottom - top, 3)) for x in range(w)]):
        box = mask.crop((left, top, right, bottom)).getbbox()
        boxes.append((left + box[0], top + box[1], left + box[2], top + box[3]))
print(len(boxes), 'gloves', boxes)
assert len(boxes) == len(NAMES)


def clean(glove):
    """The green of the sheet's first ground left on the soft edge: taken out of it."""
    r, g, b, a = glove.split()
    rp, gp, bp = r.load(), g.load(), b.load()
    for y in range(glove.height):
        for x in range(glove.width):
            top = max(rp[x, y], bp[x, y])
            if gp[x, y] > top + 12:
                gp[x, y] = top
    return Image.merge('RGBA', (r, g, b, a))


os.makedirs('app/img/cursor', exist_ok=True)
gloves = {}
for name, box in zip(NAMES, boxes):
    if not name:
        continue
    g = clean(im.crop(box))
    g.save(f'Img/cursor/{name}.png')
    gloves[name] = g
    small = g.copy()
    small.thumbnail((160, 160), Image.LANCZOS)
    small.save(f'app/img/cursor/{name}.webp', 'WEBP', quality=90, method=6)
    print(name, g.size, os.path.getsize(f'app/img/cursor/{name}.webp'))


def pointer(glove, size, flip=False, rotate=0):
    """A mouse pointer: the glove on a square of `size`, as a PNG data URI (a .png file is ignored by the repository)."""
    g = glove.transpose(Image.FLIP_LEFT_RIGHT) if flip else glove
    if rotate:
        g = g.rotate(rotate, expand=True, resample=Image.BICUBIC)
        g = g.crop(g.getbbox())
    g = g.copy()
    g.thumbnail((size, size), Image.LANCZOS)
    g = g.filter(ImageFilter.UnsharpMask(radius=1, percent=60, threshold=0))
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.paste(g, (0, 0), g)
    buf = io.BytesIO()
    out.save(buf, 'PNG', optimize=True)
    return 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode(), g.size


def uri(image):
    buf = io.BytesIO()
    image.save(buf, 'PNG', optimize=True)
    return 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()


def help_pointer(glove, size):
    """The pointer over what has a tooltip: the same glove, a gold question mark in a round badge at its side.
    Drawn four times too big then brought down, for clean edges."""
    k = 4
    g = glove.transpose(Image.FLIP_LEFT_RIGHT).copy()
    g.thumbnail((size * k, size * k), Image.LANCZOS)
    d = 17 * k
    out = Image.new('RGBA', (g.width + d * 2 // 3, max(g.height, g.height * 2 // 3 + d)), (0, 0, 0, 0))
    out.paste(g, (0, 0), g)
    x, y = out.width - d - k, out.height - d - k
    draw = ImageDraw.Draw(out)
    draw.ellipse((x, y, x + d, y + d), fill=(255, 224, 138, 255), outline=(42, 29, 18, 255), width=2 * k)
    try:
        font = ImageFont.truetype('arialbd.ttf', 13 * k)
    except OSError:
        font = ImageFont.load_default()
    draw.text((x + d / 2, y + d / 2 + k / 2), '?', font=font, fill=(42, 29, 18, 255), anchor='mm')
    out = out.resize((out.width // k, out.height // k), Image.LANCZOS)
    return uri(out)


def help_selectors():
    """Where the page asks for the tooltip pointer (cursor:help in its sheets): the badge glove goes there, so a rule
    added to the page later is followed when this script is run again."""
    found = []
    for f in sorted(glob.glob('app/css/*.css')):
        if f.replace(os.sep, '/').endswith('/cursor.css'):
            continue
        for sel in re.findall(r'([^{}]+)\{[^{}]*cursor:help', open(f, encoding='utf-8').read()):
            sel = re.sub(r'/\*.*?\*/', '', sel, flags=re.S).strip()
            found += [x.strip() for x in sel.split(',') if x.strip()]
    # and everything that carries a tooltip without being a control one clicks (tips.js moves a title to data-tip
    # the first time the pointer comes over it): the question mark says "there is something to read here"
    controls = 'button,a,select,input,textarea,summary,label,option,[role="tab"],.btn,.chip,.slot,.setrow,.opt,.live'
    return sorted(set(found)) + [f':is([title],[data-tip]):not({controls})']


# the mouse pointers, their hot spot at the fingertip (top left of the square once the glove is turned)
css = ['/* GearSwap Atelier · cursor.css: the mouse pointer, a white cartoon glove (written by scripts/atelier/cursor_gloves.py from',
       '   atelier/Img/cursor/Cursor.png; the images are inside this sheet because the repository ignores .png files).',
       '   Vana\'diel and Grimoire themes only; a text field keeps its own pointer. */']
arrow, _ = pointer(gloves['up'], 36, flip=True)
press, _ = pointer(Image.open('Img/cursor/up_press.png').convert('RGBA'), 34, flip=True)   # cut by cursor_gloves_extra.py (run it first)
stop, sz = pointer(gloves['stop'], 34)
fist, fz = pointer(gloves['fist'], 32)
openh, oz = pointer(gloves['open'], 34)
sel = ':root:is([data-theme="vanadiel"],[data-theme="grimoire"])'
# !important: the glove also where the page asks for the system's own pointers (the hand, the arrow with a question
# mark of a tooltip, the default arrow)
css.append(f'{sel},{sel} *{{cursor:url({arrow}) 2 2,auto !important}}')
css.append(f'{sel}:active,{sel} *:active{{cursor:url({press}) 3 3,auto !important}}')
helps = help_selectors()
print('tooltip pointer on:', helps)
css.append(f'{sel} :is({",".join(helps)}),{sel} :is({",".join(helps)}) :not(button,a,select,input,textarea,.btn,.chip){{cursor:url({help_pointer(gloves["up"], 34)}) 2 2,help !important}}')
css.append(f'{sel} :is(:disabled,[disabled],[aria-disabled="true"]){{cursor:url({stop}) {sz[0] // 2} {sz[1] // 2},not-allowed !important}}')
css.append(f'{sel} [draggable="true"]{{cursor:url({openh}) {oz[0] // 2} {oz[1] // 2},grab !important}}')
css.append(f'{sel} [draggable="true"]:active{{cursor:url({fist}) {fz[0] // 2} {fz[1] // 2},grabbing !important}}')
css.append(f'{sel} :is(input:not([type="checkbox"],[type="radio"],[type="range"]),textarea):not(:disabled){{cursor:text !important}}')
# the finger bent while a mouse button is held, over every rule above
# (the class is put by app/js/tips.js)
heavy = '.pressing' * 4   # the class counted four times: heavier than the longest rule above
css.append(f'{sel}{heavy},{sel}{heavy} *:not(:disabled,[disabled]){{cursor:url({press}) 3 3,auto !important}}')
open('app/css/cursor.css', 'w', encoding='utf-8', newline='\n').write('\n'.join(css) + '\n')
print('cursor.css', os.path.getsize('app/css/cursor.css'))

# a check sheet
sheet = Image.new('RGB', (8 * 170, 170), (16, 30, 70))
for i, n in enumerate(x for x in NAMES if x):
    s = Image.open(f'app/img/cursor/{n}.webp')
    sheet.paste(s, (i * 170 + 5, 5), s)
sheet.save(os.path.join(os.environ.get('SHEET_DIR', '.'), 'gloves.png'))
