local file_str = 'DESCRIPTION_HINTS_get.lua'

---- every Hint* value with a nil unit is the gun alone: no stat bonus or penalty (the grey bracket)
local HintNoStats = {placeholder = true, Marksmanship = 0, Dexterity = 0, Agility = 0, Strength = 0}
local HintFullStats = {placeholder = true, Marksmanship = 100, Dexterity = 100, Agility = 100, Strength = 100}

---- the caliber's kick at Strength 100 belongs to the gun; only the Strength penalty above it is the merc's
local function HintRecoil(weapon, attacker)
    local recoil = GetWepRecoil(weapon, attacker, true) * GetCaliberStrRecoil(weapon, attacker or HintFullStats)
    if attacker then
        recoil = recoil * GetRecoilOther(weapon, attacker, false)
    end
    return cRound(recoil * 100)
end

---- aim 0 = hipfire, 1 = snapshot; Reflexes factor mirrors CTH_hipfire_and_snapshot.lua (classic)
---- and Rat_StepAttrMul (aCTH), which both scale the same step excess the weapon mul does
local function HintHipSnap(weapon, aim, unit, acth)
    local mul = GetWeaponHipfireOrSnapshotMul(weapon, false, false, true, aim)
    if unit and acth then
        return MulDivRound(cRound(mul * 100), Rat_StepAttrMul(unit, nil, aim), 100)
    elseif unit then
        mul = mul * (1.35 - 0.70 * rGetReflex(unit) / 100)
    end
    return cRound(mul * 100)
end

---- classic Hand-Eye scale, as % (CTH_aim.lua / CTH_pointblank.lua)
local function HintHandEyeScale(unit)
    local min, max = const.Combat.R_MinAimScaling, const.Combat.R_MaxAimScaling
    return Clamp(min + MulDivRound(max - min, rGetHandEyeCoordination(unit) - 10, 90), min, max)
end

---- Hand-Eye scaling mirrors CTH_pointblank.lua; a negative bonus scales inversely there
local function HintPB(weapon, unit)
    local pb = GetPBbonus(weapon)
    if not unit then
        return pb
    end
    local scale = HintHandEyeScale(unit)
    if pb < 0 then
        scale = 150 - scale
    end
    return MulDivRound(pb, scale, 100)
end

---- per-aim-level bonus in hundredths. Classic mirrors CTH_aim.lua; aCTH mirrors Rat_ApertureAimDecay,
---- whose closing is proportional to AimAccuracy x Hand-Eye while A.DecayBase is 0
local function HintAim(weapon, unit, acth)
    local acc = weapon.AimAccuracy * 100
    if acth then
        return unit and MulDivRound(acc, Clamp(rGetHandEyeCoordination(unit), 10, 100), 100) or acc
    end
    if IsKindOfClasses(weapon, "Pistol", "Revolver") then
        acc = acc / 2
    end
    if GetComponentEffectValue(weapon, "ReduceAimAccuracy", "cth_penalty") then
        acc = acc / 2
    end
    if weapon:HasComponent("light_stock_aim_reduce") then
        acc = MulDivRound(acc, 90, 100)
    end
    return MulDivRound(MulDivRound(acc, unit and HintHandEyeScale(unit) or 100, 100), const.Combat.R_AimMul, 100)
end

---- classic aim is fractional per level; aCTH's is an integer stat
local function HintAimText(v, acth)
    if acth then
        return tostring(MulDivRound(v, 1, 100))
    end
    v = MulDivRound(v, 1, 10)
    return string.format("%d.%d", v / 10, v % 10)
end

---- mirrors ChangeWeapon.GetAPCost for this gun alone, in displayed AP
local function HintSwapAP(weapon)
    if IsKindOf(weapon, "HeavyWeapon") then
        return MulDivRound(R_VanillaAP(4), 1, const.Scale.AP)
    end
    local ap = weapon.Rat_swap_ap or 0
    if weapon:HasComponent("FreeWeaponSwap") then
        ap = Max(0, ap - 20)
    end
    if IsKindOfClasses(weapon, "Pistol", "Revolver") and not weapon.pistol_swap and ap < 20 then
        return 0
    end
    return ap
end

---- the weapon-only half of the fire modes' GetUIState (COMBAT_ACTIONS.lua): modes the gun lacks
local function HintAttackHidden(weapon, id)
    if not IsKindOf(weapon, "Firearm") then
        return false
    end
    if id == "BurstFire" then
        return not Rat_HasSelectiveBurst(weapon) or
                   (IsKindOf(weapon, "AR15") and not weapon:HasComponent("Enable_BurstFire"))
    elseif id == "SingleShot" then
        return weapon.AutoFireOnly
    elseif id == "MobileShot" then
        return weapon.AutoFireOnly and table.find(weapon.AvailableAttacks or empty_table, "RunAndGun")
    end
    return false
end

