"""Per-shot drift pips for the aCTH RECOIL window (UI_aperture_breakdown.lua, Rat_ACTHRecoilPopulate).

One pip per round: green while the muzzle is well inside the target, amber near its edge, red past it.
Same height as the hint bar segments (gen_hint_bars.py) so both read as one family. Colours are the
ends and middle of Rat_QualityColor. The game caches images by path: restart after regenerating.

    python tools/gen_recoil_pips.py
"""
import os

from PIL import Image

W, H, GAP = 12, 20, 4
COLORS = {"g": (126, 186, 108), "a": (216, 172, 76), "r": (214, 96, 82)}

out = os.path.join(os.path.dirname(__file__), "..", "Images", "RecoilPip")
os.makedirs(out, exist_ok=True)
for name, c in COLORS.items():
    im = Image.new("RGBA", (W + GAP, H), (0, 0, 0, 0))
    for x in range(W):
        for y in range(H):
            im.putpixel((x, y), c + (255,))
    im.save(os.path.join(out, name + ".png"))
print(f"wrote {len(COLORS)} pips to Images/RecoilPip")
