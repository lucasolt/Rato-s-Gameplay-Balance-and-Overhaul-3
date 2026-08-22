function place_hipfire_cth()
    PlaceObj('ChanceToHitModifier', {
        CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof,
                             aim, opportunity_attack, attacker_pos, target_pos)

            if not action then
                return false, 0
            end

            local side = attacker and attacker.team and attacker.team.side or ''

            if not IsKindOf(weapon1, "Firearm") and action.id ~= "KnifeThrow" then
                return false, 0
            end

            if action.id == "PinDown" then
                return false, 0
            end

            if action.id == "AutoFire" and (HasPerk(attacker, "shooting_stance") or aim > 0) and
                not opportunity_attack then
                return false, 0
            end

            ---------------------------------------------------------------------------------------------------------
            ---- MGSetup / MGRotate: a PREVISAO tem que medir o tiro que a arma vai fazer de verdade.
            ----
            ---- Uma MG montada dispara por interrupcao, e o ramo de interrupcao ja existe aqui
            ---- embaixo -- curva propria de distancia (MGInterruptMaxDist / MGInterruptBasePenalty)
            ---- vezes MGSetupInterruptMul. So que ele so e alcancado com `opportunity_attack`, e a
            ---- previsao chega sem. Resultado: previa-se um snapshot comum, com a curva de 40
            ---- tiles, no alcance em que a MG e mandada cobrir (o cone dela usa o WeaponRange
            ---- INTEIRO, 34-40 tiles).
            ----
            ---- O tiro REAL ja entra aqui com opportunity_attack = true, entao ele nao muda nada.
            ---- Quem muda e so quem pergunta "quanto eu acertaria se montasse".
            ----
            ---- Quem mais depende disso: o AIPrecalcConeTargetZones (source) descarta do cone todo
            ---- alvo com `chance_to_hit == 0`. Medido no processo vivo, MG42 a 22 m: -58 como
            ---- snapshot comum (CTH 2), -32 como interrupcao de MG (CTH 19). Com o -58, a IA
            ---- perdia o cone inteiro e o MGSetup sumia da lista de signature actions.
            ----
            ---- O `aim = Max(aim, 1)` continua aqui pelo mesmo motivo de antes: o
            ---- GetWeaponHipfireOrSnapshotMul desvia por `aim == 0` (hipfire) vs `aim > 0`
            ---- (snapshot), e montar a arma nao e tiro de quadril.
            ---------------------------------------------------------------------------------------------------------

            if action.id == "MGSetup" or action.id == "MGRotate" then
                aim = Max(aim, 1)
                opportunity_attack = true
            end

            local actions_that_use_snapshot_always = {"Overwatch", "MobileShot", "RunAndGun"}

            if aim > 0 and
                (not table.find(actions_that_use_snapshot_always, action.id) and target and
                    attacker:GetLastAttack() == target) and not opportunity_attack then
                return false, 0
            end

            if aim > 2 then
                return false, 0
            end

            ------

            local metaText = {}

            local dist = (attacker_pos and target_pos and attacker_pos:Dist(target_pos)) or
                             (attacker and target and attacker:GetDist(target))

            ---------------------------

            local weapon = weapon1

            local penalty = 1.0

            if opportunity_attack or attacker:HasStatusEffect("shooting_stance") or
                attacker:HasStatusEffect("ManningEmplacement") or
                attacker:HasStatusEffect("StationedMachineGun") then
                aim = Max(1, aim)
            end

            if action.id == "Overwatch" then
                aim = Max(1, aim)
            end

            if g_Overwatch[attacker] and g_Overwatch[attacker].permanent then
                aim = Max(1, aim)
            end

            local display = false

            local wep_hip_penal, wep_meta = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action,
                                                                          display, aim)

            if action and action.id == "DualShot" then
                weapon = weapon2
                local wep_hip_penal2 = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action,
                                                                     display, aim)
                weapon = weapon1
                wep_hip_penal = (wep_hip_penal + wep_hip_penal2) / 2
                wep_meta = {T {392849416519, "Average: Two Weapons"}}
            end

            penalty = penalty * wep_hip_penal

            for i, text in ipairs(wep_meta) do
                table.insert(metaText, text)
            end

            local reflex_s = 1.0
            local ratio

            if action.id == "BurstFire" then
                ratio = attacker.Strength / rGetReflex(attacker)
            end

            if not opportunity_attack and aim < 1 and
                ((action.id == "BuckshotBurst" or action.id == "MGBurstFire" or action.id ==
                    "GrizzlyPerk" or action.id == "AutoFire") or (ratio and ratio > 1)) then
                local reflex = attacker.Strength

                local min = 0.65
                local max = 1.35
                reflex_s = max - (max - min) * reflex / 100

                if reflex_s >= 1.00 then
                    metaText[#metaText + 1] = T {221848738467, "Low Strength"}
                elseif reflex_s <= 0.80 then
                    metaText[#metaText + 1] = T {413925295955, "High Strength"}
                else
                    metaText[#metaText + 1] = T {278838794679, "Strength"}
                end
            else
                local reflex = rGetReflex(attacker)

                local min = 0.65
                local max = 1.35
                reflex_s = max - (max - min) * reflex / 100

                if reflex_s >= 1.00 then
                    metaText[#metaText + 1] = T {645785968721, "Low Reflexes"}
                elseif reflex_s <= 0.80 then
                    metaText[#metaText + 1] = T {433649794796, "High Reflexes"}
                else
                    metaText[#metaText + 1] = T {253999664478, "Reflexes"}
                end
            end

            local max_dist = const.Combat.Hipfire.MaxDistforPenalty * const.SlabSizeX
            local max_penal = const.Combat.Hipfire.MaxPenalty

            local hip_penal = Min(0, MulDivRound(dist, max_penal, max_dist))

            local weapon_ref = reflex_s * penalty * 100
            local base_penal1 = const.Combat.Hipfire.BasePenalty
            local base_penal

            if not (side == 'player1' or side == 'player2') then
                weapon_ref = AIpenal_reduc(attacker, weapon_ref)
            end

            if action.id == "GrizzlyPerk" then
                weapon_ref = weapon_ref * 0.4
                base_penal1 = cRound(base_penal1 / 2)
                metaText[#metaText + 1] = "Off the Hip"
            end

            base_penal = MulDivRound(dist, base_penal1, 16 * const.SlabSizeX)

            if base_penal < base_penal1 then
                base_penal = base_penal1
            elseif base_penal > cRound(base_penal1 / 2) then
                base_penal = cRound(base_penal1 / 2)
            end

            local mobile_shot_penal = 0

            if action and action.id == "MobileShot" then
                mobile_shot_penal = -8
            end

            local name = T(588769789298, "Hipfire")
            local snap_name = T(335346378867, "Snapshot")

            if action and action.id == "KnifeThrow" then
                name = T(941222879324, "Quick Throw")
                snap_name = name
                if aim > 0 then
                    return false, 0
                end
            end

            if aim > 0 and aim < 3 then
                max_dist = const.Combat.Snapshot.MaxDistforPenalty * const.SlabSizeX
                max_penal = const.Combat.Snapshot.MaxPenalty

                base_penal1 = const.Combat.Snapshot.BasePenalty

                ---- MG em interrupcao usa uma curva de distancia propria: rampa muito mais
                ---- longa, componente fixo muito maior. O patamar geral fica parecido com o
                ---- de antes, mas espalhado -- a distancia deixa de ser o que decide o tiro.
                ----
                ---- Motivo: o cone de overwatch da MG e o unico que usa o WeaponRange
                ---- INTEIRO (34 a 40 tiles); as outras classes usam 75% dele, por
                ---- Firearm:GetOverwatchConeParam. Com a rampa padrao terminando em 40, a MG
                ---- pagava quase a penalidade maxima na borda do proprio cone -- justo o
                ---- alcance que o jogo manda ela cobrir.
                ----
                ---- Esticar a rampa sozinho nao serviria: ela e linear a partir do zero,
                ---- entao alongar o teto abaixa a curva INTEIRA na mesma proporcao, perto
                ---- inclusive. Quem segura a ponta curta e o base_penal, que nao depende da
                ---- distancia. Por isso os dois andam juntos aqui.
                if opportunity_attack and IsKindOf(weapon1, "MachineGun") then
                    max_dist = const.Combat.Snapshot.MGInterruptMaxDist * const.SlabSizeX
                    base_penal1 = const.Combat.Snapshot.MGInterruptBasePenalty
                    metaText[#metaText + 1] = T {519274638150, "Prepared Machine Gun"}
                end

                base_penal = MulDivRound(dist, base_penal1, 16 * const.SlabSizeX)

                if base_penal < base_penal1 then
                    base_penal = base_penal1
                elseif base_penal > cRound(base_penal1 / 2) then
                    base_penal = cRound(base_penal1 / 2)
                end

                local snap_penal = Min(0, MulDivRound(dist, max_penal, max_dist))

                snap_penal = MulDivRound(snap_penal, weapon_ref, 100) + base_penal

                if opportunity_attack then
                    if (g_Overwatch[attacker] and g_Overwatch[attacker].permanent) or action and
                        action.id == "MGSetup" then
                        snap_penal = MulDivRound(snap_penal,
                                                 const.Combat.Snapshot.MGSetupInterruptMul, 100)
                    else
                        snap_penal =
                            MulDivRound(snap_penal, const.Combat.Snapshot.InterruptMul, 100)
                    end
                end

                if aim == 2 then
                    snap_penal = MulDivRound(snap_penal, 25, 100)
                end

                snap_penal = snap_penal + mobile_shot_penal
                return true, snap_penal, snap_name, #metaText ~= 0 and metaText
            end

            hip_penal = MulDivRound(hip_penal, weapon_ref, 100) + base_penal

            if dist < const.Weapons.PointBlankRange * const.SlabSizeX then
                hip_penal = MulDivRound(hip_penal, 90, 100)
            end

            hip_penal = hip_penal + mobile_shot_penal

            return true, hip_penal, name, #metaText ~= 0 and metaText
        end,
        RequireTarget = true,
        display_name = T(145534626581, "Hipshot Penalty"),
        group = "Default",
        id = "HipshotPenalty"
    })

end

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [588769789298] = "Hipfire",
    [335346378867] = "Snapshot",
    [941222879324] = "Quick Throw",
    [145534626581] = "Hipshot Penalty",
    [392849416519] = "Average: Two Weapons",
    [221848738467] = "Low Strength",
    [413925295955] = "High Strength",
    [278838794679] = "Strength",
    [645785968721] = "Low Reflexes",
    [433649794796] = "High Reflexes",
    [253999664478] = "Reflexes",
    [519274638150] = "Prepared Machine Gun"
}

ratG_T_table['CTH_shooting_stance_hipfire.lua'] = t_id_table
