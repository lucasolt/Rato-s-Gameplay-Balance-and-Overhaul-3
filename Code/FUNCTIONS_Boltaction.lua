------------------ meant for unit reactions, so the params are the unit reactions params
function rat_unbolt(self, target, attacker, action, attack_target, results, attack_args)
    ------------ not used
    if target == attacker then
        local weapon = attack_args.weapon
        if weapon == self then
            if attack_args.used_action_id == "DualShot" then
                local w1, w2 = attacker:GetActiveWeapons()
                if rat_CanBolt(w2) then
                    w2.unbolted = true
                    ObjModified(w2)
                end
            end
            weapon.unbolted = true
            ObjModified(weapon)
            ObjModified(attacker)
        end
    end
end

function rat_endturn_bolt(self, target, unit_override)
    if self.unbolted then

        local unit = self.owner and g_Units[self.owner] or unit_override

        if not unit then
            return
        end

        local w1, w2 = unit:GetActiveWeapons()
        if self == w1 or self == w2 then
            local ap_cost = rat_get_manual_cyclingAP(unit, self)
            if unit:UIHasAP(ap_cost) then

                unit.ActionPoints = unit.ActionPoints - ap_cost
                CombatPathReset(unit)
                Msg("UnitAPChanged", unit)

                self.unbolted = false
                ObjModified(self)
                ObjModified(unit)
            elseif R_IsAI(unit) then
                local chance = Max(1, MulDivRound(unit.Dexterity, 80, 100))
                local roll = unit:Random(100)
                -- print("chance", chance, "roll", roll)
                if roll < chance then
                    self.unbolted = false
                    -- print("unbolted")
                    ObjModified(self)
                    ObjModified(unit)
                end
            end
        end
    end
end

function rat_endcombat_bolt(self, target)
    self.unbolted = false
    ObjModified(self)
end

-------------

function OnMsg.OnAttack(self, action, target, results, attack_args)

    local weapon = attack_args.weapon

    if rat_canBolt(weapon) then
        weapon.unbolted = true
        ObjModified(weapon)
        self:RecalcUIActions(true)
    end

    if attack_args.used_action_id == "DualShot" then
        local w1, w2 = self:GetActiveWeapons()

        if rat_canBolt(w2) then

            w2.unbolted = true
            ObjModified(w2)
            self:RecalcUIActions(true)
        end
    end

end

----

function rat_canBolt(weapon)
    if not weapon or not IsKindOf(weapon, "Firearm") then
        return false
    end
    if weapon:HasComponent("DASA_action_ap") or weapon:HasComponent("bolt_action_ap") then
        return true
    end
    return false
end

function unbolted_text(item, text_cost)
    local text = TranslationTable[995799974699] or "UNCYCLED"

    local cycle = item.Rat_cycling or false
    if cycle == "SingleAction" or cycle == "DoubleAction" then
        text = TranslationTable[642995678175] or "UNCOCKED"
    elseif cycle == "BoltAction" then
        text = TranslationTable[562438742744] or "UNBOLTED"
    end

    text = "<color AmmoBasicColor>" .. text .. "</color>"

    if text_cost then

        local ap_cost = rat_get_manual_cyclingAP(SelectedObj, item)
        local ap_cost_text = " (" .. MulDivRound(ap_cost, 1, const.Scale.AP) .. " " .. (TranslationTable[926825516268] or "AP") ..
                                 ")"
        local color = "AmmoAPColor>"
        if SelectedObj:UIHasAP(ap_cost) then
            color = "AmmoBasicColor>"
        end

        ap_cost_text = "<color " .. color .. ap_cost_text .. "</color>"
        text = text .. ap_cost_text
    end

    return T(text)
end

function rat_get_cycling()
    return {
        "BreakAction", "PumpAction", "BoltAction", "SingleAction", "SADoubleAction", "DoubleAction",
        "SemiAuto", "LeverAction", "Auto", ""
    }
end

