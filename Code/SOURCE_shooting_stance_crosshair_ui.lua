----- UI/CrosshairUI.lua
----- ok 1.5
local function formatNumber(num)
    local integerPart = math.floor(num)
    local fractionalPart = num - integerPart
    if fractionalPart == 0 and fractionalPart ~= 0.5 then
        return string.format("%d", num)
    else
        return tostring(num)
    end
end

function redefine_crosshairUI_function()
    function CrosshairUI:UpdateAim()
        local pContext = self.context
        if not pContext then
            return
        end

        local attacker = pContext.attacker
        local action = self.show_data_for_action or pContext.action
        local target = pContext.target

        if not IsValid(target) or not action then
            return
        end

        local args = {
            target = target,
            goto_pos = pContext.meleeTargetPos,
            target_spot_group = self.targetPart.id,
            step_pos = pContext.override_pos,
            cth_breakdown = true,
            damage_breakdown = true,
            free_aim = pContext.free_aim,
            num_shots = Rat_CrosshairShots(self, attacker, action)
        }
        if not self.context.noAim then
            self.aim = self.aim or 0
            args.aim = self.aim

            -- make sure the attacker has the AP for the aiming
            while self.aim > 0 and action:GetUIState({attacker}, args) ~=
                "enabled" do
                self.aim = self.aim - 1
                args.aim = self.aim
            end
        end
        ---- then the burst gives way, down to its minimum
        while args.num_shots and args.num_shots > const.Combat.Autofire.MinShots and
            action:GetUIState({attacker}, args) ~= "enabled" do
            args.num_shots = Rat_CrosshairSetShots(self, action, args.num_shots - 1)
        end

        -- Action can no longer be used.
        if action:GetUIState({attacker}, args) ~= "enabled" then
            if not attacker.move_attack_in_progress then
                SetInGameInterfaceMode(g_Combat and "IModeCombatMovement" or
                                           "IModeExploration")
            end
            return
        end

        local attackResultTable = {}
        local cthTable = {}
        local critChance = 0

        -- Gather information from attack results, to display.
        if not self.cached_results then
            self.cached_results = {}
        end

        local cached_results = self.cached_results[action.id]
        local invalidCache = not cached_results or cached_results.aim ~=
                                 self.aim or cached_results.ap ~=
                                 attacker.ActionPoints or
                                 cached_results.free_move_ap ~=
                                 attacker.free_move_ap or
                                 cached_results.num_shots ~= args.num_shots

        if invalidCache then
            local cthCalc, attackResultCalc = {}, {}
            local crit = 0

            -- Check for spotter unit, shows a specific icon and rollover
            local spotter = false
            for _, u in ipairs(attacker.team.units) do
                if u ~= attacker and
                    VisibilityCheckAll(u, target, nil, const.uvVisible) then
                    spotter = u
                end
            end

            local spotterCth, noLoSCth, grazingProtected = false, false, false -- needed for ui
            local inDarkness = false -- needed for tutorials

            -- Non-unit targets (such as traps) need to provide an empty string as the target_spot_group (due to lof internal logic)
            local queryBodyParts = IsKindOf(target, "Unit")
            for i, p in ipairs(pContext.body_parts) do
                local partId = p.id
                args.target_spot_group = queryBodyParts and partId or ""
                local results, attack_args =
                    action:GetActionResults(attacker, args)
                cthCalc[partId] = results.chance_to_hit
                results.crosshair_attack_args = attack_args
                attackResultCalc[partId] = results

                -- skip calling ResolveAttackParams for every body part
                if results.lof then
                    args.lof = results.lof
                end

                spotterCth = spotterCth or
                                 table.find(results.chance_to_hit_modifiers,
                                            "id", "SeenBySpotter")
                noLoSCth = noLoSCth or
                               table.find(results.chance_to_hit_modifiers, "id",
                                          "NoLineOfSight")
                inDarkness = inDarkness or
                                 table.find(results.chance_to_hit_modifiers,
                                            "id", "Darkness")

                results.cantSeeBodyPart = false
                results.spotter = false -- no longer per body part but leaving this here for clarity

                local hitOnTarget = table.find_value(results, "obj", target)
                if hitOnTarget and hitOnTarget.grazing then
                    results.grazing = true
                    results.crit_chance = 0
                    if hitOnTarget.grazing_reason == "cover" then
                        grazingProtected = true
                    end
                end

                if results and results.crit_chance then
                    crit = results.crit_chance
                end

                local damage = 0
                for i, hit in ipairs(results) do
                    if hit.obj == target then
                        damage = damage + hit.damage +
                                     (hit.armor_prevented or 0)
                    end
                end

                local aoeDamage = 0
                for i, hit in ipairs(results.area_hits) do
                    if hit.obj == target then
                        aoeDamage = aoeDamage + hit.damage +
                                        (hit.armor_prevented or 0)
                    end
                end
                results.calculated_target_damage = damage
                results.calculated_target_aoeDamage = aoeDamage
            end

            if noLoSCth or spotterCth then
                local defaultPartId = self.defaultTargetPart.id
                cthCalc["BlindFire"] = cthCalc[defaultPartId]
                local attackResultCopy = table.copy(
                                             attackResultCalc[defaultPartId])
                attackResultCopy.cantSeeBodyPart = true
                attackResultCopy.spotter = spotterCth and spotter
                attackResultCalc["BlindFire"] = attackResultCopy

                -- Overwrite some of the torso data so it's more ambigious which
                -- part you're hitting
                attackResultCopy.chance_to_hit_modifiers = {
                    {
                        id = "Unknown",
                        value = 0,
                        name = T(553504408105, "Unknown Modifiers")
                    }
                }

                -- For debug functionality display the highest cth bodypart
                if CthVisible() then
                    local highestCth = 0
                    local highestCthPart = false
                    for partName, partData in pairs(attackResultCalc) do
                        local cth = partData.chance_to_hit
                        if not highestCthPart or cth > highestCth then
                            highestCthPart = partData
                            highestCth = highestCth
                        end
                    end
                    attackResultCopy.chance_to_hit_modifiers =
                        highestCthPart.chance_to_hit_modifiers
                    attackResultCopy.chance_to_hit =
                        highestCthPart.chance_to_hit
                    cthCalc["BlindFire"] = highestCthPart.chance_to_hit
                end

                local noneOfPartsHit = true
                for partName, partData in pairs(attackResultCalc) do
                    if partData.target_hit then
                        noneOfPartsHit = false
                        break
                    end
                end
                if not noneOfPartsHit then
                    attackResultCopy.target_hit = true
                end

                self.targetPart = Presets.TargetBodyPart.Default.BlindFire
            elseif target:HasStatusEffect("Protected") and grazingProtected then
                local highestCth = 0
                local highestCthPart, highestCthId = false, false
                for partName, partData in pairs(attackResultCalc) do
                    local cth = partData.chance_to_hit
                    if not highestCthPart or cth > highestCth then
                        highestCthPart = partData
                        highestCth = highestCth
                        highestCthId = partName
                    end
                end

                -- InCover body part selects the body part with highest cth (191329)
                local attackResultCopy = table.copy(highestCthPart)
                attackResultCopy.actual_body_part = highestCthId
                attackResultCopy.bodyPartDisplayName =
                    Presets.TargetBodyPart.Default[highestCthId].display_name
                cthCalc["InCover"] = cthCalc[highestCthId]
                attackResultCalc["InCover"] = attackResultCopy

                self.targetPart = Presets.TargetBodyPart.Default.InCover
            elseif self.targetPart == Presets.TargetBodyPart.Default.BlindFire or
                self.targetPart == Presets.TargetBodyPart.Default.InCover then -- No longer valid fake bodypart
                self.targetPart = g_DefaultShotBodyPart
            end

            self.cached_results[action.id] = {
                cthCalc = cthCalc,
                attackResultCalc = attackResultCalc,
                crit = crit,
                aim = self.aim,
                ap = attacker.ActionPoints,
                free_move_ap = attacker.free_move_ap,
                num_shots = args.num_shots
            }

            if inDarkness and not TutorialHintsState.InDarkness then
                self.darkness_tutorial = true
            end

            local target_dummy
            local lof_data = args.lof and args.lof[1]
            local atk_results =
                attackResultCalc[args.target_spot_group or false]
            if lof_data then
                target_dummy = {
                    obj = lof_data.obj,
                    anim = lof_data.anim,
                    phase = 0,
                    pos = lof_data.step_pos,
                    angle = lof_data.angle,
                    stance = lof_data.stance
                }
            elseif args.goto_pos and attacker:GetDist(args.goto_pos) >
                const.SlabSizeX / 2 then
                target_dummy = {obj = attacker, pos = args.goto_pos}
            elseif atk_results and atk_results.step_pos then
                target_dummy = {obj = attacker, pos = atk_results.step_pos}
            end
            self.context.danger = AnyAttackInterrupt(attacker, target, action,
                                                     target_dummy)
            if not self.context.danger and args.goto_pos then
                local combatPath = GetMeleeAttackCombatPath(action, attacker)
                local targetPath = combatPath and
                                       combatPath:GetCombatPathFromPos(
                                           args.goto_pos)
                if targetPath then
                    self.context.danger =
                        AnyInterruptsAlongPath(attacker, targetPath, "all",
                                               action)
                end
            end
        end

        assert(self.cached_results[action.id])
        local cachedRe = self.cached_results[action.id]
        cthTable = cachedRe.cthCalc
        attackResultTable = cachedRe.attackResultCalc
        critChance = cachedRe.crit

        -- Write data to context
        if not action.AlwaysHits then
            pContext.cth = cthTable
        else
            pContext.cth = {}
        end
        pContext.attackResultTable = attackResultTable

        local actualAction = pContext.action -- Dont use "show_for_action" for these calculations
        local distToTarget = attacker:GetDist(target)
        pContext.attack_distance = DivCeil(distToTarget, const.SlabSizeX)

        local weapon1, _ = actualAction:GetAttackWeapons(attacker)
        pContext.weapon_range =
            actualAction:GetMaxAimRange(attacker, weapon1) or
                weapon1.WeaponRange
        assert(pContext.weapon_range)
        pContext.weapon_range = pContext.weapon_range or 0

        local dialog = GetInGameInterfaceModeDlg()
        self.attack_cursor = GetRangeBasedMouseCursor(dialog.penalty,
                                                      actualAction, "attack")

        local bodyPartsUI = self:ResolveId("idButtonsContainer")
        for i, p in ipairs(bodyPartsUI) do
            local cth = CthVisible() and cthTable[p.context.id]
            if cth then
                p.idHitChance:SetText(T {
                    483116174778,
                    "<percent(cth)>",
                    cth = cth
                })
                --------------------- Descriptive CTH
            elseif IsMod_loaded("N6rmtjQ") and (DCth_LabelsOnBodyParts()) then
                cth = cthTable[p.context.id]
                if (cth) then
                    local stat = DCth_chooseLabelStat(attacker)
                    local label = DCth_calculateCthLabel(cth, stat)
                    p.idHitChance:SetText("<valign bottom +1>" .. label)
                else
                    p.idHitChance:SetVisible(false)
                end
                --------------------------	

            else
                p.idHitChance:SetVisible(false)
            end
        end
        ObjModified("crosshair")
        ObjModified("firing_mode")
        ObjModified(pContext)

        args.target_spot_group = self.targetPart.id -- restore potentially changed argument by the loop above
        if RolloverWin then
            RolloverWin:UpdateRolloverContent()
        end
        -- self:SetScaleModifier(GetUIStyleGamepad() and point(1150, 1150) or point(1000, 1000))

        if self.idAPCostText then

            args.ap_cost_breakdown = {}

            local weapon = weapon1
            local unit = attacker
            local action = actualAction
            local target_arg = args.target or false
            local stance_ap = unit:GetShootingStanceAP(target_arg, weapon, args.aim or 0, action)

            local apCost = action:GetAPCost(attacker, args)

            -- aim share = cost delta against the same shot at aim 0, minus the stance AP that aiming unlocks
            local args0 = table.copy(args)
            args0.aim = 0
            args0.ap_cost_breakdown = {}
            local cost0 = action:GetAPCost(attacker, args0)
            local stance0 = unit:GetShootingStanceAP(target_arg, weapon, 0, action)
            local aim_ap = Max(0, (apCost - stance_ap) - (cost0 - stance0))

            local recoil_ap, recoil_text, recoil_capped = 0, false, false
            local recoil = attacker:GetStatusEffect("Rat_recoil")
            local aim_penalty = recoil and recoil:ResolveValue("aim_cost")
            if aim_penalty and aim_penalty >= R_VanillaAPToDisplay(0.5) then
                local min_aim = attacker:GetBaseAimLevelRange(action, weapon)
                local aim_level = Max(0, (args.aim or 0) - min_aim)
                recoil_capped = aim_level > 3
                aim_level = Min(3, aim_level)
                -- mirrors Rat_recoil's OnCalcAPCost
                recoil_ap = Min(aim_ap, cRoundDown(aim_penalty * aim_level) * const.Scale.AP)
                recoil_text = not recoil_capped and formatNumber(aim_penalty)
            end

            local free_move_ap_used = Min(args.ap_cost_breakdown.move_cost or 0,
                                          attacker.free_move_ap)
            apCost = apCost - Max(0, free_move_ap_used)
            -- round the cost to match before/after AP readings
            local unitAp = attacker:GetUIActionPoints()
            local before = unitAp / const.Scale.AP
            local after = (unitAp - apCost) / const.Scale.AP -- free move is already accounted for in apCost
            apCost = (before - after) * const.Scale.AP

            if g_Combat then
                self.idAPCostText:SetText(T {
                    "<apn(apCost)><style CrosshairAPTotal><valign bottom -2>/<apn(unitAp)> AP</style>",
                    apCost = apCost,
                    unitAp = unitAp
                })
            else
                self.idAPCostText:SetText(T {
                    "<apn(apCost)><style CrosshairAPTotal><valign bottom -2> AP</style>",
                    apCost = apCost
                })
            end

            Rat_UpdateCrosshairAPBreakdown(self, unit, {
                stance = stance_ap,
                shot = Max(0, apCost - stance_ap - aim_ap),
                aim = aim_ap,
                recoil = recoil_ap,
                recoil_text = recoil_text,
                recoil_capped = recoil_capped
            })
            ------------------
            if self.aim ~= 0 then
                self.idAPCostText:SetTextStyle("CrosshairAPCostYellow")
            else
                self.idAPCostText:SetTextStyle("CrosshairAPCost")
            end
        end

        Rat_UpdateCrosshairRounds(self, attacker, actualAction, args)

        WeaponRangeTutorial(self)
        ShowCrosshairTutorial(self)
    end
