function OnMsg.UnitSwappedWeapon(unit)
    unit:RecalcUIActions(true)
end

------------ Savior Rework
local function check_and_addSaviorAdrenalineRush(team, downed_unit)
    for i, unit in ipairs(team.units or empty_table) do
        if not (downed_unit == unit) and not (unit:IsDowned() or unit:IsDead()) and HasPerk(unit, "Savior") then
            unit:AddStatusEffect("AdrenalineRush_Savior")
        end
    end
end

function OnMsg.UnitDied(unit)
    check_and_addSaviorAdrenalineRush(unit.team or empty_table, unit)
end

function OnMsg.UnitDowned(unit)
    check_and_addSaviorAdrenalineRush(unit.team or empty_table, unit)
end
---
function OnMsg.UnitStanceChanged(unit)

    local attaches = unit:GetAttaches(WeaponVisualClasses)
    for _, attach in ipairs(attaches) do
        local parts = attach.parts
        local is_holstered = attach.equip_index ~= 1 and attach.equip_index ~= 2
        if parts and parts.Grip and parts.Grip:HasState("folded") then
            local bipod_state =
                is_holstered or unit.stance ~= "Prone" and "folded" or unit.stance == "Prone" and
                    "idle"
            if parts.Grip:GetStateText() ~= bipod_state then
                parts.Grip:SetState(bipod_state)
            end
        end
    end
end

function OnMsg.OnAttack(unit, action, target, results, attack_args)

    local weapon = attack_args.weapon or unit:GetActiveWeapons()
    if not weapon then
        return
    end

    if IsKindOfClasses(weapon, "Pistol", "Revolver", "SubmachineGun") then
        unit:AddStatusEffect("shoot_move")
    end

end

---------------------------------------------------

function OnMsg.GatherDamageModifications(attacker, target, action_id, self, mod_attack_args,
                                         mod_hit_data, data)
    local weapon = data.weapon
    if not weapon or not IsKindOf(weapon, "Firearm") then
        return
    end
    if target:HasStatusEffect("Flanked") and weapon:HasComponent("flanker") then
        local damageBonus = 10
        data.base_damage = MulDivRound(data.base_damage, 100 + damageBonus, 100)
    end
    if target:HasStatusEffect("Flanked") and IsKindOf(weapon, "SubmachineGun") then
        local damageBonus = 15
        data.base_damage = MulDivRound(data.base_damage, 100 + damageBonus, 100)
    end
end

function OnMsg.IGIModeChanged(self, new_mode)
    local unit = SelectedObj
    if IsKindOf(unit, "Unit") then
        unit:RecalcUIActions(true)
    end
end

function OnMsg.GatherDamageModifications(attacker, target, action_id, self, mod_attack_args,
                                         mod_hit_data, data)
    local weapon = data.weapon
    if weapon then
        if IsKindOf(weapon, "EndlessKnives") then
            local level = attacker:GetLevel()
            local damage_mul = 2 * level
            data.base_damage = MulDivRound(data.base_damage, 100 + damage_mul, 100)
        end

        if IsKindOf(weapon, "Unarmed") and HasPerk(attacker, "MartialArts") and attacker.species ==
            "Human" then
            local dex_mod = 100 + MulDivRound(attacker.Dexterity, 115, 100)
            data.base_damage = MulDivRound(data.base_damage, dex_mod, 100)
        end
    end
end

-- function OnMsg.GatherDamageModifications (attacker, target, action_id, self, mod_attack_args, mod_hit_data, data)

-- if not (action_id == "Buckshot" or action_id == "BuckshotBurst") then
-- return
-- end
-- local mod_mul = rat_shotgun_dmg_scale(attacker,target) or 1
-- print("before dmg", data.base_damage)

-- data.damage_percent =  data.damage_percent * mod_mul
-- print("after dmg", data)

-- end

