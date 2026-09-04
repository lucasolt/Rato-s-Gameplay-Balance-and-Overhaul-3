---------------------------------------------------------------------------------------------------
---- Recoil no modelo angular: SUBIDA DO CANO por tiro, e a chance de o atirador segura-la.
----
---- O modelo somado vira `cth_loss_per_shot` e subtrai pontos em linha
---- (SOURCE_FirearmGetAttackResults.lua:260). O modelo de cone anterior alargava o cone. Nenhum
---- dos dois e recuo: recuo nao espalha o grupo em volta do alvo, ele LEVANTA o cano numa direcao
---- e a rajada anda por ali. E o que a vanilla desenha em Firearm:CalcShotVectors (Weapon.lua:1612),
---- so que la e enfeite -- acerto e erro ja tinham sido sorteados. Aqui a bala e a verdade, entao a
---- caminhada precisa vir com a probabilidade que lhe corresponde (Rat_SimRecoilLadder).
----
---- A cadeia tunada se parte em DOIS papeis, sem recopiar constante nenhuma:
----   arma  = mod / control -- cano, mecanismo, cartucho, ROF, deltas de rajada: quanto sobe
----   control              -- Marksmanship, postura, bipe, Forca vs breakpoint, perks: o atirador
---- e `control` deixa de ser um desconto garantido e vira CHANCE de o tiro sair controlado:
----     chance = 100 - control    (control 0.65 -> 35% dos tiros nao sobem)
---- A media sobrevive intacta -- gun * (1 - chance) = mod -- entao toda a escala ja tunada continua
---- valendo; o que muda e a variancia, e ela entra no CTH pelo segundo momento, nao a esmo.
---- Um atirador de moeda-ao-ar fica pior que um confiavel de mesma media, que e o certo.
----
---- A distancia continua mandando, pela via correta: a mesma subida custa pouco de perto, onde a
---- silhueta e maior que ela, e muito de longe. Nao precisa de rampa tabelada -- emerge de theta ~ 1/d.
----
---- Retorna a subida por tiro em MINUTOS de angulo e a chance de controle em % (0..100).
---------------------------------------------------------------------------------------------------
---- Modo "growth" (A.RecoilMode): o recuo ALARGA o cone por tiro em vez de levantar o cano.
---- Retorna o multiplicador de sigma por tiro em % (100 = sem recuo).
function Rat_GetRecoilConeGrowth(attacker, action, weapon, num_shots, test)
    local a = const.Combat.Aperture
    if not attacker or not IsKindOf(weapon, "Firearm") then
        return 100
    end

    local mod = Rat_GetRecoilBaseMod(attacker, action, weapon, num_shots)

    ---- cadencia: mais tiros no mesmo tempo, menos tempo para reassentar a arma
    if not IsKindOf(weapon, "Shotgun") then
        local action_id_rof = (action and action.id) or ""
        if action_id_rof == "GrizzlyPerk" then
            action_id_rof = "MGBurstFire"
        end
        local ROF = Rat_GetROF(weapon, action_id_rof)
        if ROF and ROF > 1 then
            mod = mod * ROF
        end
    end

    ---- MG montada absorve recoil; MG na mao, nao
    local aid = action and action.id
    if aid == "MGBurstFire" then
        if test or (g_Overwatch[attacker] and g_Overwatch[attacker].permanent) then
            mod = mod * const.Combat.Recoil.MGSetupMul
        end
    elseif aid == "GrizzlyPerk" then
        mod = mod * const.Combat.Recoil.MGSetupMul
    end

    local excess = Clamp(MulDivRound(a.RecoilGrowthBase, cRound(mod), 100), 0, a.RecoilGrowthMax)
    excess = MulDivRound(excess, const.Combat.R_Recoil or 100, 100)
    return 100 + excess
end

---- `control` em BASE 100 (recuo que o atirador NAO cancelou; 100 = nao cancela nada) -> chance de
---- segurar o cano, em %. O mapa antigo era chance = 100 - control, e control real so anda entre 85
---- e 117: a chance nunca passava de 15% e o lado estocastico era decorativo. Pivot/Gain esticam a
---- MESMA faixa; Pivot 100 / Gain 100 reproduz o mapa antigo exatamente.
function Rat_RecoilHoldChance(control)
    local a = const.Combat.Aperture
    return Clamp(MulDivRound(a.RecoilControlGain or 100,
                             (a.RecoilControlPivot or 100) - (control or 100), 100),
                 0, a.RecoilControlMax or 90)
end

function Rat_GetRecoilClimb(attacker, action, weapon, num_shots, test)
    local a = const.Combat.Aperture
    if not attacker or not IsKindOf(weapon, "Firearm") then
        return 0, 0
    end

    local mod, _, control = Rat_GetRecoilBaseMod(attacker, action, weapon, num_shots)

    ---- control > 100 (Marks baixa, Forca abaixo do breakpoint) nao e "controle negativo": e a ARMA
    ---- subindo mais. O clamp sozinho DESCARTAVA esse excesso -- cortava antes da divisao e a
    ---- penalidade de estar abaixo do breakpoint nunca chegava ao climb. Agora o excesso e
    ---- separado e multiplica a arma, que e o que o paragrafo acima sempre disse que fazia.
    local excess = Max(100, control)
    control = Min(control, 100)

    local chance = Rat_RecoilHoldChance(control)

    ---- gun is the kick a LOST shot delivers, and nothing more. It used to be divided by (1-chance)
    ---- so the mean stayed at `mod` whatever the hold map said -- but that inflated the kick of the
    ---- mercs who hold most, so the best shooter had the wildest single shot. Skill now lowers the
    ---- kick (via mod) AND raises the hold chance; the mean is no longer pinned, it just falls.
    local gun = mod * excess / 100.00

    ---- cadencia: mais tiros no mesmo tempo, menos tempo para reassentar a arma
    if not IsKindOf(weapon, "Shotgun") then
        local action_id_rof = (action and action.id) or ""
        if action_id_rof == "GrizzlyPerk" then
            action_id_rof = "MGBurstFire"
        end
        local ROF = Rat_GetROF(weapon, action_id_rof)
        if ROF and ROF > 1 then
            gun = gun * ROF
        end
    end

    ---- MG montada absorve recoil; MG na mao, nao. E apoio do atirador -> entra no controle.
    ---- Sobe SO a chance, sem refazer o gun: aqui a media cai de verdade, que e o beneficio.
    local aid = action and action.id
    if aid == "MGBurstFire" then
        if test or (g_Overwatch[attacker] and g_Overwatch[attacker].permanent) then
            chance = Rat_RecoilHoldChance(cRound(control * const.Combat.Recoil.MGSetupMul))
        end
    elseif aid == "GrizzlyPerk" then
        chance = Rat_RecoilHoldChance(cRound(control * const.Combat.Recoil.MGSetupMul))
    end

    local climb = MulDivRound(a.RecoilClimbBase, cRound(gun), 100)
    climb = Clamp(climb, 0, a.RecoilClimbMax)

    ---- o dial global de recoil do jogador continua valendo
    climb = MulDivRound(climb, const.Combat.R_Recoil or 100, 100)

    return climb, chance
end