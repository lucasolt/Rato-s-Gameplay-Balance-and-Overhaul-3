"""Captures clean, level weapon renders from the running game into tools/weapon_icons/src/<Name>.png (RGBA).

Open any weapon in the Modify Weapon screen first. tools/weapon_icons/capture.lua then spawns a default copy of
each class there, turns it exactly side-on (cabinet axis_z 180 deg: camera looks along +Y, barrel is local +X), and
renders it isolated: neutral LUT, white scene light colours (the cabinet's are warm), no vignette/bloom/sharpening/particles/sky/UI, DLSS at 100%.
Four shots per gun (gun and empty, over dark sky and a bright plane) give exact alpha by difference matting:
    alpha = 1 - (fg_bright - fg_dark) / (bg_bright - bg_dark)
The gun's shadow is disabled so it cannot fall on the plane. Afterwards build the icons with gen_weapon_icons.py.

    python tools/capture_weapon_icons.py              # every JOBS entry that has a `cls`
    python tools/capture_weapon_icons.py UMP G11      # some of them
"""
import os
import subprocess
import sys
import time

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_weapon_icons import JOBS, SRC  # noqa: E402

SHOTS = os.path.join(os.environ["APPDATA"], "Jagged Alliance 3", "rat_icons")
MARGIN = 12


def capture(names):
    os.makedirs(SHOTS, exist_ok=True)
    for f in os.listdir(SHOTS):
        os.remove(os.path.join(SHOTS, f))
    with open(os.path.join(HERE, "weapon_icons", "capture.lua"), encoding="utf-8") as fh:
        lua = fh.read()
    classes = ", ".join('{"%s", "%s"}' % (n, JOBS[n]["cls"]) for n in names)
    script = os.path.join(SHOTS, "_capture.lua")
    with open(script, "w", encoding="utf-8") as fh:
        fh.write(lua.replace("--CLASSES--", classes))
    subprocess.run([sys.executable, os.path.join(HERE, "dap_eval.py"), "--quiet", "-c", "-f", script], check=True)
    done = os.path.join(SHOTS, "done.txt")
    deadline = time.time() + 30 + 15 * len(names)
    while not os.path.exists(done):
        if time.time() > deadline:
            sys.exit("capture timed out; check the game")
        time.sleep(1)
    time.sleep(0.5)
    with open(done) as fh:
        report = fh.read()
    print(report)
    if "ok=true" not in report:
        sys.exit(1)


def load(name, kind):
    return np.array(Image.open(os.path.join(SHOTS, f"{name}_{kind}.png")).convert("RGB")).astype(float)


def matte(name):
    fd, fb, bd, bb = (load(name, k) for k in ("fg_dark", "fg_bright", "bg_dark", "bg_bright"))
    dback = bb - bd
    # least squares over the channels: weights the channels where the backdrops differ most
    alpha = 1 - ((fb - fd) * dback).sum(2) / np.maximum((dback * dback).sum(2), 1)
    weak = (dback * dback).sum(2) < 30 ** 2
    if weak.any():
        print(f"  {name}: {weak.mean():.1%} of pixels have a weak backdrop difference")
    alpha = np.clip(alpha, 0, 1)
    alpha[alpha < 0.02] = 0
    col = np.clip((fd - (1 - alpha[..., None]) * bd) / np.maximum(alpha[..., None], 1e-3), 0, 255)

    ys, xs = np.nonzero(alpha > 0.1)
    H, W = alpha.shape
    if ys.min() < 2 or xs.min() < 2 or ys.max() > H - 3 or xs.max() > W - 3:
        print(f"  {name}: WARNING gun touches the screen edge")
    y0, y1 = max(0, ys.min() - MARGIN), min(H, ys.max() + MARGIN + 1)
    x0, x1 = max(0, xs.min() - MARGIN), min(W, xs.max() + MARGIN + 1)
    rgba = np.dstack([col, alpha * 255])[y0:y1, x0:x1].astype(np.uint8)
    path = os.path.join(SRC, JOBS[name]["src"])
    Image.fromarray(rgba, "RGBA").save(path)
    print(f"  {name}: {x1 - x0}x{y1 - y0} -> {os.path.normpath(path)}")


def main():
    names = sys.argv[1:] or [n for n, j in JOBS.items() if j.get("cls")]
    bad = [n for n in names if n not in JOBS or not JOBS[n].get("cls")]
    if bad:
        sys.exit(f"no JOBS entry with `cls` for: {', '.join(bad)}")
    capture(names)
    for n in names:
        matte(n)


if __name__ == "__main__":
    main()