local v_after = function(child, context, item, i, n, last)
    local itemIcon = child.idIcon
    itemIcon:SetImage(item.Icon)
    itemIcon:SetMinHeight(HUDButtonHeight)
    itemIcon:SetMaxHeight(HUDButtonHeight)

    local warningText = child.idWarningText
    local button = child.idFrame
    local sideButtonsSize = 0
    if item:IsLargeItem() then
        itemIcon:SetMaxWidth(154 + sideButtonsSize)
    else
        itemIcon:SetMaxWidth(77 + sideButtonsSize)
    end
    warningText:SetMaxWidth(itemIcon.MaxWidth)

    local reloadables = GetReloadOptionsForWeapon(item, false, "skipSubWeapon")
    local count = GetBulletCount(item)
    local is_firearm = IsKindOf(item, "Firearm")
    if is_firearm and item.jammed and not item:IsCondition("Broken") then
        warningText:SetText(T(276505585210, "JAMMED"))
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)
    elseif is_firearm and item:IsCondition("Broken") then
        warningText:SetText(T(623193685060, "BROKEN"))
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)

        ----------------------
    elseif is_firearm and item.unbolted then

        local text = unbolted_text(item)

        warningText:SetText(text)
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)
        ------------------
    elseif count and count == 0 then
        if not reloadables or #reloadables == 0 then
            warningText:SetText(T(669866061827, "No Ammo"))
            itemIcon:SetDesaturation(255)
            itemIcon:SetTransparency(50)
        else
            warningText:SetText(T(402669531723, "RELOAD"))
            itemIcon:SetDesaturation(255)
            itemIcon:SetTransparency(50)
            rawset(child, "weapon-click", "reload")
        end
        warningText:SetVisible(true)
    elseif is_firearm and item:GetSubweapon("GrenadeLauncher") and
        GetBulletCount(item:GetSubweapon("GrenadeLauncher")) == 0 then
        warningText:SetText(T(693636719988, "NO GRENADE"))
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)
    end
end

local v_after2 = function(child, context, item, i, n, last)
    local itemIcon = child.idIcon
    itemIcon:SetImage(item.Icon)
    itemIcon:SetMinHeight(HUDButtonHeight)
    itemIcon:SetMaxHeight(HUDButtonHeight)

    local warningText = child.idWarningText
    local button = child.idFrame
    local sideButtonsSize = 0
    if item:IsLargeItem() then
        itemIcon:SetMaxWidth(154 + sideButtonsSize)
    else
        itemIcon:SetMaxWidth(77 + sideButtonsSize)
    end
    warningText:SetMaxWidth(itemIcon.MaxWidth)

    local reloadables = GetReloadOptionsForWeapon(item, false, "skipSubWeapon")
    local count = GetBulletCount(item)
    local is_firearm = IsKindOf(item, "Firearm")
    if is_firearm and item.jammed and not item:IsCondition("Broken") then
        warningText:SetText(T(276505585210, "JAMMED"))
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)
    elseif is_firearm and item:IsCondition("Broken") then
        warningText:SetText(T(623193685060, "BROKEN"))
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)
        ------------------
    elseif is_firearm and item.unbolted then

        local text = unbolted_text(item, true)
        warningText:SetText(text)
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)
        rawset(child, "weapon-click", "reload")
        ----------------------
    elseif count and count == 0 then
        if not reloadables or #reloadables == 0 then
            warningText:SetText(T(669866061827, "No Ammo"))
            itemIcon:SetDesaturation(255)
            itemIcon:SetTransparency(50)
        else
            warningText:SetText(T(402669531723, "RELOAD"))
            itemIcon:SetDesaturation(255)
            itemIcon:SetTransparency(50)
            rawset(child, "weapon-click", "reload")
        end
        warningText:SetVisible(true)
    elseif is_firearm and item:GetSubweapon("GrenadeLauncher") and
        GetBulletCount(item:GetSubweapon("GrenadeLauncher")) == 0 then
        warningText:SetText(T(693636719988, "NO GRENADE"))
        itemIcon:SetDesaturation(255)
        itemIcon:SetTransparency(50)
        warningText:SetVisible(true)
    end
end

function rat_bolt_template1()
    ForEachPreset("XTemplate", function(x)
        if x.id == "UIWeaponDisplay" then
            for i, v in ipairs(x[1][4][1]) do
                -- print("i",i)
                -- print("v", v)
                -- for k, j in ipairs(v) do
                -- print("k", k)
                -- print(j)
                -- end
                if i == 1 then
                    -- print(i)
                    -- print(v.comment)
                    -- print("array", v.array)
                    -- print("run_after", v.run_after)
                    v.run_after = v_after

                end
            end

        end
    end)
end

function rat_bolt_template2()
    local xt = FindXtByProp(XTemplates.UIWeaponDisplay, 'Id', 'idEquippedSet')
    xt = FindXtByProp(xt[1], "comment", "weapon")
    -- print("vafter",xt[1].run_after)
    xt[1].run_after = v_after2
end

function rat_change_template_boltaction()
    rat_bolt_template1()
    rat_bolt_template2()
end

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [995799974699] = "UNCYCLED",
    [642995678175] = "UNCOCKED",
    [562438742744] = "UNBOLTED",
    [276505585210] = "JAMMED",
    [623193685060] = "BROKEN",
    [669866061827] = "No Ammo",
    [402669531723] = "RELOAD",
    [693636719988] = "NO GRENADE",
    [926825516268] = "AP"
}

ratG_T_table['FUNCTIONS_Boltaction.lua'] = t_id_table
