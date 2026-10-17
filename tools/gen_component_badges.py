"""Generate the corner badges drawn over barrel component icons (heavy / light / gain twist).

    python tools/gen_component_badges.py

Writes Images/Badges/barrel_{heavy,light,improved}.png. Drawn at 4x and downsampled.
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter

SIZE = 48
SS = 4
C = SIZE * SS
CREAM = (232, 224, 196, 255)
BACK = (22, 22, 18, 200)
OUT = os.path.join(os.path.dirname(__file__), "..", "Images", "Badges")


def disc(d):
    m = 2 * SS
    d.ellipse((m, m, C - m, C - m), fill=BACK)


def weight(d):
    # Gym weight: trapezoid body under a ring handle.
    cx = C / 2
    d.ellipse((cx - 24, 34, cx + 24, 82), outline=CREAM, width=12)
    d.polygon([(cx - 36, 72), (cx + 36, 72), (cx + 56, 150), (cx - 56, 150)], fill=CREAM)


def feather(d):
    # Lens-shaped vane leaning right, with the quill cut through it.
    cx, cy, ang = C / 2, C / 2, math.radians(-45)
    pts = []
    for i in range(41):
        t = i / 40
        x = (t - 0.5) * 140
        w = 30 * math.sin(math.pi * t) ** 0.8
        pts.append((x, w))
    pts += [(x, -w) for x, w in reversed(pts)]

    def rot(p):
        x, y = p
        return (cx + x * math.cos(ang) - y * math.sin(ang), cy + x * math.sin(ang) + y * math.cos(ang))

    d.polygon([rot(p) for p in pts], fill=CREAM)
    d.line([rot((-82, 0)), rot((58, 0))], fill=BACK, width=7)
    d.line([rot((-92, 0)), rot((-64, 0))], fill=CREAM, width=8)
    for x in (-20, 22):
        d.polygon([rot((x, 33)), rot((x + 16, 33)), rot((x + 4, 10))], fill=BACK)


def twist(d):
    # Bore seen from the muzzle: three grooves whose turn rate grows outward (gain twist).
    cx = cy = C / 2
    r0, r1 = 20, 66
    d.ellipse((cx - r1 - 6, cy - r1 - 6, cx + r1 + 6, cy + r1 + 6), outline=CREAM, width=10)
    for k in range(3):
        base = k * 2 * math.pi / 3
        pts = []
        for i in range(31):
            t = i / 30
            r = r0 + (r1 - r0) * t
            pts.append((cx + r * math.cos(base + 2.2 * t * t), cy + r * math.sin(base + 2.2 * t * t)))
        d.line(pts, fill=CREAM, width=10, joint="curve")
    d.ellipse((cx - 9, cy - 9, cx + 9, cy + 9), fill=CREAM)


def render(name, glyph):
    img = Image.new("RGBA", (C, C), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    disc(d)
    glyph(d)
    img = img.resize((SIZE, SIZE), Image.LANCZOS)
    os.makedirs(OUT, exist_ok=True)
    img.save(os.path.join(OUT, name + ".png"))


if __name__ == "__main__":
    render("barrel_heavy", weight)
    render("barrel_light", feather)
    render("barrel_improved", twist)