end

redefine_crosshairUI_function()

---------------------------------------------------------------------------------------------------
local ap_breakdown_labels = {
    stance = T(771402935518, "STN"),
    rotate = T(771402935519, "ROT"),
    shot = T(771402935520, "SHT"),
    aim = T(771402935521, "AIM"),
    recoil = T(771402935522, "<color AmmoAPColor>RECOIL: +<r>/aim</color>")
}

local function ap_breakdown_col(id)
    return PlaceObj('XTemplateWindow', {
        'Id', id,
        'IdNode', true,
        'LayoutMethod', "VList",
        'VAlign', "center",
        'Margins', box(3, 0, 3, 0),
        'UseClipBox', false,
        'FoldWhenHidden', true
    }, {
        PlaceObj('XTemplateWindow', {
            '__class', "XText",
            'Id', "idLabel",
            'HAlign', "center",
            'Padding', box(0, 0, 0, 0),
            'Clip', false,
            'UseClipBox', false,
            'TextStyle', "Crosshair_Range",
            'Translate', true
        }),
        PlaceObj('XTemplateWindow', {
            '__class', "XText",
            'Id', "idValue",
            'HAlign', "center",
            'Padding', box(0, 0, 0, 0),
            'Margins', box(0, -4, 0, 0),
            'Clip', false,
            'UseClipBox', false,
            'TextStyle', "CrosshairAPTotal",
            'Translate', true
        })
    })
