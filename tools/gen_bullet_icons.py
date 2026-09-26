"""Renders the autofire crosshair cartridge icons into Images/Bullets/<id>[_AP|_Match|_Tracer|_HP].png.

Pure stdlib (no PIL). Each round is a stack of radius segments in real millimetres, shaded as a lit
cylinder. Height is compressed (px ~ sqrt(length)) so a .50 BMG does not dwarf a pistol round.
Images are drawn at 2x the UI size; the Lua side halves them.

    python tools/gen_bullet_icons.py
"""
import math
import os
import struct
import zlib

OUT = os.path.join(os.path.dirname(__file__), "..", "Images", "Bullets")
PX_K = 6.0  # image px/mm = PX_K / sqrt(length)
SS = 4  # supersamples per axis

MAT = {
    # base rgb, specular strength, shininess
    "brass": ((200, 158, 76), 0.55, 18),
    "nickel": ((188, 190, 196), 0.65, 22),
    "steel_green": ((104, 110, 78), 0.25, 10),
    "steel_grey": ((96, 98, 90), 0.25, 10),
    "steel_dark": ((78, 74, 62), 0.2, 10),
    "copper": ((190, 106, 62), 0.5, 16),
    "gilding": ((176, 116, 72), 0.45, 14),
    "lead": ((104, 106, 116), 0.3, 8),
    "tip_green": ((58, 142, 72), 0.3, 10),
    "tip_black": ((34, 34, 38), 0.35, 12),
    "tip_red": ((196, 44, 40), 0.4, 14),
    "propellant": ((168, 92, 50), 0.08, 6),
    "propellant_cap": ((128, 64, 36), 0.08, 6),
    "ring": ((34, 30, 28), 0.15, 8),
    "tip_ap": ((191, 67, 77), 0.3, 10),
    "tip_match": ((220, 140, 28), 0.3, 10),
    "tip_tracer": ((134, 143, 93), 0.3, 10),
    "tip_hp": ((109, 187, 209), 0.3, 10),
    # shotshell hulls follow the inventory icons, not the TextStyle colors (sampled 2026-09-26)
    "hull_basic": ((67, 124, 37), 0.2, 8),
    "hull_ap": ((124, 44, 34), 0.2, 8),
    "hull_match": ((36, 108, 116), 0.2, 8),
    "hull_tracer": ((149, 120, 11), 0.2, 8),
    "hull_hp": ((109, 187, 209), 0.2, 8),
}


def darker(mat, f):
    rgb, spec, shin = MAT[mat]
    key = "%s*%s" % (mat, f)
    MAT[key] = (tuple(c * f for c in rgb), spec * f, shin)
    return key


class Round:
    def __init__(self):
        self.segs = []  # (y0, y1, radius_fn(t), mat_fn(t), shape)
        self.y = 0.0

    def lin(self, length, r0, r1, mat, shape="cyl"):
        self.segs.append((self.y, self.y + length, lambda t, a=r0, b=r1: a + (b - a) * t,
                          lambda t, m=mat: m, shape))
        self.y += length
        return self

    def nose(self, length, r, mat, a=1.6, b=1.0, cut=1.0, tip=None, tipfrac=0.0, ring=0.0):
        """r(t) = r * (1 - (t*cut)^a)^b; cut < 1 leaves a flat meplat. ring: dark band (mm) under the tip."""
        ring_t = ring / length
        def rad(t):
            u = t * cut
            return r * max(0.0, 1 - u ** a) ** b

        def mat_at(t):
            if tip and t >= 1 - tipfrac:
                return tip
            return "ring" if ring and t >= 1 - tipfrac - ring_t else mat
        self.segs.append((self.y, self.y + length, rad, mat_at, "cyl"))
        self.y += length
        return self

    def base(self, D, mat, rim_r=None):
        """Rimmed (rim_r > body) or rimless with an extractor groove."""
        dark = darker(mat, 0.72)
        if rim_r and rim_r > D / 2:
            return self.lin(1.4, rim_r, rim_r, dark)
        rim = rim_r or D / 2
        self.lin(1.1, rim, rim, dark)
        self.lin(0.5, D / 2 * 0.82, D / 2 * 0.82, darker(mat, 0.5))
        return self.lin(0.6, D / 2 * 0.82, D / 2, dark)

    def sample(self, y):
        for y0, y1, rf, mf, shape in self.segs:
            if y0 <= y < y1:
                t = (y - y0) / (y1 - y0)
                return rf(t), mf(t), shape
        return None


