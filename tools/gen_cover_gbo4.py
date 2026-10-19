import math, random, sys

out = sys.argv[1]
W = H = 1024
BG, BONE, AMBER, RED = "#121212", "#E6E0D2", "#E39B32", "#A8432F"

# Shot frame: muzzle at origin, axis +x, rotated onto the canvas diagonal.
MX, MY, TX, TY = 150, 860, 770, 270
L = math.hypot(TX - MX, TY - MY)
ANG = math.degrees(math.atan2(TY - MY, TX - MX))
FULL = 0.15   # outer cone half-angle (tan)
CORE = 0.05   # 50% contour half-angle (tan)

rnd = random.Random(42)
p = []
a = p.append

a(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
a('<defs>')
a('<pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse">'
  f'<path d="M32 0H0V32" fill="none" stroke="{BONE}" stroke-width="1" opacity="0.045"/></pattern>')
a('<radialGradient id="vig" cx="50%" cy="45%" r="75%">'
  '<stop offset="55%" stop-color="#000" stop-opacity="0"/><stop offset="100%" stop-color="#000" stop-opacity="0.6"/></radialGradient>')
a(f'<linearGradient id="coreGrad" x1="0" y1="0" x2="1" y2="0">'
  f'<stop offset="0" stop-color="{AMBER}" stop-opacity="0.15"/><stop offset="0.35" stop-color="{AMBER}" stop-opacity="0.85"/>'
  f'<stop offset="0.86" stop-color="{AMBER}" stop-opacity="0.9"/><stop offset="1" stop-color="{AMBER}" stop-opacity="0"/></linearGradient>')
a('<filter id="feather" x="-10%" y="-30%" width="120%" height="160%"><feGaussianBlur stdDeviation="5"/></filter>')
a('<filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="14"/></filter>')
a('</defs>')
a(f'<rect width="{W}" height="{H}" fill="{BG}"/>')
a(f'<rect width="{W}" height="{H}" fill="url(#grid)"/>')

a(f'<g transform="translate({MX},{MY}) rotate({ANG:.3f})">')
R = L + 90
# Outer cone: hairlines only.
a(f'<path d="M0 0L{R:.0f} {-R*FULL:.1f}M0 0L{R:.0f} {R*FULL:.1f}" stroke="{AMBER}" stroke-width="1.5" opacity="0.45" fill="none"/>')
a(f'<path d="M0 0L{R:.0f} {-R*FULL:.1f}L{R:.0f} {R*FULL:.1f}Z" fill="{AMBER}" opacity="0.05"/>')
# 50% contour: soft halo + solid wedge.
core = f'M0 0L{R:.0f} {-R*CORE:.1f}L{R:.0f} {R*CORE:.1f}Z'
a(f'<path d="{core}" fill="{AMBER}" opacity="0.35" filter="url(#glow)"/>')
a(f'<path d="{core}" fill="url(#coreGrad)" filter="url(#feather)"/>')
a(f'<path d="{core}" fill="url(#coreGrad)" opacity="0.6"/>')

# Range rings as dashed arcs across the outer cone.
for i, d in enumerate(range(140, int(R), 140)):
    h = d * FULL
    a(f'<path d="M{d:.0f} {-h:.1f}Q{d+h*0.12:.1f} 0 {d:.0f} {h:.1f}" stroke="{BONE}" stroke-width="1" opacity="0.28" fill="none" stroke-dasharray="3 5"/>')
    a(f'<text x="{d+4}" y="{h+16:.0f}" font-family="Consolas,monospace" font-size="12" fill="{BONE}" opacity="0.45">{(i+1)*4}m</text>')

# Blocked cells (cover cuts) on the near side of the outer ring.
for k in range(3):
    d0, d1 = 470 + k * 26, 490 + k * 26
    y0, y1 = d0 * CORE + 6, d0 * FULL
    a(f'<path d="M{d0} {y0:.1f}L{d1} {d1*CORE+6:.1f}L{d1} {d1*FULL:.1f}L{d0} {y1:.1f}Z" fill="{RED}" opacity="0.75"/>')

# Target: top-down silhouette, facing the shooter.
tx = L
a(f'<g fill="{BONE}">'
  f'<ellipse cx="{tx+4:.0f}" cy="-46" rx="11" ry="15"/>'
  f'<ellipse cx="{tx+4:.0f}" cy="46" rx="11" ry="15"/>'
  f'<ellipse cx="{tx:.0f}" cy="0" rx="21" ry="50"/>'
  f'</g>')
a(f'<circle cx="{tx-2:.0f}" cy="0" r="17" fill="{BONE}" stroke="{BG}" stroke-width="3"/>')

# Single-shot scatter: Gaussian around the aim point.
for _ in range(13):
    x = tx + rnd.gauss(0, 20)
    y = rnd.gauss(0, 34)
    a(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="4" fill="{BG}" stroke="{BONE}" stroke-width="1.5"/>')
# Head hit.
a(f'<circle cx="{tx-4:.0f}" cy="3" r="5" fill="{RED}" stroke="{BG}" stroke-width="2"/>')

# Burst: recoil climbs off-axis with each round.
prev = None
for n in range(6):
    x = tx - 30 + n * 26 + rnd.gauss(0, 3)
    y = -62 - n * n * 4 - n * 9 + rnd.gauss(0, 3)
    if prev:
        a(f'<line x1="{prev[0]:.1f}" y1="{prev[1]:.1f}" x2="{x:.1f}" y2="{y:.1f}" stroke="{AMBER}" stroke-width="1" opacity="0.5" stroke-dasharray="2 3"/>')
    a(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{3.5 + n*0.3:.1f}" fill="{AMBER}" opacity="{1 - n*0.12:.2f}"/>')
    prev = (x, y)

# Muzzle.
a(f'<circle r="5" fill="{BONE}"/><circle r="13" fill="none" stroke="{BONE}" stroke-width="1" opacity="0.5"/>')
a('</g>')

# Range-card annotations.
mono = 'font-family="Consolas,monospace" font-size="15" letter-spacing="1"'
def note(x, y, txt, op=0.6, anchor="start"):
    a(f'<text x="{x}" y="{y}" {mono} fill="{BONE}" opacity="{op}" text-anchor="{anchor}">{txt}</text>')
def leader(x1, y1, x2, y2):
    a(f'<polyline points="{x1},{y1} {x2},{y2}" stroke="{BONE}" stroke-width="1" opacity="0.4" fill="none"/>')

note(64, 84, "FIG. 4 — SINGLE SHOT, AIM 3/3", 0.7)
note(64, 106, "AIMED CONE / SIMULATED RECOIL", 0.45)
a(f'<line x1="64" y1="122" x2="380" y2="122" stroke="{BONE}" stroke-width="1" opacity="0.25"/>')
note(840, 150, "σ 2.4°", 0.65); leader(836, 148, 850, 228)
note(870, 360, "d50 14m", 0.65); leader(866, 355, 822, 320)
note(560, 220, "RECOIL +0.8°/RD", 0.65, "end"); leader(565, 212, 700, 182)
note(680, 610, "BLOCKED", 0.65); leader(676, 604, 590, 548)
note(176, 900, "MUZZLE", 0.5)

# Title block.
a(f'<line x1="560" y1="742" x2="960" y2="742" stroke="{BONE}" stroke-width="1" opacity="0.25"/>')
note(960, 728, "GAMEPLAY BALANCE &amp; OVERHAUL", 0.6, "end")
title = 'font-family="Barlow Condensed,Bahnschrift,Arial Narrow,sans-serif" font-weight="700" font-stretch="condensed"'
a(f'<text x="960" y="948" {title} font-size="236" letter-spacing="-4" text-anchor="end">'
  f'<tspan fill="{BONE}">GBO</tspan><tspan dx="18" fill="{AMBER}">4</tspan></text>')
note(960, 980, "JAGGED ALLIANCE 3 · RATO", 0.4, "end")

a(f'<rect width="{W}" height="{H}" fill="url(#vig)"/>')
a('</svg>')

open(out, "w", encoding="utf-8").write("\n".join(p))
