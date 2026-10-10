"""One more glove, from the Gemini sheet on a green ground (Img/cursor/Gemini_..._i3o0...jfif): the diagonal pointer
with its finger bent (up_press), the mouse pointer while a button is held. Run from atelier/."""
import glob
import os

from PIL import Image

src = [f for f in glob.glob('Img/cursor/Gemini*i3o0*')][0]
im = Image.open(src).convert('RGB')
w, h = im.size
# where each one is on the sheet (a wide box around it; the glove's own outline is found inside)
AREAS = {'up_press': (130, 1340, 680, 1990)}


def keyed(region):
    """The green ground made transparent, its tint taken off the soft edge."""
    out = Image.new('RGBA', region.size)
    src_px, dst = region.load(), out.load()
    for y in range(region.height):
        for x in range(region.width):
            r, g, b = src_px[x, y]
            green = g - max(r, b)
            a = 255 if green <= 24 else 0 if green >= 96 else int(255 * (96 - green) / 72)
            dst[x, y] = (r, min(g, max(r, b)), b, a)
    return out


os.makedirs('app/img/cursor', exist_ok=True)
for name, box in AREAS.items():
    g = keyed(im.crop(box))
    g = g.crop(g.split()[3].point(lambda v: 255 if v > 40 else 0).getbbox())
    g.save(f'Img/cursor/{name}.png')
    small = g.copy()
    small.thumbnail((160, 160), Image.LANCZOS)
    small.save(f'app/img/cursor/{name}.webp', 'WEBP', quality=90, method=6)
    print(name, g.size)
sheet = Image.new('RGB', (len(AREAS) * 170, 170), (16, 30, 70))
for i, n in enumerate(AREAS):
    s = Image.open(f'app/img/cursor/{n}.webp')
    sheet.paste(s, (i * 170 + 5, 5), s)
sheet.save(os.path.join(os.environ.get('SHEET_DIR', '.'), 'gloves2.png'))
