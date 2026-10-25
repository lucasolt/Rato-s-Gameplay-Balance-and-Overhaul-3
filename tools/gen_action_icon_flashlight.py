"""Flashlight switch action icons (on/off), in the vanilla combat-action style.

Action icons are 108x54: two 54x54 frames (normal, hover). The hover frame is brighter with a soft glow;
both sit on the faded blue scanline background the vanilla actions use (see shootingstancecompleto.png).

    python tools/gen_action_icon_flashlight.py [out_dir]
"""
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

F = 54
S = 8
R2 = np.sqrt(0.5)
FILL = ((200, 197, 180), (238, 236, 224))
GROOVE = ((112, 112, 104), (138, 138, 128))
LENS_ON = ((246, 240, 196), (255, 252, 226))
LENS_OFF = ((78, 82, 86), (96, 100, 104))
OUTLINE = (26, 26, 26)
STRIPE = np.array((118, 160, 180), float)
GLOW = np.array((214, 224, 230), float)
ORIGIN_SHIFT = 4.0      # along the axis, so tail..rays sit centered in the frame
RAY_R = (10.0, 18.0)    # ray span, distance from the fan origin behind the lens
RAY_ANGLES = (-34, 0, 34)
RAY_W = 0.85            # half width


def axis_coords():
    """Supersampled coords along (u) and across (v) the up-right diagonal."""
    c = (np.arange(F * S) + 0.5) / S
    x, y = np.meshgrid(c, c)
    ox, oy = F / 2 + ORIGIN_SHIFT * R2, F / 2 - ORIGIN_SHIFT * R2
    dx, dy = x - ox, y - oy
    return (dx - dy) * R2, (dx + dy) * R2


def seg_dist(u, v, a, b):
    ax, ay = a
    bx, by = b
    px, py = u - ax, v - ay
    ex, ey = bx - ax, by - ay
    t = np.clip((px * ex + py * ey) / (ex * ex + ey * ey), 0, 1)
    return np.hypot(px - t * ex, py - t * ey)


def shapes(on):
    u, v = axis_coords()
    av = np.abs(v)
    # half height along the body: tail cap, grip, neck, body, flared head
    h = np.select(
        [(u >= -27) & (u < -25.5), (u >= -25.5) & (u < -14), (u >= -14) & (u < -11),
         (u >= -11) & (u < -3), (u >= -3) & (u < 3), (u >= 3) & (u <= 5)],
        [2.6, 3.0, 3.0 + (u + 14) / 6, 3.5, 3.5 + (u + 3) * 0.6, 7.2], 0)
    body = av < h
    groove = body & (u > -24) & (u < -15) & (np.mod(u + 24, 3) < 1.1)
    lens = body & (u >= 2.6) & (av < 6.2)
    rays = np.zeros_like(body)
    if on:
        for ang in RAY_ANGLES:
            r = np.radians(ang)
            a = (RAY_R[0] * np.cos(r), RAY_R[0] * np.sin(r))
            b = (RAY_R[1] * np.cos(r), RAY_R[1] * np.sin(r))
            rays |= seg_dist(u, v, a, b) < RAY_W
    return body, groove, lens, rays


def down(m):
    return m.reshape(F, S, F, S).mean(axis=(1, 3))


def stripes():
    rng = np.random.default_rng(42)
    x = np.arange(F) + 0.5
    env_x = np.exp(-((x - F / 2) / 19) ** 4)
    a = np.zeros((F, F))
    for y in range(F):
        k = (y - 3) % 4
        if k > 1:
            continue
        env_y = np.exp(-((y + 0.5 - F / 2) / 19) ** 4)
        noise = ndimage.gaussian_filter1d(rng.uniform(0.0, 1.0, F), 1.2)
        a[y] = 125 * (0.55 + 0.45 * k) * env_x * env_y * noise / noise.max()
    return a


def frame(on, hover):
    body, groove, lens, rays = shapes(on)
    fg = body | rays
    fill = np.array(FILL[hover], float)
    col = np.where(groove[..., None], GROOVE[hover], fill)
    col = np.where(lens[..., None], (LENS_ON if on else LENS_OFF)[hover], col)
    a_fg = down(fg.astype(float))
    rgb_fg = (col * fg[..., None]).reshape(F, S, F, S, 3).sum(axis=(1, 3)) / np.maximum(
        fg.reshape(F, S, F, S).sum(axis=(1, 3)), 1)[..., None]
    a_out = down(ndimage.distance_transform_edt(~fg) <= S * 1.0) * 0.85

    out = np.zeros((F, F, 4))
    out[..., :3] = STRIPE
    out[..., 3] = stripes() / 255

    def over(rgb, a):
        a0 = out[..., 3]
        na = a + a0 * (1 - a)
        out[..., :3] = (rgb * a[..., None] + out[..., :3] * (a0 * (1 - a))[..., None]) / np.maximum(na, 1e-6)[..., None]
        out[..., 3] = na

    if hover:
        over(GLOW, np.clip(ndimage.gaussian_filter(a_out, 1.6) * 0.75, 0, 1))
    over(np.array(OUTLINE, float), a_out)
    over(rgb_fg, a_fg)
    return np.dstack([np.clip(out[..., :3], 0, 255), np.clip(out[..., 3] * 255, 0, 255)]).round().astype(np.uint8)


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "Images"
    for on, name in ((True, "flashlight_switch.png"), (False, "flashlight_switch_off.png")):
        im = np.concatenate([frame(on, 0), frame(on, 1)], axis=1)
        Image.fromarray(im, "RGBA").save(os.path.join(out_dir, name))


if __name__ == "__main__":
    main()
