#!/usr/bin/env python3
"""Balance tables for the angular-CTH model. Run: python tools/aperture_report.py"""
import os, sys; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from aperture_model import *
p = P()

# d at which CTH = X% vs standing torso (theta = 1203/d)
def d_for_cth(sigma, target_cth=50, half=42):
    k = k_for_cth(target_cth) / 1000.0
    if k <= 0: return 0
    return (half * 34380 / SLAB) / (k * sigma)

ARCH = [
    ("Pistol  Glock17", 18, 2, 19),
    ("Pistol  HiPower",  18, 4, 17),
    ("SMG     MP5",      22, 4, 14),
    ("SMG     HK53",     28, 4, 13),
    ("AR      AK47",     26, 3,  8),
    ("AR      AK74",     28, 5,  7),
    ("BattleR FNFAL",    30, 4,  2),
    ("MG      MG42",     30, 2, -2),
    ("Sniper  SVD",      30, 7, -5),
    ("Sniper  M24",      32, 9, -6),
    ("Sniper  PSG1",     34, 9, -9),
    ("Sniper  Barret",   40, 8,-13),
]

print("="*104)
print("1. WHAT RANGE BUYS: the asymptote.  d50_max = 1022/floor = 1.545 x WeaponRange (torso, standing)")
print("="*104)
print(f"{'archetype':<18}{'range':>6}{'floor':>7}{'sigma0(M90)':>13}{'gap/floor':>11}{'d50_max':>9}   fully-aimed CTH at d = 0.5R / 1.0R / 1.5R / 2.0R")
s0 = mdr(p.Base, skill_mul(90), 100)
for name, R, acc, pb in ARCH:
    F = aperture_floor(R)
    row = []
    for mult in (0.5, 1.0, 1.5, 2.0):
        d = R * mult
        th = theta_target(int(d * SLAB), 42)
        row.append(f"{min(97, rayleigh_cth(th, F)):>3}%")
    print(f"{name:<18}{R:>6}{F:>7}{s0:>13}{(s0-F)/F:>11.2f}{d_for_cth(F):>9.1f}   " + " / ".join(row))

print()
print("="*104)
print("2. RANGE REALISATION  rho(n) = floor/sigma_n  = fraction of the weapon's range ceiling reached")
print("   (Marks 90, HE 100, no scope, no residuals; hipfire/snapshot step INCLUDED at aim 0-2)")
print("="*104)
hdr = "".join(f"{'aim '+str(n):>9}" for n in range(0, 7))
print(f"{'archetype':<18}{'acc':>4}{'decay':>7}" + hdr)
for name, R, acc, pb in ARCH:
    F = aperture_floor(R)
    cells = []
    for n in range(0, 7):
        sg, _, _, _ = sigma(R, acc, marks=90, aim=n, he=100)
        cells.append(f"{d_for_cth(sg):>9.1f}")
    print(f"{name:<18}{acc:>4}{aim_decay(acc):>6}%" + "".join(cells))
print("   (cells are d50 in tiles: the distance at which that aim level still gives 50% on a standing torso)")


print("="*100)
print("3. THE RESIDUAL CURRENCY: Rat_ConeMulForPoints at different ConeRefCTH")
print("   (cone mul %; 100 = neutral. A mul of m is EXACTLY a 1/m change in effective range.)")
print("="*100)
pts = [40, 20, 10, 5, 3, -3, -5, -10, -20, -40, -55]
print(f"{'ConeRefCTH':>11}" + "".join(f"{('+' if x>0 else '')+str(x):>8}" for x in pts))
for ref in (50, 65, 80, 90):
    q = P(); q.ConeRefCTH = ref
    print(f"{ref:>11}" + "".join(f"{cone_mul_for_points(x, q):>8}" for x in pts))
print("   -> at ref 80, +20 points buys only -5% cone but -20 costs +25%.  The scale is")
print("      strongly asymmetric: bonuses are nearly free to the balance, penalties are brutal.")

print()
print("="*100)
print("4. HANDLING: where you apply it changes its SHAPE, not just its size")
print("   Same nominal strength; A = multiplier on sigma_0 (pre-aim), B = multiplier on final sigma")
print("="*100)
def d50(sg): return (42*34380/SLAB)/((k_for_cth(50)/1000.0)*sg)
for name, R, acc, pb, hm in [("SMG  MP5   (PB +14)", 22, 4, 14, 79),
                             ("AR   AK74  (PB  +7)", 28, 5,  7, 90),
                             ("Snpr M24   (PB  -6)", 32, 9, -6, 109)]:
    rowA, rowB, rowN = [], [], []
    for n in range(0, 7):
        sgN,_,_,_ = sigma(R, acc, marks=90, aim=n, he=100)
        sgA,_,_,_ = sigma(R, acc, marks=90, aim=n, he=100, handling_mul=hm)
        sgB = max(1, mdr(sgN, hm, 100))
        rowN.append(f"{d50(sgN):>7.1f}"); rowA.append(f"{d50(sgA):>7.1f}"); rowB.append(f"{d50(sgB):>7.1f}")
    print(f"{name}   HandlingMul={hm}")
    print(f"   {'no handling':<16}" + "".join(rowN))
    print(f"   {'A: on sigma_0':<16}" + "".join(rowA))
    print(f"   {'B: on final':<16}" + "".join(rowB))