def bottleneck(L, case_len, D, sh0, sh1, neck_r, bullet_r, case_mat, bullet_mat,
               rim_r=None, ogive=0.72, tip=None, tipfrac=0.0, nose_a=1.5, ring=0.0):
    r = Round().base(D, case_mat, rim_r)
    body_top = D / 2 * 0.95
    r.lin(sh0 - r.y, D / 2, body_top, case_mat)
    r.lin(sh1 - sh0, body_top, neck_r, case_mat)
    r.lin(case_len - sh1, neck_r, neck_r, case_mat)
    exposed = L - case_len
    r.lin(exposed * (1 - ogive), bullet_r, bullet_r, bullet_mat)
    r.nose(exposed * ogive, bullet_r, bullet_mat, a=nose_a, tip=tip, tipfrac=tipfrac, ring=ring)
    return r


def straight(L, case_len, D, bullet_r, case_mat, bullet_mat, rim_r=None, ogive=0.85,
             a=2.0, b=0.55, cut=1.0, tip=None, tipfrac=0.0, ring=0.0):
    r = Round().base(D, case_mat, rim_r)
    r.lin(case_len - r.y, D / 2, D / 2 * 0.985, case_mat)
    exposed = L - case_len
    r.lin(exposed * (1 - ogive), bullet_r, bullet_r, bullet_mat)
    r.nose(exposed * ogive, bullet_r, bullet_mat, a=a, b=b, cut=cut, tip=tip, tipfrac=tipfrac,
           ring=ring)
    return r


def swc(L, case_len, D, bullet_r, case_mat, rim_r, tip=None, tipfrac=0.0):
    ring = ring_mm(L) if tip else 0.0
    """Semi-wadcutter lead: full-diameter band, then a truncated cone to a flat."""
    r = Round().base(D, case_mat, rim_r)
    r.lin(case_len - r.y, D / 2, D / 2, case_mat)
    exposed = L - case_len
    r.lin(exposed * 0.25, bullet_r, bullet_r, "lead")
    cone, r0, r1 = exposed * 0.75, bullet_r * 0.78, bullet_r * 0.58
    split = 1 - (tipfrac if tip else 0.0)
    rad = lambda f: r0 + (r1 - r0) * f
    band = ring / cone
    r.lin(cone * (split - band), r0, rad(split - band), "lead")
    if tip:
        r.lin(ring, rad(split - band), rad(split), "ring")
        r.lin(cone * (1 - split), rad(split), r1, tip)
    return r


def shotshell(L, D, head_len, hull_mat):
    r = Round()
    r.lin(1.2, D / 2 * 1.06, D / 2 * 1.06, darker("brass", 0.72))
    r.lin(head_len - 1.2, D / 2, D / 2, "brass")
    r.lin(L - head_len - 4.0, D / 2 * 0.98, D / 2 * 0.98, hull_mat)
    r.lin(4.0, D / 2 * 0.98, D / 2 * 0.86, darker(hull_mat, 0.82))
    return r


def caseless(L, W, cap_mat="propellant_cap"):
    r = Round()
    ring = ring_mm(L) if cap_mat != "propellant_cap" else 0.0
    r.lin(L - 3.0 - ring, W / 2, W / 2, "propellant", shape="box")
    if ring:
        r.lin(ring, W / 2, W / 2, "ring", shape="box")
    r.lin(3.0, W / 2, W / 2 * 0.92, cap_mat, shape="box")
    return r


# ammo colorStyle -> file suffix and paint (the game's TextStyle colors); Basic keeps each round's own look
VARIANTS = {
    "": None,
    "_AP": "tip_ap",
    "_Match": "tip_match",
    "_Tracer": "tip_tracer",
    "_HP": "tip_hp",
}
HULL = {None: "hull_basic", "tip_ap": "hull_ap", "tip_match": "hull_match",
        "tip_tracer": "hull_tracer", "tip_hp": "hull_hp"}

VT = 0.45  # painted fraction of a round nose on a variant
VT_POINTED = 0.65  # a pointed nose tapers, so more of it is painted
RING_PX = 1.2  # dark band under a painted tip, in image px


def ring_mm(L):
    return RING_PX * math.sqrt(L) / PX_K


def bn(*dims, tip=None, tipfrac=0.0, **kw):
    """bottleneck whose painted tip a variant replaces."""
    return lambda paint: bottleneck(*dims, tip=paint or tip,
                                    tipfrac=max(VT_POINTED, tipfrac) if paint else tipfrac,
                                    ring=ring_mm(dims[0]) if paint else 0.0, **kw)


def st(*dims, **kw):
    return lambda paint: straight(*dims, tip=paint, tipfrac=VT if paint else 0.0,
                                  ring=ring_mm(dims[0]) if paint else 0.0, **kw)


