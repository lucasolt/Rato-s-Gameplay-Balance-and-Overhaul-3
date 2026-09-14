function rat_place_prepareweapon_combat_actions()
    PlaceObj('CombatAction', {
        ActionType = "Ranged Attack",
        ActivePauseBehavior = "queue",
        AimType = "cone",
        ConfigurableKeybind = false,
        ------------------
        Description = T(222855944347, "Enter <em>Shooting Stance</em>."),
        DisplayName = T(187383913751, "Prepare Weapon"),
        -------------------
        Execute = function(self, units, args)
            local unit = units[1]
            args.num_attacks = 0
            args.aim = 0
            local ap = self:GetAPCost(unit, args)
            NetStartCombatAction(self.id, unit, ap, args)
        end,

        -----
        GetAPCost = function(self, unit, args)

            local stance = 0
            local param
            local weapon = unit:GetActiveWeapons()
            local action = self
            if not HasPerk(unit, "shooting_stance") then
                param = "stance"
                stance = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                  args and args.aim or 0, action, param) or 0
            end

            if not HasPerk(unit, "shooting_stance") then
                stance = stance + Get_AimCost(unit)
                return stance -- Max(unit:GetUIActionPoints(), stance), stance
            else
                local rotate = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                        args and args.aim or 0, action, param) or 0

                rotate = Max(R_VanillaAP(1), rotate)
                return rotate -- Max(unit:GetUIActionPoints(), rotate), rotate
            end

        end,

        GetActionDescription = function(self, units)
            local descr
            local unit = units[1]
            if not HasPerk(unit, "shooting_stance") then
                descr = T {399161531399, "Enter <em>Shooting Stance</em>."}

            else
                descr = T {878229893688, "Rotate your weapon."}

            end
            return descr
        end,

        ---------------------------------

        GetActionDisplayName = function(self, units)
            local name
            local unit = units[1]
            if not HasPerk(unit, "shooting_stance") then
                name = T(871168252913, "Prepare Weapon")
            else
                name = T(735297133453, "Rotate Weapon")
            end
            return name
        end,
        GetActionIcon = function(self, units)
            return self.Icon
        end,
        GetAimParams = function(self, unit, weapon)
            local params = weapon:R_GetAreaAttackParams(self.id, unit)
            -- params.min_range = self:GetMinAimRange(unit, weapon)
            params.max_range = self:GetMaxAimRange(unit, weapon) * 1.5
            params.min_range = params.max_range * 1.5
            -- assert(params.max_range >= params.min_range)
            return params
        end,
        GetAttackWeapons = function(self, unit, args)
            if args and args.weapon then
                return args.weapon
            end
            return unit:GetActiveWeapons("Firearm")
        end,
        GetMaxAimRange = function(self, unit, weapon)
            local range = weapon:GetOverwatchConeParam("MaxRange")
            local sight = unit:GetSightRadius() / const.SlabSizeX
            return Min(range, sight)
        end,
        GetMinAimRange = function(self, unit, weapon)
            local range = weapon:GetOverwatchConeParam("MinRange")
            local sight = unit:GetSightRadius() / const.SlabSizeX
            return Min(range, sight)
        end,
        GetUIState = function(self, units, args)
            local unit = units[1]
            local cost = self:GetAPCost(unit, args)
            local weapon = unit:GetActiveWeapons()

            if not IsKindOf(weapon, "Firearm") or IsKindOf(weapon, "HeavyWeapon") then
                return "hidden"
            end

            if cost < 0 then
                return "hidden"
            end

            if g_Overwatch[unit] then
                return "hidden"
            end

            if not unit:UIHasAP(cost) then
                return "disabled", GetUnitNoApReason(unit)
            else
                return "enabled"
            end

        end,
        Icon = "Mod/cfahRED/Images/shootingstancecompleto.png",
        IdDefault = "R_PrepareWeapon",
        MultiSelectBehavior = "first",
        KeybindingSortId = "2351",
        QueuedBadgeText = T(756827411698, "PREPARE"),
        RequireState = "any",
        Run = function(self, unit, ap, ...)

            unit:SetActionCommand("ShootingStanceCommand", self.id, ap, ...)
            -- local args = ...
            -- SetShootingStanceCommand(unit, args.target)
        end,
        SortKey = 2,
        UIBegin = function(self, units, args)
            CombatActionAttackStart(self, units, args, "IModeCombatAreaAim", "cancel")
        end,
        group = "Default",
        id = "R_PrepareWeapon"
    })

    PlaceObj('CombatAction', {
        ActionPoints = 0000,
        ActivePauseBehavior = "instant",
        ConfigurableKeybind = false,
        Description = T(148517345744, "Exit <em>Shooting Stance</em>"),
        DisplayName = T(567973728148, "Lower Weapon"),
        GetActionDescription = function(self, units)
            local unit = units[1]

            local description = TranslationTable[148517345744] or "Exit <em>Shooting Stance</em>" -- self.Description

            if unit.return_pos_reserved then
                description = description .. " and return to cover."
            else
                description = description .. "."
            end

            return T(description)
        end,

        GetUIState = function(self, units, args)
            ---------------------
            local unit = units[1]
            local cost = self:GetAPCost(unit, args)

            if not HasPerk(unit, "shooting_stance") then
                return "hidden"
            elseif not unit:UIHasAP(R_VanillaAP(1)) and (unit.free_move_ap and unit.free_move_ap < R_VanillaAP(1)) then
                return "disabled", T(677754398866, "<color AmmoAPColor>Turn Ended</color>")
            end

            return "enabled"
            ------------------
        end,
        Icon = "Mod/cfahRED/Images/shootingstance_removal3.png",
        IdDefault = "R_LowerWeapon",
        IsAimableAttack = false,
        KeybindingSortId = "2352",
        MultiSelectBehavior = "first",
        RequireState = "any",
        Run = function(self, unit, ap, ...)
            unit:RemoveStatusEffect("shooting_stance")
            unit:InterruptPreparedAttack()
            unit:SetCommand("Idle")
        end,
        SortKey = 21,
        group = "Default",
        id = "R_LowerWeapon"
    })