print(f"   {'':<16}" + "".join(f"{'aim '+str(n):>7}" for n in range(0,7)))
print("   A washes out as you aim (the cone converges to the floor, which handling never touched).")
print("   B is a flat % at every aim level -- it never lets the long gun overtake the short one.")

print()
print("="*100)
print("5. THE INTENDED CROSSOVER, with handling on sigma_0 (Marks 90, HE 100)")
print("   CTH on a standing torso.  Handling = 100 - 1.5 x PBbonus.")
print("="*100)
CASES = [("SMG  MP5",  22, 4, 14, 3), ("AR   AK74", 28, 5, 7, 3), ("Snpr M24", 32, 9, -6, 3)]
for dist in (4, 8, 12, 18, 25, 32):
    print(f"  --- {dist} tiles ---")
    for name, R, acc, pb, mx in CASES:
        hm = max(40, min(160, 100 - int(1.5*pb)))
        cells = []
        for n in range(0, 7):
            c,_,_ = cth(dist, R, acc, marks=90, aim=n, he=100, handling_mul=hm)
            cells.append(f"{c:>6}%")
        print(f"    {name:<11}hdl={hm:>4}" + "".join(cells))
    print(f"    {'':<16}" + "".join(f"{'aim '+str(n):>7}" for n in range(0,7)))


# ShootAP, APStance, MaxAim(base), range, acc, PB
W = [("MP5   SMG",     3, 3, 22, 4, 14, 3),
     ("AK74  AR",      4, 4, 28, 5,  7, 3),
     ("FNFAL BattleR", 4, 4, 30, 4,  2, 3),
     ("M24   Sniper",  4, 5, 32, 9, -6, 3)]
AP = 12
HS = 150  # handling scale: cone% per point of PBbonus

def hmul(pb): return max(50, min(150, 100 - mdr(HS, pb, 100)))

print("="*102)
print("6. EXPECTED HITS PER TURN  (12 AP, shooting stance paid once, 1 AP per aim level)")
print("   Handling ON sigma_0 = 100 - 1.5 x PBbonus.  Marks 90, HE 100, standing torso.")
print("="*102)
for dist in (5, 10, 16, 24, 32):
    print(f"  --- {dist} tiles ---   {'':<20}" + "".join(f"{'aim '+str(n):>12}" for n in range(1, 7)))
    for name, shoot, stance, R, acc, pb, mx in W:
        hm = hmul(pb)
        cells = []
        for n in range(1, 7):
            cost = shoot + n
            shots = (AP - stance) // cost
            c, _, _ = cth(dist, R, acc, marks=90, aim=n, he=100, handling_mul=hm)
            cells.append(f"{shots}x{c:>2}%={shots*c/100:>4.2f}")
        best = max(range(6), key=lambda i: float(cells[i].split('=')[1]))
        out = "".join(("["+c+"]" if i == best else " "+c+" ") for i, c in enumerate(cells))
        print(f"    {name:<16}hdl={hm:>4} sh/st={shoot}/{stance}" + out)
    print()

print("="*102)
print("7. THE SCOPE CHERRY: extra AimAccuracy at high levels vs. a floor multiplier")
print("   M24 (range 32, acc 9, Marks 90).  d50 in tiles; base = no scope, 3 aim levels.")
print("="*102)
def d50(sg): return (42*34380/SLAB)/((k_for_cth(50)/1000.0)*sg)
variants = [
    ("no scope, aim<=3",              None, 100, 3),
    ("+2 levels only",                None, 100, 5),
    ("+2 lvl, +8 acc from lvl 5",     [{"from":5,"to":None,"acc":8}], 100, 5),
    ("+2 lvl, +3 acc from lvl 3",     [{"from":3,"to":None,"acc":3}], 100, 5),
    ("+2 lvl, floor x87",             None,  87, 5),
    ("+2 lvl, +3 acc from 3, flr x87",[{"from":3,"to":None,"acc":3}], 87, 5),
]
for label, sc, fm, mx in variants:
    q = P(); q.FloorPct = mdr(p.FloorPct, fm, 100)
    row = []
    for n in range(0, 7):
        if n > mx: row.append(f"{'-':>8}"); continue
        sg, _, _, _ = sigma(32, 9, marks=90, aim=n, he=100, scope=sc, p=q)
        row.append(f"{d50(sg):>8.1f}")
    print(f"  {label:<34}" + "".join(row))
print(f"  {'':<34}" + "".join(f"{'aim '+str(n):>8}" for n in range(0, 7)))
print("  -> +8 acc at level 5 moves d50 by ~1 tile: at level 5 only ~2% of the gap is left to close.")
print("     A floor multiplier is the only thing that moves the CEILING, and it is invisible at low aim.")