ROUNDS = {
    "9mm": st(29.7, 19.15, 9.96, 4.5, "brass", "copper"),
    "9x18": st(25.0, 18.1, 9.95, 4.63, "steel_green", "gilding"),
    "45ACP": st(32.4, 22.8, 12.0, 5.74, "brass", "copper", ogive=0.9, b=0.5),
    "380ACP": st(25.0, 17.3, 9.5, 4.5, "nickel", "copper", cut=0.8),
    "44MAG": lambda paint: swc(40.6, 32.6, 11.6, 5.4, "nickel", rim_r=6.55, tip=paint, tipfrac=0.4),
    "50AE": st(40.9, 32.6, 13.9, 6.35, "brass", "copper", rim_r=6.7, cut=0.78, b=0.5),
    "5_7x28": bn(43.2, 28.9, 7.95, 23.5, 25.2, 3.25, 2.85, "brass", "copper",
                 ogive=0.85, tip="tip_black", tipfrac=0.3),
    "556": bn(57.4, 44.7, 9.6, 36.5, 39.5, 3.2, 2.85, "brass", "copper",
              tip="tip_green", tipfrac=0.5),
    "545x39": bn(57.0, 39.8, 10.0, 30.5, 33.0, 3.15, 2.8, "steel_green", "gilding", ogive=0.78),
    "762WP": bn(56.0, 38.7, 11.35, 30.5, 32.5, 4.3, 3.95, "steel_grey", "gilding"),
    "762NATO": bn(71.0, 51.2, 11.95, 39.6, 43.0, 4.35, 3.9, "brass", "copper"),
    "308Win": bn(71.0, 51.2, 11.95, 39.6, 43.0, 4.35, 3.9, "nickel", "copper",
                 tip="tip_red", tipfrac=0.18),
    "762x54R": bn(77.2, 53.7, 12.37, 45.0, 48.0, 4.3, 3.95, "steel_green", "gilding", rim_r=7.2),
    "50BMG": bn(138.0, 99.0, 20.4, 76.0, 84.0, 7.1, 6.5, "brass", "copper",
                tip="tip_black", tipfrac=0.3),
    "30-60": bn(84.8, 63.3, 11.95, 49.5, 53.6, 4.4, 3.9, "brass", "copper"),
    "12gauge": lambda paint: shotshell(64.0, 20.2, 12.0, HULL[paint]),
    "7_92x33": bn(47.8, 33.0, 11.9, 25.3, 27.5, 4.45, 4.1, "steel_dark", "gilding"),
    "7_92x57": bn(80.5, 57.0, 11.95, 46.5, 50.0, 4.5, 4.1, "brass", "gilding"),
    "9x39": bn(56.0, 38.7, 11.35, 31.0, 33.0, 5.0, 4.63, "steel_green", "gilding",
               ogive=0.6, tip="tip_black", tipfrac=0.2, nose_a=1.8),
    "4_7x33": lambda paint: caseless(33.0, 8.0, paint or "propellant_cap"),
}

LIGHT = (-0.55, 0.83)  # (x, z): upper-left, towards the viewer


def shade(mat, n, shape):
    rgb, spec, shin = MAT[mat]
    if shape == "box":
        d = 1.0 if n < 0 else 0.62
        d *= 1 - 0.35 * abs(n) ** 8  # soft bevel
        s = 0.0
    else:
        nz = math.sqrt(max(0.0, 1 - n * n))
        d = max(0.0, LIGHT[0] * n + LIGHT[1] * nz)
        s = spec * d ** shin
    k = 0.28 + 0.85 * d
    return tuple(min(255.0, c * k + 255 * s) for c in rgb)


def render(rnd):
    L = rnd.y
    ppm = PX_K / math.sqrt(L)
    max_r = max(max(rf(i / 20) for i in range(21)) for _, _, rf, _, _ in rnd.segs)
    W = int(math.ceil(2 * max_r * ppm)) + 2
    H = int(math.ceil(L * ppm)) + 1
    cx = W / 2
    rows = []
    for py in range(H):
        row = bytearray([0])
        for px in range(W):
            acc = [0.0, 0.0, 0.0]
            cov = 0
            for sy in range(SS):
                y = (H - (py + (sy + 0.5) / SS)) / ppm
                hit = rnd.sample(y)
                if not hit:
                    continue
                r, mat, shape = hit
                if r <= 0:
                    continue
                for sx in range(SS):
                    x = (px + (sx + 0.5) / SS - cx) / ppm
                    if abs(x) <= r:
                        c = shade(mat, x / r, shape)
                        acc[0] += c[0]
                        acc[1] += c[1]
                        acc[2] += c[2]
                        cov += 1
            if cov:
                row += bytes([int(acc[0] / cov), int(acc[1] / cov), int(acc[2] / cov),
                              int(255 * cov / (SS * SS))])
            else:
                row += bytes(4)
        rows.append(bytes(row))
    return W, H, b"".join(rows)


def write_png(path, W, H, raw):
    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for cid, build in ROUNDS.items():
        for suffix, paint in VARIANTS.items():
            W, H, raw = render(build(paint))
            write_png(os.path.join(OUT, cid + suffix + ".png"), W, H, raw)
        print("%-10s %2dx%-3d" % (cid, W, H))