---- whose AP an attack is priced with: the owner, else the merc whose inventory is open.
---- GetAPCost needs a spawned Unit, so UnitData (satellite view, unit off map) gets nil
local function HintAPUnit(owner_id)
    local id = owner_id or (GetInventoryUnit() or SelectedObj or empty_table).session_id
    local unit = id and g_Units[id]
    return IsKindOf(unit, "Unit") and unit or nil
end

local HintMechanismLabel =ratT(file_str, 285374032193, "Operation")
local HintCyclingLabel = ratT(file_str, 608246246045, "Action")
local HintBurstCritLabel = ratT(file_str, 318826540120, "Selective Burst Critical Chance")
local HintAutoCritLabel = ratT(file_str, 318826540121, "Autofire Critical Chance")
local HintBurstRecoilLabel = ratT(file_str, 318826540123, "Selective Burst Recoil Penalty")
local HintAutoRecoilLabel = ratT(file_str, 318826540122, "Autofire Recoil Penalty")
local HintLongRecoilLabel = ratT(file_str, 318826540124, "Long Burst Recoil Penalty")
---- keyed without underscores: recoil_mechanism spells "Bolt_Action", Rat_cycling "BoltAction"
local HintMechanismNames = {
    GasOperated = ratT(file_str, 541468575245, "Gas Operated"),
    RecoilOperated = ratT(file_str, 372078613063, "Recoil Operated"),
    ShortRecoil = ratT(file_str, 951379947642, "Short Recoil"),
    RollerDelayed = ratT(file_str, 545422117275, "Roller-Delayed Blowback"),
    Blowback = ratT(file_str, 248357646755, "Blowback"),
    StrikerFired = ratT(file_str, 449197275880, "Striker Fired"),
    Revolver = ratT(file_str, 203993894214, "Revolver"),
    SingleShot = ratT(file_str, 305432457434, "Single Shot"),
    BreakAction = ratT(file_str, 134961306884, "Break Action"),
    PumpAction = ratT(file_str, 248130161322, "Pump Action"),
    BoltAction = ratT(file_str, 979693802164, "Bolt Action"),
    LeverAction = ratT(file_str, 387632024720, "Lever Action"),
    SingleAction = ratT(file_str, 747722846624, "Single Action"),
    DoubleAction = ratT(file_str, 949408355343, "Double Action"),
    SADoubleAction = ratT(file_str, 285374032194, "Single/Double Action"),
    SemiAuto = ratT(file_str, 608246246046, "Semi-Automatic"),
    Auto = ratT(file_str, 541468575246, "Automatic"),
}

---- one ammo's modifiers on the gun's own value, stacked the way Firearm:Reload adds them
local function HintAmmoProp(value, ammo, prop)
    for _, mod in ipairs(ammo and ammo.Modifications or empty_table) do
        if mod.target_prop == prop then
            value = MulDivRound(value, mod.mod_mul, 1000) + mod.mod_add
        end
    end
    return value
end

local function HintAmmoPellets(w, ammo)
    local n = HintAmmoProp(w.NumPellets or 0, ammo, "NumPellets")
    return n > 1 and n or nil
end

local function HintStanceAP(weapon, unit)
    unit = unit or HintNoStats
    return MulDivRound(GetWeapon_StanceAP(unit, weapon, true), 1, const.Scale.AP) +
               MulDivRound(Get_AimCost(unit), 1, const.Scale.AP)
end

---- manual cycle AP after a shot, Dexterity-reduced; nil when the gun cycles itself.
---- double_action: firing without cycling, which rat_get_manual_cyclingAP caps at the manual cost
local function HintCycleAP(weapon, unit, double_action)
    local da = weapon:HasComponent("DASA_action_ap")
    if double_action and not da or not (da or weapon:HasComponent("bolt_action_ap")) then
        return
    end
    return MulDivRound(rat_get_manual_cyclingAP(unit, weapon, double_action), 1, const.Scale.AP)
end

local function HintCritPerAim(weapon, unit)
    return MulDivRound(Rat_WeaponCritPerAim(weapon), unit and rGetHandEyeCoordination(unit) or 100, 100)
end

local function HintHundredths(v)
    local sign = v < 0 and "-" or ""
    v = abs(v)
    return string.format("%s%d.%02d", sign, v / 100, v % 100)
end

---- value in the panel's value style, units muted like vanilla's " AP"
local function HintMulText(v, extra)
    return HintHundredths(v) .. "<style PDABrowserTitleSmall>x" .. (extra or "") .. "</style>"
end

---- the Recoil row times the fire mode's own factors in GetRecoilOther; stance left out so the hint stays put
local function HintModeRecoil(weapon, unit, delta_prop, bump)
    local net = MulDivRound(HintRecoil(weapon, unit), weapon[delta_prop] or 100, 100)
    if bump and weapon:HasComponent("recoil_bump") then
        net = cRound(net * const.Combat.Recoil.Components.RecoilBumpMul)
    end
    if unit and unit:HasStatusEffect("AutoWeapons") then
        net = cRound(net * const.Combat.Recoil.Perks.AutoWeaponsMul)
    end
    return net