end

-- sits right of the total inside the AP box; scaled down so the box stays one line tall
local ap_breakdown_template = PlaceObj('XTemplateWindow', {
    'comment', "rat_ap_breakdown",
    'Id', "idRatAPBreakdown",
    'IdNode', true,
    'VAlign', "center",
    'LayoutMethod', "HList",
    'Margins', box(0, 0, 6, 0),
    'ScaleModifier', point(750, 750),
    'UseClipBox', false,
    'Visible', false,
    'FoldWhenHidden', true
}, {
    PlaceObj('XTemplateWindow', {
        'MinWidth', 1,
        'MaxWidth', 1,
        'Margins', box(0, 4, 4, 4),
        'Background', RGBA(195, 189, 172, 90)
    }),
    PlaceObj('XTemplateWindow', {
        'LayoutMethod', "VList",
        'VAlign', "center",
        'UseClipBox', false
    }, {
        PlaceObj('XTemplateWindow', {
            'LayoutMethod', "HList",
            'HAlign', "center",
            'UseClipBox', false
        }, {
            ap_breakdown_col("idRatAPStance"),
            ap_breakdown_col("idRatAPShot"),
            ap_breakdown_col("idRatAPAim")
        }),
        PlaceObj('XTemplateWindow', {
            '__class', "XText",
            'Id', "idRatAPRecoil",
            'HAlign', "center",
            'Padding', box(0, 0, 0, 0),
            'Margins', box(0, -4, 0, 0),
            'Clip', false,
            'UseClipBox', false,
            'FoldWhenHidden', true,
            'TextStyle', "Crosshair_Range",
            'Translate', true
        })
    })
})

