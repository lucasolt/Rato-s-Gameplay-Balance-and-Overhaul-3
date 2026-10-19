"""Settled status icon: the Sharpshooter perk rifle resting on a ground bar, in the vanilla status-effect style.

Vanilla status icons (UI/Hud/Status effects/*.dds) are 40x40 RGBA: flat fill (buffs 194,185,130) and a
near-black 1px outline. The rifle silhouette comes from the vanilla perk icon, which is not shipped here:
extract it first through dap_eval (AsyncFileToString("UI/Icons/Perks/Instagib.dds") -> AsyncStringToFile).

    python tools/gen_status_icon_settled.py <Instagib.dds> [out.png] [--detail]
"""
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

SIZE = 40
S = 8
FILL = np.array((194, 185, 130), float)
OUTLINE = (36, 36, 36)
RIFLE_BOX = 35.5        # rifle bbox side, icon px
BAR_Y = (36.0, 38.5)    # ground bar top/bottom
BOLD = 0.15             # px the silhouette is thickened by, so it holds up at 40px
BAR_X = (1.5, 38.5)
GAP = 1.0               # dark gap between rifle and bar


def rifle_layers(src):
    """Silhouette and the perk's own dark part lines, supersampled."""
    im = Image.open(src).convert("RGBA")
    a = np.array(im).astype(float)
    ys, xs = np.nonzero(a[..., 3] > 128)
    a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    k = RIFLE_BOX * S / max(a.shape[:2])
    size = (round(a.shape[1] * k), round(a.shape[0] * k))
    alpha = np.array(Image.fromarray(a[..., 3].astype(np.uint8)).resize(size, Image.BICUBIC)).astype(float)
    # the 68px source is stair-stepped; blur before thresholding so the edges come out straight
    alpha = ndimage.gaussian_filter(alpha, 0.3 * S) > 128
    alpha = ndimage.distance_transform_edt(~alpha) <= BOLD * S
    luma = a[..., :3] @ np.array([0.299, 0.587, 0.114])
    dark = np.where(a[..., 3] > 128, luma < 70, False).astype(np.uint8) * 255
    dark = np.array(Image.fromarray(dark).resize(size, Image.BICUBIC)) > 128
    return alpha, dark & alpha


def main(src, out_path, detail):
    W = SIZE * S
    rifle, lines = rifle_layers(src)
    h, w = rifle.shape
    # butt sits on the bar, muzzle toward the top-right corner
    x0 = round((SIZE - 1.6) * S - w)
    y0 = round((BAR_Y[0] - GAP - 0.4) * S - h)
    canvas = np.zeros((W, W), bool)
    detail_m = np.zeros((W, W), bool)
    cy0, cx0 = max(0, y0), max(0, x0)
    canvas[cy0:y0 + h, cx0:x0 + w] = rifle[cy0 - y0:, cx0 - x0:][:W - cy0, :W - cx0]
    detail_m[cy0:y0 + h, cx0:x0 + w] = lines[cy0 - y0:, cx0 - x0:][:W - cy0, :W - cx0]

    bar = np.zeros((W, W), bool)
    bar[int(BAR_Y[0] * S):int(BAR_Y[1] * S), int(BAR_X[0] * S):int(BAR_X[1] * S)] = True
    bar &= ndimage.distance_transform_edt(~canvas) > GAP * S

    shape = canvas | bar
    ys = np.arange(W)[:, None, None] / W
    rgb = np.broadcast_to(FILL * (1.04 - 0.1 * ys), (W, W, 3)).copy()
    outline = (ndimage.distance_transform_edt(~shape) <= 1.2 * S) & ~shape
    rgb[outline] = OUTLINE
    if detail:
        rgb[detail_m] = OUTLINE
    alpha = (shape | outline).astype(float) * 255

    pre = np.dstack([rgb * alpha[..., None] / 255, alpha])
    small = Image.fromarray(np.clip(pre, 0, 255).astype(np.uint8), "RGBA").resize((SIZE, SIZE), Image.BOX)
    s = np.array(small).astype(float)
    a = s[..., 3:4]
    s[..., :3] = np.where(a > 0, s[..., :3] * 255 / np.maximum(a, 1), 0)
    Image.fromarray(np.clip(s, 0, 255).astype(np.uint8), "RGBA").save(out_path)
    print("wrote", out_path)


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    main(args[0], args[1] if len(args) > 1 else "Images/status_Settled.png", "--detail" in sys.argv)