end

function Rat_HasBarrelRule(weapon)
    return (weapon.rat_barrel_len or 0) > 0 and Rat_CaliberDamage(weapon.Caliber) ~= nil
end

---- bar value of each row for the preset scan, taken for the gun alone and for a stat-100 merc; `range`
---- skips the scan and `ammo` rows scan every ammo of the caliber instead of the Basic one.
---- lower = smaller is better, which only picks the gap color: bars always grow with the value, like vanilla
local HintBarRows = {
    Pellets = {ammo = HintAmmoPellets},
    Spread = {lower = true, ammo = function(w, ammo)
        return HintAmmoPellets(w, ammo) and HintAmmoProp(w.BuckshotConeAngle or 0, ammo, "BuckshotConeAngle")
    end},
    RecStr = {lower = true, range = {30, 100}},
    StanceAP = {lower = true, value = HintStanceAP},
    CycleAP = {lower = true, value = HintCycleAP},
    ---- scan-only: double action shares the cycling bar, so its costs widen that range
    CycleDA = {into = "CycleAP", value = function(w, unit) return HintCycleAP(w, unit, true) end},
    Angle = {value = function(w) return w:GetProperty("OverwatchAngle") end},
    Reliability = {value = function(w) return w.Reliability end},
    Noise = {lower = true, value = function(w) return w.Noise end},
    ---- every ammo of the caliber, so HP/AP modifiers land inside the range
    Crit = {ammo = function(w, ammo) return HintAmmoProp(w.CritChance, ammo, "CritChance") end},
    CritPerAim = {value = HintCritPerAim},
    CritDamage = {ammo = function(w, ammo) return HintAmmoProp(w.CritDamage, ammo, "CritDamage") end},
    AimAccuracy = {value = function(w, unit) return HintAim(w, unit, IsACHTActive()) end},
    PB = {value = HintPB},
    Handling = {lower = true, value = function(w) return Rat_ApertureHandlingMul(w) end},
    Hipfire = {lower = true, value = function(w, unit) return HintHipSnap(w, 0, unit, IsACHTActive()) end},
    Snapshot = {lower = true, value = function(w, unit) return HintHipSnap(w, 1, unit, IsACHTActive()) end},
    Recoil = {lower = true, value = HintRecoil},
    RPM = {value = function(w) return w.RPM or 0 end, applies = function(w) return Rat_HasVariableAuto(w) end},
    Barrel = {value = function(w) return Rat_EffectiveBarrelLength(w) end, applies = function(w) return Rat_HasBarrelRule(w) end},
}

---- headroom past the stock extremes, since components push values beyond them
local HintBarPadPct = 15
local HintBarRanges

---- scans every firearm preset once per session
local function GetHintBarRanges()
    if HintBarRanges then
        return HintBarRanges
    end
    local lo, hi = {}, {}
    local function widen(id, v)
        lo[id] = Min(lo[id] or v, v)
        hi[id] = Max(hi[id] or v, v)
    end
    ForEachPreset("InventoryItemCompositeDef", function(preset)
        local class = g_Classes[preset.id]
        ---- unpatched presets keep raw values and would stretch every range
        if not Rat_IsLiveFirearm(class) or IsKindOf(class, "HeavyWeapon") then
            return
        end
        local w = PlaceInventoryItem(preset.id)
        ---- ammo rows read the unloaded gun, before the Basic modifiers below
        for _, def in ipairs(w.Caliber and GetAmmosWithCaliber(w.Caliber) or empty_table) do
            for id, row in pairs(HintBarRows) do
                local v = row.ammo and row.ammo(w, g_Classes[def.id])
                if v then
                    widen(id, v)
                end
            end
        end
        ---- loaded, since caliber noise (CaliberApplyParams) lives on the ammo, not the gun
        local ammo = Rat_BasicAmmoClass(w)
        ---- same modifiers Firearm:Reload adds, without spawning ammo items
        for _, mod in ipairs(ammo and ammo.Modifications or empty_table) do
            w:AddModifier("ammo", mod.target_prop, mod.mod_mul, mod.mod_add)
        end
        for id, row in pairs(HintBarRows) do
            if row.value and (not row.applies or row.applies(w)) then
                for _, unit in ipairs{false, HintFullStats} do
                    local ok, v = pcall(row.value, w, unit or nil)
                    if ok and v then
                        widen(row.into or id, v)
                    end
                end
            end
        end
        DoneObject(w)
    end)
    HintBarRanges = {}
    for id in pairs(lo) do
        local pad = Max(1, MulDivRound(hi[id] - lo[id], HintBarPadPct, 100))
        HintBarRanges[id] = {lo[id] - pad, hi[id] + pad}
    end
    return HintBarRanges
end

---- ~150ms: run it behind the loading screen instead of on the first hover
function OnMsg.NewMapLoaded()
    GetHintBarRanges()
end

