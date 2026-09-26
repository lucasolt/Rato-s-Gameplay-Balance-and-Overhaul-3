"""Builds vanilla-style inventory icons for ToG guns into Images/<Name>_icon.png from in-game renders.

Sources live in tools/weapon_icons/src: RGBA captures from capture_weapon_icons.py (clean alpha, neutral
light, already side-on), or opaque screenshots on the modify-screen canvas. Per gun:
  1. Screenshots only: GrabCut cutout, re-run with solid canvas patches forced to background.
  2. Screenshots only: white balance from the low-saturation metal pixels. Then luma percentiles are
     remapped to vanilla values.
  3. Levelled by `tilt` (degrees CCW), cropped, premultiplied Lanczos downscale, light unsharp.
  4. Vanilla glow: no offset, 1px spread, gaussian sigma 3.2, opacity 0.9, rgb (3,3,3) --
     fitted against 11 vanilla UI/Icons/Weapons DDS files (0.9 matches vanilla's 2-4px ring alpha ~0.37).
Masks, mask overlays (magenta = removed) and a 3x preview go to tools/weapon_icons/_work.

    pip install pillow numpy scipy opencv-python-headless
    python tools/gen_weapon_icons.py                  # all guns
    python tools/gen_weapon_icons.py UMP P90          # some guns
    python tools/gen_weapon_icons.py --measure-tilt   # suggest `tilt` values, writes nothing

Canvas 216x110 fits LargeItem guns, 108x110 the small ones; vanilla gun bodies span x ~6..209 / ~5..101.
"""
import argparse
import os

import cv2
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "weapon_icons", "src")
WORK = os.path.join(HERE, "weapon_icons", "_work")
OUT = os.path.join(HERE, "..", "Images")

GLOW_SPREAD, GLOW_SIGMA, GLOW_OP, GLOW_RGB = 1, 3.2, 0.9, (3, 3, 3)
SRC_PCT = [2, 25, 50, 75, 98]

# cls: game class, for capture_weapon_icons.py; src: RGBA capture (alpha used as is) or an opaque screenshot
# (then rect: GrabCut box (x0, y0, x1, y1), wood: skip reddish pixels in the white-balance reference);
# box: max gun size in the icon; pct: target luma at SRC_PCT (vanilla black guns ~[10,40,65,95,170]);
# ratio: metal r:g:b after white balance, None to keep the capture's neutral colour; tilt: degrees CCW
JOBS = {
    "UMP":      dict(cls="UMP_1",      src="UMP.png",      canvas=(216, 110), box=(206, 86),
                     pct=[8, 38, 62, 90, 160],   ratio=None, tilt=0),
    "P90":      dict(cls="P90_2",      src="P90.png",      canvas=(216, 110), box=(200, 76),
                     pct=[8, 38, 60, 90, 165],   ratio=None, tilt=0),
    "M1Garand": dict(cls="M1Garand_2", src="M1Garand.png", canvas=(216, 110), box=(206, 70),
                     pct=[16, 44, 62, 100, 196], ratio=None, tilt=0),
    "USP":      dict(cls="USP_1",      src="USP.png",      canvas=(108, 110), box=(98, 72),
                     pct=[10, 36, 58, 88, 160],  ratio=None, tilt=0),
    "G11":      dict(cls="G11_1",      src="G11.png",      canvas=(216, 110), box=(206, 80),
                     pct=[8, 38, 62, 90, 160],   ratio=None, tilt=0),
    "AN94":     dict(cls="AN94_1",     src="AN94.png",     canvas=(216, 110), box=(206, 80),
                     pct=[8, 38, 62, 90, 165],   ratio=None, tilt=0),
}


def load_source(job):
    im = Image.open(os.path.join(SRC, job["src"]))
    if im.mode == "RGBA" and np.array(im)[..., 3].min() < 255:
        a = np.array(im).astype(float)
        return a[..., :3], a[..., 3] / 255
    return np.array(im.convert("RGB")).astype(float), None


