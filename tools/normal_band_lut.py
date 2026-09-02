#!/usr/bin/env python3
"""Meia-faixa normal para o CTH separavel: 1000 * (Phi(z) - 0.5), z = i * STEP/1000.

O modelo separavel troca o circulo equivalente em area por P = Px*Py, e cada eixo e a massa
normal entre duas meias-extensoes. Sem float no jogo, isso vira LUT em permil.
"""
from math import erf, sqrt

STEP = 125          # 0.125 sigma por passo, mesmo idioma de A.RayleighStep
N = 32              # ate z = 4.0; Phi(4) - 0.5 ja satura em 500 permil

vals = [round(500.0 * erf((i * STEP / 1000.0) / sqrt(2.0))) for i in range(N + 1)]

# monotonica e saturando, senao a interpolacao inverteria em algum ponto
assert all(b >= a for a, b in zip(vals, vals[1:])), vals
assert vals[0] == 0 and vals[-1] == 500, vals

# k = 1 tem de reproduzir a faixa de 1 sigma (68.27%)
assert abs(2 * vals[8] - 683) <= 1, vals[8]

out = ["A.NormalStep = %d" % STEP, "A.NormalBand = {"]
line = "    [0] = 0,"
for i in range(1, N + 1):
    piece = " %d," % vals[i]
    if len(line) + len(piece) > 98:
        out.append(line)
        line = "   "
    line += piece
out.append(line)
out.append("}")
print("\n".join(out))
print()
print("-- conferencia: 2*banda em k=1,2,3 = %d %d %d permil (esperado 683 954 997)"
      % (2 * vals[8], 2 * vals[16], 2 * vals[24]))