end

---- New version moved to shooting_stance functions
--[[function SetShootingStanceCommand(unit, target)

    local orientation = CalcOrientation(unit, target)
    local stance = unit.stance
    local aim_state = unit:GetAimAnim(stance)

    if g_Combat then
        unit:AnimatedRotation(orientation)
        unit:SetState(aim_state, const.eKeepComponentTargets)
        ----
        PackAimPosInStanceEffect(unit:GetStatusEffect("shooting_stance"), target)
        ----
        Sleep(300)
    else ---- not sure how to create a thread, so cant Sleep
        unit:SetOrientationAngle(orientation)
        unit:SetState(aim_state, const.eKeepComponentTargets)
    end

    unit:EnterShootingStance(target)

    SetInGameInterfaceMode(g_Combat and "IModeCombatMovement" or "IModeExploration")
end]]
---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [222855944347] = "Enter <em>Shooting Stance</em>.",
    [187383913751] = "Prepare Weapon",
    [871168252913] = "Prepare Weapon",
    [735297133453] = "Rotate Weapon",
    [756827411698] = "PREPARE",
    [148517345744] = "Exit <em>Shooting Stance</em>",
    [567973728148] = "Lower Weapon",
    [540349977342] = "Cancel the bandaging action. The unit will be able to move but not regain any more HP.",
    [151546259528] = "Cancel the bandaging action. The bandaged unit will not regain any more HP.",
    [677754398866] = "<color AmmoAPColor>Turn Ended</color>",
    [399161531399] = "Enter <em>Shooting Stance</em>.",
    [878229893688] = "Rotate your weapon."
}

ratG_T_table['shooting_stance_prepare_weapon_action.lua'] = t_id_table
