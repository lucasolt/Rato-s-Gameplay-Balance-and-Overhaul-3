"""Exact replica of GBO3 angular-CTH integer math (Code/FUNCTIONS_aperture.lua)."""

SLAB = 1200

def mdr(a, b, c):
    """MulDivRound: engine rounds half away from zero."""
    n = a * b
    if c == 0: return 0
    q, r = divmod(abs(n), abs(c))
    if 2 * r >= abs(c): q += 1
    return q if (n >= 0) == (c > 0) else -q

def idiv(a, b):
    """Lua 5.3-with-truncating-/ as the engine patches it."""
    q = abs(a) // abs(b)
    return q if (a >= 0) == (b > 0) else -q

class P:
    SkillMin = 50
    SkillMaxFactor = 3
    BaseFactor = 75
    FloorPct = 55
    DecayBase = 0
    DecayScale = 6
    DecayMinPct = 20
    MinCTH = 1
    MaxCTH = 97
    AimStep = {0: 280, 1: 180, 2: 130}
    AimStepMaxLevel = 2
    ConeRefCTH = 80
    ConeMulMin = 25
    ConeMulMax = 1000
    RayleighStep = 125
    Silhouette = {"Standing": 42, "Crouch": 37, "Prone": 31}
    BodyPart = {"Torso": 100, "Arms": 62, "Legs": 62, "Groin": 55}
    BodyPartAbsolute = {"Head": 11, "Neck": 11}
    CrosshairSigmaMul = 250

    @property
    def SkillMax(self): return self.SkillMaxFactor * self.SkillMin
    @property
    def Base(self): return idiv(self.BaseFactor * 100, self.SkillMin)

RAY = [0, 8, 31, 68, 117, 177, 245, 318, 393, 469, 542, 611, 675, 733, 784, 828,
       865, 896, 920, 940, 956, 968, 977, 984, 989, 992, 995, 997, 998, 999, 999, 999, 1000]

def theta_target(dist, half_cm):
    if dist is None or dist < 1: return 100000
    return max(1, mdr(half_cm, 34380, dist))

def rayleigh_cth(theta, sigma, p=None):
    p = p or P()
    if not sigma or sigma < 1: return 100
    k1000 = mdr(theta, 1000, sigma)
    step = p.RayleighStep
    idx = idiv(k1000, step)
    if idx >= len(RAY) - 1: return 100
    lo, hi = RAY[idx], RAY[idx + 1]
    frac = k1000 - idx * step
    permil = lo + mdr(hi - lo, frac, step)
    return mdr(permil, 100, 1000)

def k_for_cth(cth, p=None):
    p = p or P()
    cth = max(1, min(99, cth))
    permil = cth * 10
    for i in range(1, len(RAY)):
        if RAY[i] >= permil:
            lo, hi = RAY[i - 1], RAY[i]
            frac = mdr(permil - lo, p.RayleighStep, hi - lo) if hi > lo else 0
            k1000 = (i - 1) * p.RayleighStep + frac
            return k1000 if k1000 >= 1 else None
    return len(RAY) * p.RayleighStep

def cone_mul_for_points(points, p=None):
    """Residual CTH points -> cone multiplier %."""
    p = p or P()
    if not points: return 100
    ref = max(2, min(98, p.ConeRefCTH))
    if points < 0:
        tgt = mdr(ref, 100 + max(points, -100), 100)
    else:
        tgt = ref + mdr(100 - ref, min(points, 100), 100)
    kr, kt = k_for_cth(ref, p), k_for_cth(max(1, min(99, tgt)), p)
    if not kr or not kt or kt < 1: return p.ConeMulMax
    return max(p.ConeMulMin, min(p.ConeMulMax, mdr(kr, 100, kt)))

def skill_mul(marks, p=None):
    p = p or P()
    marks = max(0, min(100, marks))
    return p.SkillMax - mdr(p.SkillMax - p.SkillMin, marks, 100)

def aperture_floor(weapon_range, p=None):
    p = p or P()
    th = theta_target(weapon_range * SLAB, p.Silhouette["Standing"])
    return max(1, mdr(th, p.FloorPct, 100))

def aim_decay(acc, he=100, p=None, extra_mul=100):
    """acc = AimAccuracy effective at this level (incl. scope threshold bonus)."""
    p = p or P()
    d = 100 - (p.DecayBase + p.DecayScale * acc)
    if extra_mul != 100:
        d = mdr(d, extra_mul, 100)
    d = max(p.DecayMinPct, d)
    d = 100 - mdr(100 - d, he, 100)
    return max(p.DecayMinPct, min(99, d))

def sigma(weapon_range, acc, marks=100, aim=0, he=100, handling_mul=100,
          scope=None, hipsnap=100, p=None, sight=100):
    """scope = list of dicts {'from':n,'to':n|None,'acc':x} threshold optics."""
    p = p or P()
    s = p.Base
    if handling_mul != 100:
        s = mdr(s, handling_mul, 100)
    s = mdr(s, skill_mul(marks, p), 100)
    if aim > 0 and sight != 100:
        s = mdr(s, sight, 100)
    flr = aperture_floor(weapon_range, p)
    gap = max(0, s - flr)
    ladder = []
    for i in range(1, aim + 1):
        bonus = 0
        for o in (scope or []):
            if i >= o["from"] and (o.get("to") is None or i <= o["to"]):
                bonus += o["acc"]
        d = aim_decay(acc + bonus, he, p)
        ladder.append(d)
        gap = mdr(gap, d, 100)
    s = flr + gap
    step = 100
    if aim <= p.AimStepMaxLevel:
        excess = p.AimStep.get(aim, 100) - 100
        if excess > 0:
            excess = mdr(excess, hipsnap, 100)
            step = 100 + excess
            s = mdr(s, step, 100)
    return max(1, s), flr, ladder, step

def cth(dist_tiles, weapon_range, acc, marks=100, aim=0, he=100, handling_mul=100,
        scope=None, hipsnap=100, residual_points=0, part="Torso",
        stance="Standing", exposed=100, p=None, sight=100):
    p = p or P()
    sg, flr, ladder, step = sigma(weapon_range, acc, marks, aim, he, handling_mul,
                                  scope, hipsnap, p, sight)
    if residual_points:
        sg = max(1, mdr(sg, cone_mul_for_points(residual_points, p), 100))
    if part in p.BodyPartAbsolute:
        half = p.BodyPartAbsolute[part]
    else:
        half = p.Silhouette[stance]
        half = mdr(half, p.BodyPart.get(part, 100), 100)
    if exposed < 100:
        half = mdr(half, isqrt(exposed * 100), 100)
    half = max(1, half)
    th = theta_target(dist_tiles * SLAB, half)
    return max(p.MinCTH, min(p.MaxCTH, rayleigh_cth(th, sg, p))), sg, th

def isqrt(n):
    if n <= 0: return 0
    x, y = n, idiv(n + 1, 2)
    while y < x:
        x = y
        y = idiv(x + idiv(n, x), 2)
    return x
