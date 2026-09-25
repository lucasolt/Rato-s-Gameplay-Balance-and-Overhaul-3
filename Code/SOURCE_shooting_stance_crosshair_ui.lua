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
        while args.num_shots and args.num_shots > Rat_AutoMinShots(action:GetAttackWeapons(attacker)) and
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

            ---------------------------
            local weapon = weapon1
            local unit = attacker
            local action = actualAction
            local ap_extra = unit:GetShootingStanceAP(
                                 args and args.target or false, weapon,
                                 args and args.aim or 0, action)

            local prep = ""
            ----------------------------^^

            local apCost = action:GetAPCost(attacker, args)

            ---------------------------
            if ap_extra > 0 then
                apCost = apCost - ap_extra
                -- local apCostshoot = (apCost - ap_extra)/ const.Scale.AP 
                ap_extra = ap_extra / const.Scale.AP
                prep = prep .. ap_extra .. "<style CrosshairAPTotal>+</style>"

            end

            local recoil = attacker:GetStatusEffect("Rat_recoil")
            local aim_pen_string = ""
            if recoil then
                local aim_penalty = recoil:ResolveValue("aim_cost")
                -- print("aim pen", aim_penalty)
                if aim_penalty and aim_penalty >= R_VanillaAPToDisplay(0.5) then
                    aim_penalty = formatNumber(aim_penalty)
                    aim_pen_string = "<scale 450><color AmmoAPColor>\naim: +" ..
                                         aim_penalty .. " AP</color>"
                end
            end

            ------------------------------------

            local free_move_ap_used = Min(args.ap_cost_breakdown.move_cost or 0,
                                          attacker.free_move_ap)
            apCost = apCost - Max(0, free_move_ap_used)
            -- round the cost to match before/after AP readings
            local unitAp = attacker:GetUIActionPoints()
            local before = unitAp / const.Scale.AP
            local after = (unitAp - apCost) / const.Scale.AP -- free move is already accounted for in apCost
            apCost = (before - after) * const.Scale.AP

            -- local has_movement = action.AimType == "melee"
            -- local apCost, unitAp = attacker:GetUIAdjustedActionCost(cost, has_movement)
            -- apCost, unitAp = apCost * const.Scale.AP, unitAp * const.Scale.AP

            ---- prep ..
            if g_Combat then
                self.idAPCostText:SetText(T {
                    prep ..
                        "<apn(apCost)><style CrosshairAPTotal><valign bottom -2>/<apn(unitAp)> AP</style>" ..
                        aim_pen_string,
                    apCost = apCost,
                    unitAp = unitAp,
                    aim_pen_string = aim_pen_string
                })
            else
                self.idAPCostText:SetText(T {
                    prep ..
                        "<apn(apCost)><style CrosshairAPTotal><valign bottom -2> AP</style>" ..
                        aim_pen_string,
                    apCost = apCost,
                    aim_pen_string = aim_pen_string
                })
            end
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

-- ok

---------------------------------------------------------------------------------------------------------

local t_id_table = {[553504408105] = "Unknown Modifiers"}

ratG_T_table['SOURCE_shooting_stance_crosshair_ui.lua'] = t_id_table
