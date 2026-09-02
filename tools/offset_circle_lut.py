"""Gera a LUT do circulo DESLOCADO (Rice / Marcum Q1) para A.OffsetCircle.

CTH de um tiro cujo centro de mira foi deslocado `mu` pelo recuo:
    P(R <= theta) = integral_0^k r * exp(-(r^2+m^2)/2) * I0(r*m) dr
com k = theta/sigma e m = mu/sigma. Em m = 0 reduz a Rayleigh, que e a tabela que ja existe.
"""
import textwrap

import numpy as np

K_STEP, K_MAX = 0.25, 8.0
M_STEP, M_MAX = 0.5, 8.0

ks = np.arange(0.0, K_MAX + 1e-9, K_STEP)
ms = np.arange(0.0, M_MAX + 1e-9, M_STEP)


def cdf_row(m):
    """P(k, m) para todo k da grade, por integracao de Simpson fina."""
    out = []
    for k in ks:
        if k <= 0:
            out.append(0.0)
            continue
        n = 4000
        r = np.linspace(0.0, k, n + 1)
        f = r * np.exp(-(r * r + m * m) / 2.0) * np.i0(r * m)
        w = np.ones(n + 1)
        w[1:-1:2], w[2:-1:2] = 4.0, 2.0
        out.append(float(np.sum(w * f) * (k / n) / 3.0))
    return out


rows = [cdf_row(m) for m in ms]

# sanidade: m = 0 tem de reproduzir Rayleigh
ray = 1.0 - np.exp(-(ks ** 2) / 2.0)
err = np.max(np.abs(np.array(rows[0]) - ray))
assert err < 1e-6, err
print("m=0 x Rayleigh: erro max %.2e" % err)

lines = []
for m, row in zip(ms, rows):
    vals = [str(int(round(min(max(v, 0.0), 1.0) * 1000))) for v in row]
    # primeiro elemento explicito em [0], como A.Rayleigh: o indice E o passo de k
    vals[0] = "[0] = " + vals[0]
    head = "    [%d] = {" % int(round(m / M_STEP))
    body = textwrap.wrap(", ".join(vals), width=99 - len(head),
                         break_long_words=False, break_on_hyphens=False)
    sep = chr(10) + " " * len(head)
    lines.append(head + sep.join(body) + "},")

print("\nA.OffsetCircleKStep = %d" % int(K_STEP * 1000))
print("A.OffsetCircleMStep = %d" % int(M_STEP * 1000))
print("A.OffsetCircle = {")
print("\n".join(lines))
print("}")