def canvas_like(img):
    b, g, r = [img[..., i].astype(int) for i in range(3)]
    luma = (r * 3 + g * 6 + b) // 10
    # canvas: bright and yellow (blue well under red/green); cast shadow: same hue, darker
    lit = (luma > 105) & (b * 100 < r * 70) & (abs(r - g) * 100 < r * 22)
    shade = (luma > 55) & (b * 100 < r * 60) & (abs(r - g) * 100 < r * 20)
    return lit | shade


def segment(name, job):
    _, alpha = load_source(job)
    if alpha is not None:
        return alpha > 0.5
    img = cv2.imread(os.path.join(SRC, job["src"]), cv2.IMREAD_COLOR)
    x0, y0, x1, y1 = job["rect"]
    mask = np.zeros(img.shape[:2], np.uint8)
    bg, fgm = np.zeros((1, 65)), np.zeros((1, 65))
    cv2.setRNGSeed(0)  # GrabCut seeds its GMMs with k-means; keep reruns byte-identical
    cv2.grabCut(img, mask, (x0, y0, x1 - x0, y1 - y0), bg, fgm, 6, cv2.GC_INIT_WITH_RECT)
    # only solid canvas patches: thin warm highlights on the metal vanish under erosion
    solid = ndimage.binary_dilation(ndimage.binary_erosion(canvas_like(img), iterations=5), iterations=3)
    mask[solid] = cv2.GC_BGD
    cv2.grabCut(img, mask, None, bg, fgm, 6, cv2.GC_INIT_WITH_MASK)
    fg = (mask == 1) | (mask == 3)
    lab, n = ndimage.label(fg)
    if n > 1:
        sizes = ndimage.sum(fg, lab, range(1, n + 1))
        fg = np.isin(lab, 1 + np.flatnonzero(sizes >= sizes.max() * 0.01))
    fg = ndimage.binary_opening(fg, iterations=1)
    ov = img.copy()
    ov[~fg] = (ov[~fg] * 0.25 + np.array([255, 0, 255]) * 0.75).astype(np.uint8)
    cv2.imwrite(os.path.join(WORK, name + "_mask_overlay.png"), ov)
    return fg


def measure_tilt(name, job, fg):
    g = cv2.cvtColor(cv2.imread(os.path.join(SRC, job["src"])), cv2.COLOR_BGR2GRAY).astype(float)
    gy = np.abs(ndimage.sobel(ndimage.gaussian_filter(g, 1), axis=0))
    gy[~ndimage.binary_dilation(fg, iterations=3)] = 0
    gy = np.maximum(gy, np.abs(ndimage.sobel(fg.astype(float), axis=0)) * 60)
    # straight horizontal edges collapse into single rows at the right angle
    scores = sorted(((ndimage.rotate(gy, a, reshape=True, order=1).sum(1) ** 2).sum(), a)
                    for a in np.arange(-8, 8.01, 0.1))[::-1]
    alts = [round(float(a), 1) for _, a in scores[1:40] if abs(a - scores[0][1]) > 1][:2]
    print(f"{name}: tilt {scores[0][1]:+.1f} (current {job['tilt']:+.1f}; other peaks {alts})")


