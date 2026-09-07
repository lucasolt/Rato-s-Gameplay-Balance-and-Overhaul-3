function OnMsg.ClassesGenerate(classdefs)

    if classdefs.RelentlessAdvance then
        classdefs.RelentlessAdvance.unit_reactions = {

            PlaceObj('UnitReaction', {
                Event = "OnCalcFreeMove",
                Handler = function(self, target, data)
                    if target:IsUsingCover() then
                        data.mul = MulDivRound(data.mul,
                                               const.Combat.Perks.RelentlessAdvanceFreeMoveMul, 100)
                    end
                end
            })
        }
    end

    if classdefs.SteadyBreathing then
        classdefs.SteadyBreathing.unit_reactions = {
            PlaceObj('UnitReaction', {
                Event = "OnCalcFreeMove",
                Handler = function(self, target, data)

                    -----
                    if not R_IsAI(target) then
                        return
                    end
                    -----

                    local armourItems = target:GetEquipedArmour()
                    for _, item in ipairs(armourItems) do
                        if item.PenetrationClass > 2 then
                            return
                        end
                    end
                    data.add = data.add + self:ResolveValue("freeMoveBonusAp")
                end
            })
        }
    end

    if classdefs.FreeMove then
        classdefs.FreeMove.OnAdded = ------- 
        function(self, obj)
            if not IsKindOf(obj, "Unit") then
                return
            end
            local cur_free_ap = obj.free_move_ap
            ------
            local free_ap = Max(0, 1000 + MulDivRound(obj.Agility - 60, const.Scale.AP, 5))
            ------
            local data = {min = 0, max = 999, add = 0, mul = 100}
            if obj.team and obj.team.player_enemy then
                ------
                local diff_mul =
                    GameDifficulties[Game.game_difficulty]:ResolveValue("freeMoveBonus") or 0
                diff_mul = 100 +
                               MulDivRound(diff_mul, CurrentModOptions.VanillaFreeMoveBonus or 100,
                                           100)
                data.mul = diff_mul
                -----
            end
            obj:CallReactions("OnCalcFreeMove", data)
            free_ap = MulDivRound(free_ap + data.add * const.Scale.AP, data.mul, 100)
            free_ap = Clamp(free_ap, data.min * const.Scale.AP, data.max * const.Scale.AP)
            if IsGameRuleActive("HeavyWounds") then
                local wounds = obj:GetStatusEffect("Wounded")
                if wounds and wounds.stacks >= 1 then
                    local max_wounds = GameRuleDefs.HeavyWounds:ResolveValue("MaxWoundsEffect")
                    local per_wound_percent = GameRuleDefs.HeavyWounds:ResolveValue("FreeMoveLost")
                    free_ap = Max(0, free_ap -
                                      MulDivRound(free_ap, Min(wounds.stacks, max_wounds) *
                                                      per_wound_percent, 100))
                end
            end

            local prev_ap = obj.ActionPoints
            obj:GainAP(free_ap - cur_free_ap)
            if obj.ActionPoints > prev_ap then -- gain can be blocked by certain statuses and conditions
                obj.free_move_ap = free_ap
                Msg("UnitAPChanged", obj)
                ObjModified(obj)
            end
        end
        -------		
    end

    if classdefs.Psycho then
        local reac = classdefs.Psycho.unit_reactions
        for i, react in ipairs(reac) do
            if react.Event == "OnFirearmAttackStart" then
                react.Handler = function(self, target, attacker, attack_target, action, attack_args)
                    if target == attacker and
                        (action.id == "SingleShot" or action.id == "BurstFire") then
                        if attacker:Random(100) < self:ResolveValue("procChance") then
                            local weapon = action:GetAttackWeapons(attacker)
                            if action.id == "SingleShot" and
                                table.find(weapon.AvailableAttacks, "BurstFire") then
                                attack_args.replace_action = "BurstFire"
                                PlayVoiceResponse(attacker, "Psycho")
                            elseif action.id == "BurstFire" and
                                table.find(weapon.AvailableAttacks, "AutoFire") then
                                attack_args.replace_action = "AutoFire"
                                -----
                                attack_args.num_shots =
                                    attacker:GetActiveWeapons():GetAutofireShots(
                                        CombatActions[attack_args.replace_action]) or
                                        attack_args.num_shots
                                -----
                                PlayVoiceResponse(attacker, "Psycho")
                            end
                        end
                    end
                end
            end
        end
    end

    -- if classdefs.ExtraOverwatchShots then
    -- local reac = ExtraOverwatchShots.unit_reactions
    -- for i, react in ipairs(reac) do
    -- if react.Event == "OnCalcOverwatchAttacks" then
    -- react.Handler =  = function (self, target, value, action, args)
    -- if not target then return value end
    -- local wep = target:GetActiveWeapons()
    -- if not wep then return value end
    -- if wep == self then
    -- return value + WeaponComponentEffects.ExtraOverwatchShots:ResolveValue("extra_attacks")
    -- end
    -- return value
    -- end
    -- end
    -- end
    -- end

    if classdefs.Spiritual then
        local reac = classdefs.Spiritual.unit_reactions
        for i, react in ipairs(reac) do
            if react.Event == "OnCalcChanceToHit" then
                react.Handler = function(self, target, attacker, action, attack_target, weapon1,
                                         weapon2, data)
                    if target == attacker then
                        data.min = self:ResolveValue("minAccuracy")
                    end
                end
                break
            end
        end
    end

    if classdefs.TakeAim then
        local reacti = classdefs.TakeAim.unit_reactions
        for i, react in ipairs(reacti) do
            if react.Event == "OnModifyCTHModifier" then
                table.remove(reacti, i)
                break
            end
        end
    end

    if classdefs.Blood.StartingPerks then
        for i, perk in ipairs(classdefs.Blood.StartingPerks) do
            if perk == "MartialArts" then
                classdefs.Blood.StartingPerks[i] = "CQCTraining"
            end
        end
    end

    if classdefs.GruntyPerk.unit_reactions then
        table.insert(classdefs.GruntyPerk.unit_reactions, {
            Event = "OnFirearmAttackStart",
            Handler = function(self, target, attacker, attack_target, action, attack_args)
                if target == attacker and attack_args.gruntyPerk then
                    target:AddStatusEffect("grunty_bonus")
                    attack_args.aim = Max(1, attack_args.aim)
                end
            end
        })
    end

    if classdefs.MartialArts.unit_reactions then
        classdefs.MartialArts.unit_reactions = {
            PlaceObj('UnitReaction', {
                Event = "OnCalcChanceToHit",
                Handler = function(self, target, attacker, action, attack_target, weapon1, weapon2,
                                   data)
                    if not (action and action.ActionType == "Melee Attack") then
                        return
                    end

                    local text = T {776394275735, "Perk: <name>", name = self.DisplayName}
                    if target == attack_target and IsKindOf(target, "Unit") and target.species ~=
                        "Human" then
                        text = T(767817302327, "Perk: Animal Reflexes")
                    end

                    --
                    if target == attacker and target.species ~= "Human" then
                        --
                        ApplyCthModifier_Add(self, data, self:ResolveValue("hit"), text)
                    end

                    if target == attack_target then
                        ApplyCthModifier_Add(self, data, -self:ResolveValue("defense"), text)
                    end
                end
            })
        }
    end

    if classdefs.AutoWeapons.unit_reactions then
        classdefs.AutoWeapons.unit_reactions = nil
    end

    if classdefs.Ambidextrous.unit_reactions then
        classdefs.Ambidextrous.unit_reactions = nil
    end

end

---------------------------------------------------------------------------------------------------------

local t_id_table = {[767817302327] = "Perk: Animal Reflexes"}

ratG_T_table['UNIT_REACTIONS_changes.lua'] = t_id_table