local function HintBarFrac(id, v)
    local r = HintBarRows[id] and HintBarRows[id].range or GetHintBarRanges()[id]
    if not r or not v then
        return
    end
    return Clamp(MulDivRound(v - r[1], 1000, r[2] - r[1]), 0, 1000)
end

---- 4 segment images + 3 dividers per bar from tools/gen_hint_bars.py, which holds every colour. XText
---- truncates each <image> to whole pixels, so a fixed image count keeps rows equal at any UI scale
local HintBarSeg, HintBarSegs = 10, 4
local HintBarImg = "Mod/cfahRED/Images/HintBar/"

---- ref is the gun alone. The span between it and the owner's value is red when worse, green when
---- better; solid when the owner raises the value, hatched when the owner lowers it
local function HintBar(id, v, ref)
    local fv = HintBarFrac(id, v)
    if not fv then
        return "<image " .. HintBarImg .. "blank.png 1000>"
    end
    local fr = HintBarFrac(id, ref) or fv
    local lower = HintBarRows[id].lower
    local worse = (lower and fv > fr) or (not lower and fv < fr)
    local kind = (worse and "_w" or "_b") .. (fv < fr and "h" or "s")
    local total = HintBarSeg * HintBarSegs
    local lo, hi = MulDivRound(total, Min(fv, fr), 1000), MulDivRound(total, Max(fv, fr), 1000)
    local s = ""
    for i = 0, HintBarSegs - 1 do
        local a = i * HintBarSeg
        local f = Clamp(lo - a, 0, HintBarSeg)
        local r = Clamp(hi - a, 0, HintBarSeg) - f
        s = s .. (i > 0 and "<image " .. HintBarImg .. "div.png 1000>" or "") ..
                "<image " .. HintBarImg .. "b" .. f .. "_" .. r .. (r > 0 and kind or "") .. ".png 1000>"
    end
    return s
end

---- term = {label, value, suffix, bar =, bar_v =, bar_ref =, base =}; base is the grey reference
local function HintLine(term)
    local bar_ref = term.bar_ref or (type(term.base) == "number" and term.base)
    return HintBar(term.bar, term.bar_v or term[2], bar_ref) .. "  " ..
               "<color PDABrowserFlavorMedium>" .. term[1] .. "</color>" ..
               "<color PDABrowserTextHighlight>" .. term[2] .. "</color>" .. term[3] ..
               ((term.base and term.base ~= term[2]) and ("<color PDABrowserFlavor> (" .. term.base .. term[3] .. ")</color>") or "") ..
               "\n"
end

---- caliber stats live on the ammo; an unloaded gun shows its caliber's Basic ammo values
function Rat_BasicAmmoProp(weapon, prop)
    local value = weapon[prop]
    if not IsKindOf(weapon, "Firearm") or weapon.ammo then
        return value
    end
    return HintAmmoProp(value, Rat_BasicAmmoClass(weapon), prop)
end

