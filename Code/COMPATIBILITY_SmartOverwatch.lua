local already_placed = false

function OnMsg.EnterSector()

    if (IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch")) and not already_placed then
        define_getOWattacks_and_aim()

        already_placed = true
        print(
            "GBO - enabling SmartOW compatibility - redefining OW get attacks and aim function")
    end
end

function smart_xtempl()
    local xt = FindXtByProp(XTemplates.UIWeaponDisplay, 'Id', 'idEquippedSet')
    xt = FindXtByProp(xt[1], "comment", "weapon")
    local xt1 = FindXtByProp(xt, "id", "idSO_Buttons")
    if not xt1 then
        print("GBO: Error - SmartOverwatch xtemplate not found")
        return
    end
    if xt1[1][1].comment == "ratified" then
        -- print("already ratified")
        return
    end
    local original_OnPress = xt1[1][1].OnPress
    xt1[1][1].OnPress = function(self, gamepad)

        local SO_BodyPart_rotation = {
            Auto = "head",
            head = "hand",
            hand = 'torso',
            torso = 'groin',
            groin = 'leg',
            leg = "Auto"
        }

        local SO_appr_attacks = {
            "SingleShot", "BurstFire", "MGBurstFire", "AutoFire", "Buckshot", "BuckshotBurst",
            "DoubleBarrel"
        }

        local function SO_get_next_attack(weapon_attacks, cur_attack)
            local SO_attacks = {}
            for i, att in ipairs(weapon_attacks) do
                if table.find(SO_appr_attacks, att) then
                    table.insert(SO_attacks, att)
                end
            end

            local ind
            if cur_attack then
                ind = table.find(SO_attacks, cur_attack) or 0
                ind = ind + 1
                if ind > #SO_attacks then
                    ind = 1
                end
            else
                ind = 1
            end

            return CombatActions[SO_attacks[ind]]
        end

        original_OnPress(self, gamepad)
        -- local weapon = self.context
        -- if not weapon then
        -- return
        -- end
        -- local SO_attack = weapon.SO_overwatch_attack.id
        -- local attacks = weapon.AvailableAttacks

        -- SO_attack = SO_get_next_attack(attacks, SO_attack)
        -- weapon.SO_overwatch_attack = SO_attack
        -- ObjModified(weapon)

        if IsKindOf(SelectedObj, "Unit") then
            SelectedObj:RecalcUIActions(true)
            -- print("recalc")
        end
    end
    xt1[1][1].comment = "ratified"
    print("GBO: changed SmartOW xTemplate to recalc UI actions")
end

function add_recalcUI()
    if IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch") then
        smart_xtempl()
    end
end

function OnMsg.EnterSector()
    if IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch") then
        smart_xtempl()
        rat_MGSetup_getap()
    end
    if (IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch")) and not already_placed then
        define_getOWattacks_and_aim()

        already_placed = true
        print("GBO - enabling SmartOW compatibility")
    end
end

function OnMsg.CombatStart()
    if IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch") then
        smart_xtempl()
        rat_MGSetup_getap()
    end
    if (IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch")) and not already_placed then
        define_getOWattacks_and_aim()

        already_placed = true
        print("GBO - enabling SmartOW compatibility")
    end
end

function OnMsg.ZuluGameLoaded()
    if IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch") then
        smart_xtempl()
        rat_MGSetup_getap()
    end
    if (IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch")) and not already_placed then
        define_getOWattacks_and_aim()

        already_placed = true
        print("GBO - enabling SmartOW compatibility")
    end
end

function OnMsg.ModsReloaded()
    if IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch") then
        smart_xtempl()
        rat_MGSetup_getap()
    end
    if (IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch")) and not already_placed then
        define_getOWattacks_and_aim()

        already_placed = true
        print("GBO - enabling SmartOW compatibility")
    end
end
