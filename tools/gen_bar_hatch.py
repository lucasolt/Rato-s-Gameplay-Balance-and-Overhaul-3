"""Hatch tiles for the "removed" span of the weapon hint bars (DESCRIPTION_HINTS_get.lua, HintBarHatch).

The game tints each tile by multiplying every pixel with the colour in HintBarColors
(worse_removed / better_removed). So a white pixel becomes exactly that colour, a grey pixel a darker
shade of it, and alpha is kept as is (it shows whatever is behind the tooltip, which varies by panel).

Tiles are 4px x 20px slices of one PERIOD-wide diagonal; the code picks slice (unit % SLICES), so the
period must be a multiple of 4. The engine caches textures by path: after regenerating, either restart
the game or use a new --prefix and set HintBarHatchImg to it.

    python tools/gen_bar_hatch.py --stripe 6 --off 170
"""
import argparse
import os

from PIL import Image

ap = argparse.ArgumentParser()
ap.add_argument("--period", type=int, default=16, help="px between stripes (multiple of 4)")
ap.add_argument("--stripe", type=int, default=6, help="px of each stripe, the rest is gap")
ap.add_argument("--on", type=int, default=255, help="stripe brightness 0-255 (255 = the tint colour itself)")
ap.add_argument("--off", type=int, default=170, help="gap brightness 0-255 (0 = black, 255 = same as the stripe)")
ap.add_argument("--off-alpha", type=int, default=255, help="gap opacity 0-255 (0 = see-through)")
ap.add_argument("--slope", type=int, default=1, help="1 = 45 degrees, 2 = steeper, -1 = mirrored")
ap.add_argument("--prefix", default="s", help="file prefix; must match HintBarHatchImg in the Lua")
a = ap.parse_args()
assert a.period % 4 == 0, "period must be a multiple of the 4px tile"

out = os.path.join(os.path.dirname(__file__), "..", "Images", "StatBar")
for k in range(a.period // 4):
    im = Image.new("RGBA", (4, 20))
    for y in range(20):
        for x in range(4):
            on = (4 * k + x + a.slope * y) % a.period < a.stripe
            im.putpixel((x, y), (a.on,) * 3 + (255,) if on else (a.off,) * 3 + (a.off_alpha,))
    im.save(os.path.join(out, f"{a.prefix}{k}.png"))
print(f"wrote {a.prefix}0..{a.prefix}{a.period // 4 - 1}; slices = {a.period // 4}")
