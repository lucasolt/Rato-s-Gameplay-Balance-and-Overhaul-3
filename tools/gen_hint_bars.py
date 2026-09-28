"""Segment images for the weapon hint bars (DESCRIPTION_HINTS_get.lua, HintBar).

A bar is always 4 segments + 3 dividers. XText truncates every <image> to whole pixels on its own, so a
fixed image count keeps every row the same width at any UI scale (the PDA draws at a different one).

Each segment is SEG units of UNIT px: `fill` units of the stat, then `gap` units of the owner-vs-gun
span, then empty. Files: b{fill}_{gap}.png, and b{fill}_{gap}_{w|b}{s|h}.png when gap > 0
(w = worse / b = better, s = solid: the owner raises the value, h = hatched: the owner lowers it).

Every colour and the hatch live here; the Lua only picks file names. The game caches images by path:
restart it after regenerating, or write to a new --dir and point HintBarImg at it.

    python tools/gen_hint_bars.py --period 22 --stripe 7 --off 170
"""
import argparse
import os

from PIL import Image

SEG, UNIT, H = 10, 4, 20
PITCH = (SEG + 1) * UNIT  # segment + divider: the hatch period must divide it so stripes line up across dividers

FILL = (195, 189, 172)
EMPTY = (56, 57, 63)
DIVIDER = (12, 12, 12)
SOLID = {"w": (191, 67, 77), "b": (124, 130, 96)}  # sampled from vanilla weapon_meter _red / _green
REMOVED = {"w": (215, 110, 118), "b": (165, 185, 115)}

ap = argparse.ArgumentParser()
ap.add_argument("--period", type=int, default=22, help=f"px between stripes; must divide {PITCH}")
ap.add_argument("--stripe", type=int, default=7, help="px of each stripe, the rest is gap")
ap.add_argument("--off", type=int, default=170, help="hatch gap brightness vs the stripe, 0-255")
ap.add_argument("--slope", type=int, default=1, help="1 = 45 degrees, 2 = steeper, -1 = mirrored")
ap.add_argument("--dir", default="HintBar", help="folder under Images/; must match HintBarImg in the Lua")
a = ap.parse_args()
assert PITCH % a.period == 0, f"period must divide {PITCH} (e.g. 11, 22, 44)"

out = os.path.join(os.path.dirname(__file__), "..", "Images", a.dir)
os.makedirs(out, exist_ok=True)


def shade(c, k):
    return tuple(v * k // 255 for v in c)


def segment(fill, gap, kind):
    im = Image.new("RGBA", (SEG * UNIT, H))
    for x in range(SEG * UNIT):
        unit = x // UNIT
        for y in range(H):
            if unit < fill:
                c = FILL
            elif unit < fill + gap:
                if kind[1] == "h":
                    on = (x + a.slope * y) % a.period < a.stripe
                    c = REMOVED[kind[0]] if on else shade(REMOVED[kind[0]], a.off)
                else:
                    c = SOLID[kind[0]]
            else:
                c = EMPTY
            im.putpixel((x, y), c + (255,))
    return im


n = 0
for fill in range(SEG + 1):
    for gap in range(SEG + 1 - fill):
        for kind in (["ws", "wh", "bs", "bh"] if gap else [None]):
            name = f"b{fill}_{gap}" + (f"_{kind}" if kind else "")
            segment(fill, gap, kind or "  ").save(os.path.join(out, name + ".png"))
            n += 1
Image.new("RGBA", (UNIT, H), DIVIDER + (255,)).save(os.path.join(out, "div.png"))
# rows without a bar keep their text aligned with the barred ones
Image.new("RGBA", (4 * SEG * UNIT + 3 * UNIT, H), (0, 0, 0, 0)).save(os.path.join(out, "blank.png"))
print(f"wrote {n} segments + div + blank to Images/{a.dir}")