local function strip_breakdown(parent)
    for i = #parent, 1, -1 do
        if parent[i].comment == "rat_ap_breakdown" then
            table.remove(parent, i)
        end
    end
end

---- appended to the "ap indicator" box
function Rat_PatchCrosshairAPBreakdown()
    local range = FindXtByProp(XTemplates.ActionCameraCrosshair, 'Id', 'idRange')
    if range and range[2] then
        strip_breakdown(range[2])
    end
    local chain = FindXtByProp(XTemplates.ActionCameraCrosshair, 'Id', 'idAPCostText')
    local ap_box = chain and chain[2]
    if not ap_box then
        return
    end
    strip_breakdown(ap_box)
    ap_box[#ap_box + 1] = ap_breakdown_template
end

local function set_col(col, label, value, visible, color)
    col:SetVisible(visible)
    if visible then
        col.idLabel:SetText(label)
        -- default is a notch under the total's brightness
        col.idValue:SetText(T {"<color " .. (color or "176 170 154") .. "><value></color>", value = value})
    end
end

function Rat_UpdateCrosshairAPBreakdown(crosshair, unit, parts)
    local row = crosshair.idRatAPBreakdown
    if not row then
        return
    end
    -- set live: XTemplate caches each template's copied props, so a patched LayoutMethod is ignored
    if row.parent.LayoutMethod ~= "HList" then
        row.parent:SetLayoutMethod("HList")
        crosshair.idAPCostText:SetScaleModifier(point(870, 870))
    end
    local show_recoil = parts.recoil_text
    local show = parts.stance > 0 or parts.aim > 0 or not not show_recoil
    row:SetVisible(show)
    if not show then
        return
    end

    local in_stance = unit:HasStatusEffect("shooting_stance") or
                          unit:HasStatusEffect("ManningEmplacement") or
                          unit:HasStatusEffect("StationedMachineGun")
    set_col(row.idRatAPStance, ap_breakdown_labels[in_stance and "rotate" or "stance"],
            T {"<apn(v)>", v = parts.stance}, parts.stance > 0)
    set_col(row.idRatAPShot, ap_breakdown_labels.shot, T {"<apn(v)>", v = parts.shot}, true)
    -- aim includes recoil: red ties it to the recoil line, amber once recoil stops adding past aim 3
    set_col(row.idRatAPAim, ap_breakdown_labels.aim, T {"<apn(v)>", v = parts.aim}, true,
            parts.recoil > 0 and (parts.recoil_capped and "215 159 80" or "AmmoAPColor"))

    local recoil = row.idRatAPRecoil
    recoil:SetVisible(not not show_recoil)
    if show_recoil then
        recoil:SetText(T {ap_breakdown_labels.recoil, r = parts.recoil_text})
    end
end

-- ok

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [553504408105] = "Unknown Modifiers",
    [771402935518] = "STN",
    [771402935519] = "ROT",
    [771402935520] = "SHT",
    [771402935521] = "AIM",
    [771402935522] = "<color AmmoAPColor>RECOIL: +<r>/aim</color>"
}

ratG_T_table['SOURCE_shooting_stance_crosshair_ui.lua'] = t_id_table