function OnMsg.CombatActionEnd(unit)

    if unit.action_command == "RunAndGun" or unit.action_command == "RecklessAssault" or
        unit.action_command == "HundredKnives" or unit.action_command == "Sprint" then
        if unit.action_command == "RecklessAssault" then
            unit:AddStatusEffect("R_outofbreath", 2)
        else
            unit:AddStatusEffect("R_outofbreath")
        end
    end

    if unit.Mobile_aimed then
        unit.Mobile_aimed = nil
    end

    ------ Persistant Recoil
    if unit.action_command == "OverwatchAction" then

        local overwatch = g_Overwatch[unit]
        if overwatch and overwatch.num_attacks > 0 then
            local effect_reset = unit:GetStatusEffect("Rat_recoil")
            if effect_reset then
                unit:RemoveStatusEffect("Rat_recoil", "all")
            end
        end
    end
end

------ Persistant Recoil
function OnMsg.OnAttack(unit, action, target, results, attack_args)

    local weapon = attack_args.weapon or unit:GetActiveWeapons()
    local aim = attack_args.aim or 0
    if const.Combat.R_RecoilP > 0 and IsKindOf(weapon, "Firearm") then

        if IsKindOf(weapon, "HeavyWeapon") then
            -- pass
        else
            unit:ApplyPersistantRecoilEffects(aim, action, weapon, attack_args)
        end
    end
end

-------------------------------------------------DEBUG
local function debug_component(w)
    if w:HasComponent("IgnoreInTheDark") then
        return true
    end
    return false
end

local function debug_weapon_component()
    for _, unit in ipairs(g_Units) do
        local _, __, wep = unit:GetActiveWeapons()
        for i, w in ipairs(wep) do
            local valid, result = pcall(debug_component, w)
            if not valid then

                print("trying to remove bugged component in unit:", unit.unitdatadef_id)

                local unit_debug = unit
                local w1_bug, w2_bug = unit_debug:GetActiveWeapons()

                if w1_bug.subweapons then
                    print("w1_bug.subweapons to remove", w1_bug.subweapons)
                    w1_bug.subweapons = {}
                end

                if w2_bug.subweapons then
                    print("w2_bug.subweapons to remove", w2_bug.subweapons)
                    w2_bug.subweapons = {}
                end

                ObjModified(unit_debug)
                ObjModified(w1_bug)
                ObjModified(w2_bug)
                print("bugged component removed in unit:", unit.unitdatadef_id)
            end
        end
    end
end

function OnMsg.EnterSector()
    debug_weapon_component()
end

function OnMsg.UnitEnterCombat(unit)
    debug_weapon_component()
end
----------------------------------------------------

function OnMsg.DamageDone(attacker, target, damage)
    if not attacker or not target then
        return
    end
    local targetIsUnit = IsKindOf(target, "Unit")
    if targetIsUnit and target:HasStatusEffect('shooting_stance') then
        local overwatch = g_Overwatch[target]
        if overwatch and overwatch.permanent then
            return
        end

        local ratio = MulDivRound(damage, 100, target.MaxHitPoints)

        if (ratio > 10) then
            local bonus = 10
            local side = target and target.team and target.team.side or ''

            if not (side == 'player1' or side == 'player2') then
                bonus = bonus + 10
            end
            local add = -ratio + bonus + 15
            if not Composure_RollSkillCheck(target, 100, add) then
                target:RemoveStatusEffect("shooting_stance")
            end
        end
    end
end

function OnMsg.EnterSector()
    for _, unit in ipairs(g_Units) do
        unit.auto_face = false
    end
end

function OnMsg.UnitEnterCombat(unit)
    for _, unit in ipairs(g_Units) do
        unit.auto_face = false
    end
end

----------------------------Tracer Rounds
function OnMsg.OnAttack(attacker, action, target, results, attack_args)
    local weapon = attack_args.weapon or attacker:GetActiveWeapons()
    if weapon and weapon.tracer == 1 then
        attacker:AddStatusEffect("Revealed_R")
    end
end

