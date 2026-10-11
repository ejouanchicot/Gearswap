"""The moogle's animated poses for the Atelier page, as sprite sheets.

Four drawings a pose (atelier/Img/moogle/<folder>/, kept on this PC only) are put side by side in one image,
atelier/app/img/mog/<pose>.webp: the page shows one frame at a time (moogle.css .mogspr).

  idle   it flies in its corner            Idle/                 frames 1 2 3 4 (the wings go down then up)
  sleep  nobody touched the page a while   Sleep/                frames 1 2 3 4 (it breathes)
  sorry  something failed or was not found Mog_desole_4_poses/   sorry, head down, eyes closed, head down
  carry  gear goes into your files         Moogle_Items/         frames 4 1 2 3 (it holds, lifts, hops)

A frame keeps its place in the drawing's canvas, so the moogle does not jump from a frame to the next.
Run from data/ when a drawing changes:  python scripts/atelier/mog_sprites.py

@author ejouanchicot
"""
import glob
import os
import re
import sys

from PIL import Image

DATA = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SRC = os.path.join(DATA, 'atelier', 'Img', 'moogle')
OUT = os.path.join(DATA, 'atelier', 'app', 'img', 'mog')
FRAME = 300

# pose -> (folder, the frames in order: the number that ends or starts each file's name)
POSES = {
    'idle': ('Idle', [1, 2, 3, 4]),
    'sleep': ('Sleep', [1, 2, 3, 4]),
    'sorry': ('Mog_desole_4_poses', [1, 3, 4, 3]),
    'carry': ('Moogle_Items', [4, 1, 2, 3]),
}


def number_of(path):
    """The frame number in a file's name: "01_mog_desole.png" -> 1, "... en plein vol-1.png" -> 1."""
    name = os.path.splitext(os.path.basename(path))[0]
    found = re.match(r'(\d+)_', name) or re.search(r'-(\d+)$', name)
    return int(found.group(1)) if found else None


def build(pose, folder, order):
    by_number = {number_of(p): p for p in glob.glob(os.path.join(SRC, folder, '*.png'))}
    missing = [n for n in order if n not in by_number]
    if missing:
        sys.exit('%s: no drawing numbered %s in %s' % (pose, missing, folder))
    sheet = Image.new('RGBA', (FRAME * len(order), FRAME), (0, 0, 0, 0))
    for i, n in enumerate(order):
        frame = Image.open(by_number[n]).convert('RGBA').resize((FRAME, FRAME), Image.LANCZOS)
        sheet.alpha_composite(frame, (i * FRAME, 0))
    out = os.path.join(OUT, pose + '.webp')
    sheet.save(out, 'WEBP', quality=82, method=6)
    print('%-6s %d frames -> %s (%d KB)' % (pose, len(order), os.path.relpath(out, DATA), os.path.getsize(out) // 1024))


def main():
    if not os.path.isdir(SRC):
        sys.exit('the drawings are not here: ' + SRC)
    for pose, (folder, order) in POSES.items():
        build(pose, folder, order)


if __name__ == '__main__':
    main()