function Rat_DisplayPenetrationClass(weapon)
    return Clamp(Rat_BasicAmmoProp(weapon, "PenetrationClass"), 1, #PenetrationClassIds)
end

---- caliber stats, shared by the weapon rollover's ammo panel and the ammo item rollover.
---- A row reads `prop` through the ammo, or `value(item)`; `show(v)` hides it
local CaliberHintRows = {
    {tid = 684546854913, text = "Base critical chance: ", prop = "CritChance", suffix = "%", bar = "Crit"},
    {tid = 247182652462, text = "Extra critical damage: ", prop = "CritDamage", suffix = "%", bar = "CritDamage"},
    {tid = 158466723759, text = "Recommended Strength: ", value = function(item) return (Recoil_StrBreakpoint(item)) end,
     suffix_tid = 785975283217, suffix = " STR", bar = "RecStr"},
    ---- slugs load 0 pellets; a lone ammo item has no gun to multiply
    {tid = 719583632117, text = "Number of Pellets: ", prop = "NumPellets", suffix = "", bar = "Pellets",
     show = function(v) return v > 1 end},
}

---- a Firearm reads its loaded (or Basic) ammo on its own stats; an Ammo item shows its modifiers on a zero base
local function CaliberHintValue(item, row)
    if row.value then
        return row.value(item)
    end
    if IsKindOf(item, "Ammo") then
        return HintAmmoProp(0, item, row.prop)
    end
    return Rat_BasicAmmoProp(item, row.prop)
end

function Rat_GetCaliberHints(item)
    if not IsKindOfClasses(item, "Firearm", "Ammo") then
        return ""
    end
    local s = ""
    for _, row in ipairs(CaliberHintRows) do
        local v = CaliberHintValue(item, row) or 0
        if not row.show or row.show(v) then
            s = s .. HintLine{TranslationTable[row.tid] or row.text, v,
                              row.suffix_tid and TranslationTable[row.suffix_tid] or row.suffix, bar = row.bar}
        end
    end
    return T{"<style CrosshairAPTotal>" .. s:sub(1, -2) .. "</style>"}
end

local function SetTemplateFunc(node, name, func)
    for _, child in ipairs(node) do
        if child.name == name then
            child.func = func
            return
        end
    end
end

local WeaponRolloverWidth = 470

---- the shop grid's PEN column reads the empty gun too
local BobbyRayStoreGetStats_Firearm_vanilla = BobbyRayStoreGetStats_Firearm
function BobbyRayStoreGetStats_Firearm(item)
    local stats = BobbyRayStoreGetStats_Firearm_vanilla(item)
    for _, stat in ipairs(stats) do
        if TGetID(stat[1]) == 842354777573 then
            stat[2] = GetPenetrationClassUIText(Rat_DisplayPenetrationClass(item))
        ---- vanilla CRIT is CritChance + level-scaled CritChanceScaled, which crit no longer reads
        elseif TGetID(stat[1]) == 921500948697 then
            stat[1] = ratT(file_str, 921500948698, "CRIT/AIM")
            stat[2] = Untranslated(HintHundredths(HintCritPerAim(item)) .. "%")
        end
    end
    return stats
end

function Rat_PatchWeaponRollover()
    ---- vanilla caps the weapon rollover at 370, which wraps every barred hint line
    local path = FindXtByProp(XTemplates.RolloverInventoryWeaponBase, "Id", "idContent")
    if path then
        path[1].MaxWidth = WeaponRolloverWidth
    end
    ---- Bobby Ray wraps the same rollover in its own 350 cap
    path = FindXtByProp(XTemplates.RolloverInventoryBobbyRay, "__template", "RolloverInventoryWeapon")
    if path then
        path[1].MaxWidth = WeaponRolloverWidth
    end
    ---- header AP: vanilla shows the raw ShootAP/AttackAP; price the default attack like the More Info list
    path = FindXtByProp(XTemplates.RolloverInventoryWeaponBase, "comment", "ap indicator")
    if path then
        local node = path[1]
        node.rat_vanilla_update = node.rat_vanilla_update or node.OnContextUpdate
        local vanilla_update = node.rat_vanilla_update
        node.OnContextUpdate = function(self, context, ...)
            local weapon = ResolvePropObj(self.context)
            local unit = IsKindOf(weapon, "Firearm") and HintAPUnit(weapon.owner)
            local action = unit and CombatActions[weapon:GetBaseAttack(unit, true)]
            local ap = action and action:GetAPCost(unit, {weapon = weapon})
            if not ap or ap == -1 then
                return vanilla_update(self, context, ...)
            end
            self:SetText(T{519320974014, "<apn(ap)> <style PDARolloverHeaderDark>AP</style>", ap = ap})
            XContextControl.OnContextUpdate(self, context)
        end
    end
    path = FindXtByProp(XTemplates.RolloverInventoryWeaponBase, "comment", "penetration")
    if path then
        SetTemplateFunc(path[1], "CreatePropValText(self, value, scale)", function(self, value, scale)
            local obj = ResolvePropObj(self.context)
            return GetPenetrationClassUIText(IsKindOf(obj, "Firearm") and Rat_DisplayPenetrationClass(obj) or value)
        end)
    end
    ---- caliber rows in both rollovers. Weapon: the first "ammo" block is the gun's own caliber row (the second
    ---- is the subweapon's). Ammo item: the generic rollover's "ammo" group, after vanilla's modifier list
    for _, tmpl in ipairs{XTemplates.RolloverInventoryWeaponBase, XTemplates.RolloverInventoryBase} do
        path = FindXtByProp(tmpl, "comment", "ammo")
        if path and not FindXtByProp(path[1], "Id", "idRatCaliberHints") then
            table.insert(path[1], PlaceObj("XTemplateWindow", {
                "__class", "XText",
                "Id", "idRatCaliberHints",
                "Margins", box(0, 4, 0, 0),
                "HandleMouse", false,
                "TextStyle", "InventoryRolloverHint",
                "Translate", true,
                "HideOnEmpty", true,
                "FoldWhenHidden", true,
            }, {
                PlaceObj("XTemplateFunc", {
                    "name", "Open(self)",
                    "func", function(self)
                        XText.Open(self)
                        self:SetText(Rat_GetCaliberHints(ResolvePropObj(self.context)))
                    end,
                }),
            }))
        end
    end
    ---- More Info panel: attack AP list skips hidden fire modes; swap/reload AP and mechanism below it
    path = FindXtByProp(XTemplates.InventoryRolloverInfo, "class", "XTemplateForEach")
    if path then
        local each = path[1]
        ---- kept on the node so a Lua reload doesn't wrap the wrapper
        each.rat_vanilla_condition = each.rat_vanilla_condition or each.condition
        local vanilla_condition = each.rat_vanilla_condition
        each.condition = function(parent, context, item, i)
            return vanilla_condition(parent, context, item, i) and not HintAttackHidden(ResolvePropObj(context), item)
        end
        ---- vanilla prices only an equipped gun; anything else fell back to ShootAP + ActionPointDelta
        each.rat_vanilla_run_after = each.rat_vanilla_run_after or each.run_after
        local vanilla_run_after = each.rat_vanilla_run_after
        each.run_after = function(child, context, item, i, n, last)
            vanilla_run_after(child, context, item, i, n, last)
            local weapon = ResolvePropObj(context)
            local unit = HintAPUnit(child.parent:GetContext().owner)
            local ap = unit and CombatActions[item]:GetAPCost(unit, {weapon = weapon})
            if ap and ap ~= -1 then
                child.idPropVal:SetValueText(T{499138807753, "<val><style PDABrowserTitleSmall> AP</style>",
                                               val = MulDivRound(ap, 1, const.Scale.AP)})
            end
            ---- the length that cost pays for, since the wheel changes it
            if Rat_IsVariableAuto(CombatActions[item]) and IsKindOf(weapon, "Firearm") then
                child.idPropVal:SetNameText(T{396207518843, "<action> (<num> rounds)", action = CombatActions[item].DisplayName,
                                              num = Rat_AutoPricedShots(CombatActions[item], weapon)})
            end
        end
        local old = table.find(path[2], "Id", "idRatHandlingAP")
        if old then
            table.remove(path[2], old)
        end
        local function row(id)
            return PlaceObj("XTemplateWindow", {
                "__class", "XNameValueText",
                "Id", id,
                "TextStyle", "PDABrowserTitleSmall",
                "TextStyleRight", "PDASectorInfo_SectionItem",
                "FoldWhenHidden", true,
            })
        end
        table.insert(path[2], PlaceObj("XTemplateWindow", {
            "__class", "XContextWindow",
            "Id", "idRatHandlingAP",
            "IdNode", true,
            "LayoutMethod", "VList",
            "FoldWhenHidden", true,
        }, {
            row("idSwap"),
            row("idReload"),
            row("idMechanism"),
            row("idCycling"),
            row("idBurstCrit"),
            row("idAutoCrit"),
            row("idBurstRecoil"),
            row("idAutoRecoil"),
            row("idLongRecoil"),
            PlaceObj("XTemplateFunc", {
                "name", "Open(self)",
                "func", function(self)
                    XContextWindow.Open(self)
                    local weapon = ResolvePropObj(self.context)
                    if not IsKindOf(weapon, "Firearm") then
                        self:SetVisible(false)
                        return
                    end
                    local ap = "<val><style PDABrowserTitleSmall> AP</style>"
                    self.idSwap:SetNameText(CombatActions.ChangeWeapon.DisplayName)
                    self.idSwap:SetValueText(T{499138807753, ap, val = HintSwapAP(weapon)})
                    self.idReload:SetNameText(CombatActions.Reload.DisplayName)
                    self.idReload:SetValueText(T{499138807753, ap, val = MulDivRound(weapon.ReloadAP or 0, 1, const.Scale.AP)})
                    local shown
                    for _, r in ipairs{{self.idMechanism, HintMechanismLabel, "recoil_mechanism"},
                                       {self.idCycling, HintCyclingLabel, "Rat_cycling"}} do
                        local text = HintMechanismNames[(weapon[r[3]] or ""):gsub("_", "")]
                        ---- manual actions name both the same (Bolt Action / Bolt Action)
                        r[1]:SetVisible(not not text and text ~= shown)
                        shown = text
                        r[1]:SetNameText(r[2])
                        r[1]:SetValueText(text or "")
                    end
                    local attacks = weapon.AvailableAttacks or empty_table
                    local has_burst = Rat_HasSelectiveBurst(weapon) and table.find(attacks, "BurstFire") and
                                          not HintAttackHidden(weapon, "BurstFire")
                    local owner = weapon.owner and (not gv_SatelliteView and g_Units[weapon.owner] or gv_UnitData[weapon.owner])
                    local function recoil_row(win, label, attack, delta_prop, bump)
                        local delta = weapon[delta_prop] or 100
                        return {win, label, delta ~= 100 and attack, function()
                            return HintMulText(HintModeRecoil(weapon, owner, delta_prop, bump),
                                               string.format(" (%+d%%)", delta - 100))
                        end}
                    end
                    for _, r in ipairs{
                        {self.idBurstCrit, HintBurstCritLabel, has_burst,
                         function() return HintMulText(weapon.BurstCritMul or 100) end},
                        {self.idAutoCrit, HintAutoCritLabel, Rat_HasVariableAuto(weapon),
                         function() return HintMulText(const.Combat.AutoFireCritMul) end},
                        recoil_row(self.idBurstRecoil, HintBurstRecoilLabel, has_burst, "burst_recoil_delta", true),
                        recoil_row(self.idAutoRecoil, HintAutoRecoilLabel,
                                   table.find(attacks, "AutoFire") and not HintAttackHidden(weapon, "AutoFire"),
                                   "auto_recoil_delta", true),
                        recoil_row(self.idLongRecoil, HintLongRecoilLabel, table.find(attacks, "MGBurstFire"),
                                   "long_recoil_delta"),
                    } do
                        r[1]:SetVisible(not not r[3])
                        r[1]:SetNameText(r[2])
                        r[1]:SetValueText(r[3] and Untranslated(r[4]()) or "")
                    end
                end,
            }),
        }))
    end
    path = FindXtByProp(XTemplates.ModifyWeaponDlg, "Id", "idValue")
    if path then
        SetTemplateFunc(path[1], "Open(self)", function(self)
            XText.Open(self)
            self:SetText(GetArmorClassUIText(Rat_DisplayPenetrationClass(self.context)))
        end)
    end
end

function GBO_GetDescriptionHints(self)
    local formattedString = "<style CrosshairAPTotal>"

    local owner = self.owner and (not gv_SatelliteView and g_Units[self.owner] or gv_UnitData[self.owner])

    local angularCTHActive = IsACHTActive()
    ---- aCTH's Handling row reads no stat, unlike classic PB
    local classic_owner = not angularCTHActive and owner

    local stance_ap, crit_per_aim, recoil = HintStanceAP(self, owner), HintCritPerAim(self, owner), HintRecoil(self, owner)
    local hip, snap = HintHipSnap(self, 0, owner, angularCTHActive), HintHipSnap(self, 1, owner, angularCTHActive)
    local pb = HintPB(self, classic_owner)
    local handling = Rat_ApertureHandlingMul(self)
    local aim = HintAim(self, owner, angularCTHActive)
    local aim_ref = owner and HintAim(self, nil, angularCTHActive)

    local reliability_suffix = "%"
    if Platform.rat then
        local jam = self.Condition < const.Weapons.JamConditionGate and self:GetJamChance(owner or HintFullStats, self.Condition) or 0
        reliability_suffix = string.format("%% (jam %d%%)", jam)
    end

	local termList = {
	    {
	        id = "ShootingStanceCost",
	        TranslationTable[242435461626] or "Shooting Stance Cost: ",
	        stance_ap, " AP",
	        base = owner and HintStanceAP(self),
	        bar = "StanceAP",
	    },
	    {
	        id = "ShootingAngle",
	        TranslationTable[766379566745] or "Shooting Angle: ",
	        string.format("%.2f", self:GetProperty("OverwatchAngle") / 60.0), "º",
	        bar = "Angle", bar_v = self:GetProperty("OverwatchAngle"),
	    },
	    {
	        id = "Reliability",
	        TranslationTable[412593832155] or "Reliability: ",
	        self.Reliability, reliability_suffix,
	        bar = "Reliability",
	    },
	    {
	        id = "NoiseRadius",
	        TranslationTable[654134899415] or "Noise Radius: ",
	        Rat_BasicAmmoProp(self, "Noise"), " tiles",
	        bar = "Noise",
	    },
	    {
	        id = "CriticalPerAim",
	        TranslationTable[318826540117] or "Critical chance per aim: ",
	        HintHundredths(crit_per_aim), "%",
	        base = owner and HintHundredths(HintCritPerAim(self)),
	        bar = "CritPerAim", bar_v = crit_per_aim, bar_ref = owner and HintCritPerAim(self),
	    },
		{
			id = "AimAccuracy",
			TranslationTable[219437987174] or "Aim accuracy: ",
			HintAimText(aim, angularCTHActive), "",
			base = aim_ref and HintAimText(aim_ref, angularCTHActive),
			bar = "AimAccuracy", bar_v = aim, bar_ref = aim_ref,
		},
	    angularCTHActive and {
	        id = "PointBlankRangeAccuracy",
	        TranslationTable[184329577856] or "Handling Penalty Multiplier: ",
			---- em aCTH o manejo e multiplicador de cone: mesma leitura de hipfire/snapshot/recoil, MENOR = melhor
	        HintHundredths(handling), "X",
	        bar = "Handling", bar_v = handling,
	    } or {
	        id = "PointBlankRangeAccuracy",
	        TranslationTable[651371401489] or "Point Blank Range Accuracy: ",
	        pb, "%",
	        base = classic_owner and GetPBbonus(self),
	        bar = "PB",
	    },
	    {
	        id = "HipfirePenaltyMultiplier",
	        TranslationTable[852084205321] or "Hipfire Penalty Multiplier: ",
	        HintHundredths(hip), "X",
	        base = owner and HintHundredths(HintHipSnap(self, 0)),
	        bar = "Hipfire", bar_v = hip, bar_ref = owner and HintHipSnap(self, 0),
	    },
	    {
	        id = "SnapshotPenaltyMultiplier",
	        TranslationTable[258395588915] or "Snapshot Penalty Multiplier: ",
	        HintHundredths(snap), "X",
	        base = owner and HintHundredths(HintHipSnap(self, 1)),
	        bar = "Snapshot", bar_v = snap, bar_ref = owner and HintHipSnap(self, 1),
	    },
	    {
	        id = "RecoilPenaltyMultiplier",
	        TranslationTable[151451884832] or "Recoil Penalty Multiplier: ",
	        HintHundredths(recoil), "X",
	        base = owner and HintHundredths(HintRecoil(self)),
	        bar = "Recoil", bar_v = recoil, bar_ref = owner and HintRecoil(self),
	    },
	}

	local cycle_ap = HintCycleAP(self, owner)
	if cycle_ap then
		table.insert(termList, table.find(termList, "id", "ShootingStanceCost") + 1, {
			id = "CyclingCost",
			TranslationTable[573918264051] or "Cycling Cost: ",
			cycle_ap, " AP",
			base = owner and HintCycleAP(self),
			bar = "CycleAP",
		})
	end
	local da_ap = HintCycleAP(self, owner, true)
	if da_ap then
		table.insert(termList, table.find(termList, "id", "CyclingCost") + 1, {
			id = "DoubleActionCost",
			TranslationTable[524204987393] or "Double Action Cost: ",
			da_ap, " AP",
			base = owner and HintCycleAP(self, nil, true),
			bar = "CycleAP",
		})
	end

	---- barrels change the spread, so it stays with the gun; the loaded (or Basic) ammo still widens it
	if (Rat_BasicAmmoProp(self, "NumPellets") or 0) > 1 then
		local spread = Rat_BasicAmmoProp(self, "BuckshotConeAngle") or 0
		table.insert(termList, {
			id = "PelletSpreadAngle",
			TranslationTable[193184162359] or "Pellet Spread Angle: ",
			string.format("%.2f", spread / 60.0), "º",
			bar = "Spread", bar_v = spread,
		})
	end

	if Rat_HasVariableAuto(self) then
		local tenths = MulDivRound(Rat_AutoAPPerRound(self), 10, const.Scale.AP)
		table.insert(termList, {
			id = "RateOfFire",
			TranslationTable[638215904417] or "Rate of Fire: ",
			self.RPM or 0,
			string.format(" RPM (<color PDABrowserTextHighlight>%d.%d</color> ", tenths / 10, tenths % 10) ..
				_InternalTranslate(ratT(file_str, 638215904418, "AP/extra round")) .. ")" ..
				(self.AutoFireOnly and (TranslationTable[638215904419] or ", full auto only") or ""),
			bar = "RPM",
		})
	end

	---- only where length drives damage (no flare gun, no 12 gauge); grey is the stock barrel
	if Rat_HasBarrelRule(self) then
		local barrel = Rat_EffectiveBarrelLength(self)
		table.insert(termList, {
			id = "BarrelLength",
			TranslationTable[529418307726] or "Barrel Length: ",
			barrel, " mm",
			base = barrel ~= self.rat_barrel_len and self.rat_barrel_len or nil,
			---- no better/worse span: length is a trade-off
			bar = "Barrel", bar_ref = barrel,
		})
	end

	local AngularCthActiveExclusionList = {
		--PointBlankRangeAccuracy = true
	}


	for _, term in ipairs(termList) do
		if not angularCTHActive or not AngularCthActiveExclusionList[term.id] then
	    	formattedString = formattedString .. HintLine(term)
		end
	end

	formattedString = formattedString .. "</style>"

	if self:IsCumbersome() then
	    local cumbersome_text = TranslationTable[153781665575] or
	        "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by <ap> (negated by high Strength)\n"
	    -- function replacement: the AP value is not a gsub pattern
	    formattedString = formattedString .. cumbersome_text:gsub("<ap>", function() return tostring(R_VanillaAPToDisplay(1)) end)
	end

	return T {formattedString}
end



local t_id_table = {
    [153781665575] = "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by <ap> (negated by high Strength)\n",
    [242435461626] = "Shooting Stance Cost: ",
    [573918264051] = "Cycling Cost: ",
    [524204987393] = "Double Action Cost: ",
    [766379566745] = "Shooting Angle: ",
    [412593832155] = "Reliability: ",
    [654134899415] = "Noise Radius: ",
    [684546854913] = "Base critical chance: ",
    [318826540117] = "Critical chance per aim: ",
    [247182652462] = "Extra critical damage: ",
    [651371401489] = "Point Blank Range Accuracy: ",
    [852084205321] = "Hipfire Penalty Multiplier: ",
    [258395588915] = "Snapshot Penalty Multiplier: ",
    [151451884832] = "Recoil Penalty Multiplier: ",
    [158466723759] = "Recommended Strength: ",
    [785975283217] = " STR",
    [719583632117] = "Number of Pellets: ",
    [193184162359] = "Pellet Spread Angle: ",
	[184329577856] = "Handling Penalty Multiplier: ",
	[219437987174] = "Aim accuracy: ",
	[638215904417] = "Rate of Fire: ",
	[529418307726] = "Barrel Length: ",
	[396207518843] = "<action> (<num> rounds)",
	--[638215904418] = "AP per extra round",

}

ratG_T_table[file_str] = ratG_T_table[file_str] or {}

for id, text in pairs(t_id_table) do
    ratG_T_table[file_str][id] = text
end
