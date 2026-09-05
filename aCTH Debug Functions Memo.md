

----------------------------

`count` = amostras independentes do mesmo tiro, nao uma rajada. Tiro inspecionado = (shot_idx, burst), padrao 1 de 1. 3o tiro de uma rajada de 6: Rat_DbgShots(150, 2, nil, nil, nil, 3, 6).

```lua
Rat_DbgShots(count, aim, target_spot, target, attacker, shot_idx, burst)
Rat_DbgShots(100, 3, "Torso")
```

----------------------------

RAJADAS inteiras, nao tiros avulsos: `bursts` rajadas de `burst` tiros, taxa de acerto por INDICE de tiro. Rat_DbgShots reamostra o eixo do recuo a cada tiro; aqui cada rajada tem UM eixo, como no jogo -- e a diferenca aparece na correlacao entre tiros da mesma rajada, que e justamente o que a caminhada do cano introduziu. 100 rajadas de 3: Rat_DbgBurst(100, 3, 1). Desenha a ULTIMA rajada, para ver um risco.

```lua
Rat_DbgBurst(bursts, burst, aim, target_spot, target, attacker)
```
```lua
Rat_DbgBurst(20, 3, 3, "Torso")
```

----------------------------

Desenha o ultimo ataque real. Nao sorteia: le g_RatLastSimShots (gravado por Firearm:GetAttackResults). `rings` = um anel por tiro em vez de um so.
```lua
Rat_DbgLastShots(rings)
```

----------------------------

Devolve o resumo e um segundo valor `ok` -- o modo mouse usa `ok` para limpar quando o ponto
deixa de ser desenhavel, senao o desenho velho fica congelado na tela mentindo.
```lua
Rat_DbgRecoilAt(pos, burst, aim, action_id, attacker, over)
Rat_DbgRecoilAt{burst=..., ...}
```

----------------------------


UMA rajada de verdade, sorteada com a arma e a pericia de quem esta selecionado: um vetor por tiro, do cano ate onde a bala para. O tiro 1 vai EXATO no ponto apontado -- e a referencia contra a qual os coices se leem; com `scatter` o cone da arma tambem entra e ele deixa de ser exato (a rajada completa, como o jogo dispara). Sem alvo sob o cursor o cone e o de Rat_GetAperture, sem os residuais -- que exigem alvo.
Aceita tambem uma tabela unica: Rat_DbgRecoilShots{burst = 10, chance = 0, scatter = true}.

```lua
Rat_DbgRecoilShots(burst, aim, scatter, pos, action_id, attacker, over)
```
```lua
Rat_DbgRecoilShots(3, 3, false)
```


----------------------------

Liga/desliga o modo que segue o mouse. Aceita tabela unica -- Rat_DbgRecoilMouse{shots = true, chance = 0}. Posicional: Rat_DbgRecoilMouse(burst, aim, action_id, shots, scatter, over): sem `shots` desenha o modelo deterministico, previsao pura (um raycast de LoF por quadro, o mesmo que o crosshair ja faz) -- nao encosta no random. Com `shots` desenha rajadas sorteadas de verdade, e ai SIM consome random sincronizado.
```lua
Rat_DbgRecoilMouse(burst, aim, action_id, shots, scatter, over)
Rat_DbgRecoilMouse(3, 3, nil, true)

```

----------------------------

