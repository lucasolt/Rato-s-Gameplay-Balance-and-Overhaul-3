"""Renders a weapon part (stock, scope, ...) from the running game into a 100x100 upgrade icon.

Open the Modify Weapon screen in any loaded map (an empty one is safest), turn the gun until you like the angle, then:

    python tools/capture_part_icon.py MinimiHeavy FNMinimi StockHeavy               # capture + preview
    python tools/capture_part_icon.py MinimiHeavy FNMinimi StockHeavy --tilt -15 0 10
    python tools/capture_part_icon.py MinimiHeavy --no-capture --tilt 5               # re-tilt the last shots
    python tools/capture_part_icon.py MinimiHeavy --no-capture --tilt 0 --install stock_minimi_heavy.png
    python tools/capture_part_icon.py --pose 20 15 0 --set-only                      # just turn the gun to look
    python tools/capture_part_icon.py MinimiHeavy FNMinimi StockHeavy --pose 20 15 0

Orientation: the cabinet's current one (drag it in game), or --pose YAW ROLL SPIN in degrees from side-on
(yaw turns it toward the camera, roll shows the top/bottom, spin turns it in the picture), or --axis-angle X Y Z A
as printed by an earlier capture to repeat it exactly. A posed capture leaves the gun posed. Outputs go to
tools/part_icons/out/: <Name>_<tilt>.png per tilt and <Name>_preview.png (each tilt over grey and dark).
--install copies the first tilt to Images/<file>; point the item's icon at Mod/cfahRED/Images/<file>.
Don't touch the game while it captures (~20 s).
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import time

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(HERE)
OUT = os.path.join(HERE, "part_icons", "out")
SHOTS = os.path.join(os.environ["APPDATA"], "Jagged Alliance 3", "rat_part_icons")
KINDS = ("full_dark", "full_bright", "body_dark", "body_bright", "none_dark", "none_bright")


def lua_pose(args):
    if args.axis_angle:
        x, y, z, a = args.axis_angle
        return "{axis = point(%d, %d, %d), angle = %d}" % (x, y, z, a)
    if args.pose:
        return "{%d, %d, %d}" % tuple(args.pose)
    return "false"


def template():
    with open(os.path.join(HERE, "part_icons", "capture.lua"), encoding="utf-8") as fh:
        return fh.read()


def run_lua(lua):
    os.makedirs(SHOTS, exist_ok=True)
    script = os.path.join(SHOTS, "_capture.lua")
    with open(script, "w", encoding="utf-8") as fh:
        fh.write(lua)
    subprocess.run([sys.executable, os.path.join(HERE, "dap_eval.py"), "--quiet", "-c", "-f", script], check=True)


def set_only(pose):
    fn = re.search(r"^local function pose_axis_angle.*?^end$", template(), flags=re.M | re.S).group(0)
    run_lua("\n".join(["local POSE = " + pose, fn,
                       "local ax, an = pose_axis_angle(g_Cabinet:GetAxis(), g_Cabinet:GetAngle())",
                       "g_Cabinet:SetAxisAngle(ax, an, 0)",
                       "return '--axis-angle ' .. table.concat({ax:xyz()}, ' ') .. ' ' .. an"]))


def capture(name, cls, slot, comp, pose):
    os.makedirs(SHOTS, exist_ok=True)
    for f in os.listdir(SHOTS):
        os.remove(os.path.join(SHOTS, f))
    # whole lines, so a formatter mangling a placeholder cannot leave it unset
    lua = re.sub(r"^local JOB\b.*$", 'local JOB = {"%s", "%s", "%s", "%s"}' % (name, cls, slot, comp), template(),
                 count=1, flags=re.M)
    lua = re.sub(r"^local POSE\b.*$", "local POSE = " + pose, lua, count=1, flags=re.M)
    run_lua(lua)
    done = os.path.join(SHOTS, "done.txt")
    deadline = time.time() + 60
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


def matte(name):
    fd, fb, bd, bb, nd, nb = (np.array(Image.open(os.path.join(SHOTS, f"{name}_{k}.png")).convert("RGB")).astype(float)
                              for k in KINDS)
    db = nb - nd
    a = np.clip(1 - ((fb - fd) * db).sum(2) / np.maximum((db * db).sum(2), 1), 0, 1)
    a[a < 0.02] = 0
    # the part = pixels that change when it is hidden, on either backdrop
    diff = np.maximum(np.abs(fd - bd).max(2), np.abs(fb - bb).max(2))
    mask = ndimage.binary_closing(ndimage.binary_opening(diff > 12, iterations=1), iterations=3)
    lab, n = ndimage.label(mask)
    if n == 0:
        sys.exit("the part never showed up in the shots")
    if n > 1:
        mask = lab == np.argmax(np.bincount(lab.ravel())[1:]) + 1
    a = a * np.clip(ndimage.gaussian_filter(mask.astype(float), 0.8) * 1.5, 0, 1)
    col = np.clip((fd - (1 - a[..., None]) * nd) / np.maximum(a[..., None], 1e-3), 0, 255)
    ys, xs = np.nonzero(a > 0.1)
    return Image.fromarray(np.dstack([col, a * 255])[ys.min() - 4:ys.max() + 5, xs.min() - 4:xs.max() + 5]
                           .astype(np.uint8), "RGBA")


def build(cut, tilt, mirror, gamma):
    im = ImageOps.mirror(cut) if mirror else cut
    r, g, b, al = im.split()
    lut = [min(255, round(255 * (v / 255) ** gamma * 1.1)) for v in range(256)]
    im = Image.merge("RGBA", (r.point(lut), g.point(lut), b.point(lut), al))
    im = im.rotate(tilt, resample=Image.BICUBIC, expand=True)
    im = im.crop(im.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox())
    s = min(92 / im.width, 88 / im.height)
    im = im.resize((max(1, round(im.width * s)), max(1, round(im.height * s))), Image.LANCZOS)
    im = im.filter(ImageFilter.UnsharpMask(radius=1, percent=60, threshold=2))
    c = Image.new("RGBA", (100, 100), (0, 0, 0, 0))
    c.alpha_composite(im, ((100 - im.width) // 2, (100 - im.height) // 2))
    return c


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("name", nargs="?", help="file stem for shots and outputs, e.g. MinimiHeavy")
    ap.add_argument("cls", nargs="?", help="weapon class, e.g. FNMinimi")
    ap.add_argument("comp", nargs="?", help="component id, e.g. StockHeavy")
    ap.add_argument("--slot", default="Stock")
    ap.add_argument("--tilt", type=int, nargs="+", default=[0], help="degrees, positive = counter-clockwise")
    ap.add_argument("--mirror", action="store_true")
    ap.add_argument("--gamma", type=float, default=0.6, help="midtone lift; lower = brighter")
    ap.add_argument("--no-capture", action="store_true", help="rebuild from the last shots")
    ap.add_argument("--install", metavar="FILE", help="copy the first tilt to Images/FILE")
    ap.add_argument("--pose", type=int, nargs=3, metavar=("YAW", "ROLL", "SPIN"), help="degrees from side-on")
    ap.add_argument("--axis-angle", type=int, nargs=4, metavar=("X", "Y", "Z", "A"), help="exact cabinet orientation")
    ap.add_argument("--set-only", action="store_true", help="only turn the gun in the open Modify screen")
    args = ap.parse_args()
    if args.set_only:
        set_only(lua_pose(args))
        return
    if not args.name:
        ap.error("name is needed")
    if not args.no_capture:
        if not (args.cls and args.comp):
            ap.error("cls and comp are needed to capture")
        capture(args.name, args.cls, args.slot, args.comp, lua_pose(args))
    cut = matte(args.name)
    os.makedirs(OUT, exist_ok=True)
    icons = []
    for t in args.tilt:
        icon = build(cut, t, args.mirror, args.gamma)
        path = os.path.join(OUT, f"{args.name}_{t}.png")
        icon.save(path)
        icons.append((t, icon))
        print(os.path.normpath(path))
    sheet = Image.new("RGBA", (len(icons) * 210, 440), (120, 120, 120, 255))
    draw = ImageDraw.Draw(sheet)
    for i, (t, icon) in enumerate(icons):
        big = icon.resize((200, 200), Image.LANCZOS)
        sheet.alpha_composite(big, (i * 210 + 5, 5))
        dark = Image.new("RGBA", (200, 200), (30, 30, 30, 255))
        dark.alpha_composite(big)
        sheet.paste(dark, (i * 210 + 5, 210))
        draw.text((i * 210 + 10, 420), f"tilt {t}", fill=(255, 255, 255, 255))
    preview = os.path.join(OUT, f"{args.name}_preview.png")
    sheet.save(preview)
    print(os.path.normpath(preview))
    if args.install:
        dest = os.path.join(MOD, "Images", args.install)
        shutil.copyfile(os.path.join(OUT, f"{args.name}_{args.tilt[0]}.png"), dest)
        print("installed", os.path.normpath(dest), "-> icon = \"Mod/cfahRED/Images/%s\"" % args.install)


if __name__ == "__main__":
    main()