def build(name, job, m):
    rgb, src_alpha = load_source(job)

    if job["ratio"]:
        # white balance from low-saturation (metal) pixels only, so wood keeps its hue
        p = rgb[m]
        lowsat = (p.max(1) - p.min(1)) < np.maximum(18, p.max(1) * 0.45)
        if job.get("wood"):
            lowsat &= p[:, 0] < p[:, 1] * 1.25
        ref = p[lowsat].mean(0)
        gains = np.array(job["ratio"]) / (ref / ref[2])
        rgb = rgb * (gains / (gains @ [.3, .59, .11]))

    # piecewise-linear luma remap, applied as a ratio to keep chroma
    luma = rgb @ [.3, .59, .11]
    src_pct = np.percentile(luma[m], SRC_PCT)
    xs = np.concatenate([[0], src_pct, [max(255, src_pct[-1] + 1)]])
    ys = np.concatenate([[0], job["pct"], [255]])
    rgb = np.clip(rgb * (np.interp(luma, xs, ys) / np.maximum(luma, 1))[..., None], 0, 255)

    if src_alpha is not None:
        alpha = src_alpha
        m = alpha > 0.02
    else:
        # fringe takes the nearest interior colour so canvas yellow does not bleed into the AA edge
        _, (iy, ix) = ndimage.distance_transform_edt(~ndimage.binary_erosion(m, iterations=2), return_indices=True)
        rgb = rgb[iy, ix]
        alpha = ndimage.gaussian_filter(ndimage.binary_erosion(m, iterations=1).astype(float), 0.8)

    if job["tilt"]:
        rgb = np.dstack([ndimage.rotate(rgb[..., c], job["tilt"], reshape=True, order=3, mode="nearest")
                         for c in range(3)])
        rgb = np.clip(rgb, 0, 255)  # cubic overshoot wraps to blue speckles in uint8
        alpha = np.clip(ndimage.rotate(alpha, job["tilt"], reshape=True, order=1), 0, 1)
        m = alpha > 0.02
    ys_, xs_ = np.nonzero(m)
    crop = np.dstack([rgb, alpha * 255])[ys_.min():ys_.max() + 1, xs_.min():xs_.max() + 1]

    box = job["box"]
    scale = min(box[0] / crop.shape[1], box[1] / crop.shape[0])
    size = (max(1, round(crop.shape[1] * scale)), max(1, round(crop.shape[0] * scale)))
    # premultiplied resize avoids dark halos from transparent pixels
    pm = crop.copy()
    pm[..., :3] *= pm[..., 3:4] / 255
    arr = np.dstack([np.array(Image.fromarray(pm[..., c].astype(np.float32), "F").resize(size, Image.LANCZOS))
                     for c in range(4)])
    a = np.clip(arr[..., 3], 0, 255)
    col = np.where(a[..., None] > 0, arr[..., :3] * 255 / np.maximum(a[..., None], 1e-3), 0)
    small = Image.fromarray(np.dstack([np.clip(col, 0, 255), a]).astype(np.uint8), "RGBA")
    sharp = small.convert("RGB").filter(ImageFilter.UnsharpMask(radius=1.0, percent=45, threshold=1))
    small = Image.merge("RGBA", (*sharp.split(), small.split()[3]))

    W, H = job["canvas"]
    gun = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gun.paste(small, ((W - small.width) // 2, (H - small.height) // 2 - 1))
    g = np.array(gun).astype(float)
    ga = g[..., 3] / 255

    solid = ndimage.binary_dilation(ga > 0.5, iterations=GLOW_SPREAD) if GLOW_SPREAD else ga > 0.5
    glow = np.clip(ndimage.gaussian_filter(np.maximum(solid, ga), GLOW_SIGMA) * GLOW_OP, 0, 1)
    out_a = ga + glow * (1 - ga)
    out_rgb = (g[..., :3] * ga[..., None] + np.array(GLOW_RGB) * (glow * (1 - ga))[..., None]) \
        / np.maximum(out_a[..., None], 1e-6)
    res = Image.fromarray(np.dstack([np.clip(out_rgb, 0, 255), out_a * 255]).astype(np.uint8), "RGBA")
    path = os.path.join(OUT, name + "_icon.png")
    res.save(path)
    print("wrote", os.path.normpath(path))
    return res


def preview(icons):
    S, pad = 3, 10
    cells = []
    for im in icons:
        bg = Image.new("RGBA", im.size, (150, 140, 110, 255))
        bg.alpha_composite(im)
        cells.append(bg.resize((im.width * S, im.height * S), Image.NEAREST))
    sheet = Image.new("RGBA", (216 * S, len(cells) * (110 * S + pad)), (40, 40, 40, 255))
    for i, c in enumerate(cells):
        sheet.paste(c, (0, i * (110 * S + pad)))
    sheet.save(os.path.join(WORK, "preview.png"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("names", nargs="*", help=f"subset of {', '.join(JOBS)}")
    ap.add_argument("--measure-tilt", action="store_true", help="print suggested tilt values only")
    args = ap.parse_args()
    names = args.names or list(JOBS)
    os.makedirs(WORK, exist_ok=True)
    icons = []
    for name in names:
        fg = segment(name, JOBS[name])
        if args.measure_tilt:
            measure_tilt(name, JOBS[name], fg)
        else:
            icons.append(build(name, JOBS[name], fg))
    if icons:
        preview(icons)


if __name__ == "__main__":
    main()
