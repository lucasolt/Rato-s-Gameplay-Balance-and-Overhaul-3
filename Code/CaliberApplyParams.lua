function ApplyAmmoParams(class_id, class, ...)

    if not class then
        print("GBO - error, Ammo class not found for ID:", class_id)
        return
    end

    local function PlaceCaliberModificationObj(args)
        return PlaceObj("CaliberModification", args)
    end

    local function GBO_GetNoiseValue(caliber)
        local function extractNumberWithSignFromString(str)
            if not str then
                return false
            end
            local num = tonumber(string.match(str, "[+-]?%d+"))
            if num then
                return num
            else
                return false
            end
        end

        local noise_setting =
            extractNumberWithSignFromString(CurrentModOptions['noise_setting_num']) or 100
        local caliber_noise = const.Calibers.Noise[caliber]
        return caliber_noise and Max(0, MulDivRound(caliber_noise, noise_setting, 100))
    end

    -- local function extract_suffix(caliber_string, class_caliber)
    --     return caliber_string:match("_" .. class_caliber .. "_(.+)")
    -- end

    -- function extract_suffix(caliber_string)
    --     return caliber_string:match("_%d*%a+_(.+)")
    -- end

    local valid_suffixes = {
        "Basic", "Buckshot", "AP", "HP", "Match", "Shock", "Tracer", "Subsonic", "Breacher",
        "Flechette", "Saltshot", "HE", "Incendiary", "SLAP"
    }

    function extract_suffix(caliber_string)
        for _, suffix in ipairs(valid_suffixes) do
            local pattern = "_" .. suffix .. "$" -- Ensure it ends with _suffix
            if caliber_string:match(pattern) then
                return suffix
            end
        end
        return "nil"
    end

    local fallback_map = {
        small = "_9mm",
        medium = "_556",
        medium_large = "_762WP",
        large = "_762NATO",
        extra_large = "_50BMG"
    }

    local function get_fallback(caliber)
        local category
        for cat, calibers in pairs(ratG_recoilData) do
            if calibers[caliber] then
                category = cat
                break
            end
        end
        local fallback = category and fallback_map[category] and
                             const.Calibers[fallback_map[category]] and
                             table.copy(const.Calibers[fallback_map[category]])

        if fallback then
            if fallback.Modifiers then
                fallback.Modifiers.CritDamage = nil
            end
            fallback.Description = nil
        end
        -- print("using fallback for caliber: ", caliber)
        return fallback
    end

    local params = ... or {}

    local icon_calibers = {"7_62x54R", "5_45x39", "5_7x28"}

    local class_caliber = class.Caliber

    if class_caliber then
        if table.find(icon_calibers, class_caliber) then
            class.Icon = "Mod/cfahRED/Images/" .. class_id .. ".png"
            -- ic(class.Icon)
        end

        if const.Calibers["_" .. class_caliber] then
            table.insert(params, const.Calibers["_" .. class_caliber])
        else
            local fallback = get_fallback(class_caliber)
            if fallback then
                table.insert(params, fallback)
            end
        end

        local ammo_type = extract_suffix(class_id) -- extract_suffix(class_id, class_caliber)
        -- ic(class_id, ammo_type)
        if const.Calibers[ammo_type] then
            table.insert(params, const.Calibers[ammo_type])
        end

        local noise_value = GBO_GetNoiseValue(class_caliber)
        if noise_value then
            table.insert(params, {Modifications = {Noise = noise_value}})
        end
    end

    class.AppliedEffects = {}
    local caliber_data = {Modifications = {}}

    local need_special_processing = {"AppliedEffects", "Modifications", "CostMul", "Cost"}

    for i, ttable in ipairs(params) do

        for k, v in pairs(ttable) do
            if not table.find(need_special_processing, k) then
                class[k] = v
            end
        end

        if ttable.Cost then
            caliber_data.Cost = ttable.Cost
        end
        if ttable.CostMul then
            caliber_data.CostMul = ttable.CostMul
        end

        local applied_effects = ttable.AppliedEffects or {}
        for _, eff in ipairs(applied_effects) do
            table.insert_unique(class.AppliedEffects, eff)
        end

        for k, v in pairs(ttable.Modifications or {}) do
            caliber_data.Modifications[k] = caliber_data.Modifications[k] or
                                                {mod_add = 0, mod_mul = false}
            if type(v) == "table" then
                caliber_data.Modifications[k].mod_add = caliber_data.Modifications[k].mod_add + v[1]
                caliber_data.Modifications[k].mod_mul =
                    (caliber_data.Modifications[k].mod_mul or 0) + v[2]
            else
                caliber_data.Modifications[k].mod_add = caliber_data.Modifications[k].mod_add + v
                caliber_data.Modifications[k].mod_mul = 1000
            end
        end

    end

    class.Modifications = {}
    if caliber_data.Cost then
        local costmul = caliber_data.CostMul
        class.Cost = costmul and MulDivRound(caliber_data.Cost, costmul, 100) or caliber_data.Cost
    end
    for k, v in pairs(caliber_data.Modifications) do
        local args = {target_prop = k, mod_add = v.mod_add, mod_mul = v.mod_mul or 1000}
        table.insert(class.Modifications, PlaceCaliberModificationObj(args))
    end
end

function OnMsg.ClassesGenerate(classdefs)
    local clb = const.Calibers

    local id_list = {
        "_12gauge_Breacher", "_12gauge_Buckshot", "_12gauge_Flechette", "_12gauge_Saltshot",
        "_20x81_Incendiary", "_20x82_Basic", "_20x82_HE", "_20x82_SLAP", "_22LR_AP", "_22LR_Basic",
        "_22LR_HP", "_22LR_Match", "_22LR_Tracer", "_280British_AP", "_280British_Basic",
        "_280British_HP", "_280British_Match", "_280British_Tracer", "_300Blackout_AP",
        "_300Blackout_Basic", "_300Blackout_HP", "_300Blackout_Match", "_300Blackout_Subsonic",
        "_300Blackout_Tracer", "_300WinMag_AP", "_300WinMag_Basic", "_300WinMag_HP",
        "_300WinMag_Match", "_300WinMag_Tracer", "_303_AP", "_303_Basic", "_303_HP", "_303_Match",
        "_303_Tracer", "_308Win_AP", "_308Win_Basic", "_308Win_HP", "_308Win_Match",
        "_308Win_Tracer", "_30_60_AP", "_30_60_Basic", "_30_60_HP", "_30_60_Match", "_30_60_Tracer",
        "_32ACP_AP", "_32ACP_Basic", "_32ACP_HP", "_32ACP_Match", "_32ACP_Tracer", "_32HRMAG_AP",
        "_32HRMAG_Basic", "_32HRMAG_HP", "_32HRMAG_Match", "_32HRMAG_Shock", "_32HRMAG_Tracer",
        "_338_Lapua_Magnum_AP", "_338_Lapua_Magnum_Basic", "_338_Lapua_Magnum_HP",
        "_338_Lapua_Magnum_Match", "_338_Lapua_Magnum_Tracer", "_357MAG_AP", "_357MAG_Basic",
        "_357MAG_HP", "_357MAG_Match", "_357MAG_Tracer", "_380ACP_AP", "_380ACP_Basic",
        "_380ACP_HP", "_380ACP_Match", "_380ACP_Tracer", "_38SP_AP", "_38SP_Basic", "_38SP_HP",
        "_38SP_Match", "_38SP_Tracer", "_408_ChayTac_AP", "_408_ChayTac_Basic", "_408_ChayTac_HP",
        "_408_ChayTac_Match", "_408_ChayTac_Tracer", "_40SW_AP", "_40SW_Basic", "_40SW_HP",
        "_40SW_Match", "_40SW_Tracer", "_44AMP_AP", "_44AMP_Basic", "_44AMP_HP", "_44AMP_Match",
        "_44AMP_Shock", "_44AMP_Subsonic", "_44AMP_Tracer", "_44CAL_AP", "_44CAL_Basic",
        "_44CAL_HP", "_44CAL_Match", "_44CAL_Shock", "_44MAG_AP", "_44MAG_Basic", "_44MAG_HP",
        "_44MAG_Match", "_44MAG_Shock", "_44MAG_Subsonic", "_44MAG_Tracer", "_45ACP_AP",
        "_45ACP_Basic", "_45ACP_HP", "_45ACP_Match", "_45ACP_Subsonic", "_45ACP_Tracer",
        "_4_6x30_AP", "_4_6x30_Basic", "_4_6x30_HP", "_4_6x30_Match", "_4_6x30_Tracer",
        "_4_7x33_AP", "_4_7x33_Basic", "_4_7x33_HP", "_4_7x33_Match", "_4_7x33_Tracer", "_50AE_AP",
        "_50AE_Basic", "_50AE_HP", "_50AE_Match", "_50AE_Shock", "_50AE_Tracer", "_50BMG_Basic",
        "_50BMG_HE", "_50BMG_Incendiary", "_50BMG_SLAP", "_556_AP", "_556_Basic", "_556_HP",
        "_556_Match", "_556_Tracer", "_5_45x39_AP", "_5_45x39_Basic", "_5_45x39_HP",
        "_5_45x39_Match", "_5_45x39_Tracer", "_5_7x28_AP", "_5_7x28_Basic", "_5_7x28_HP",
        "_5_7x28_Match", "_5_7x28_Tracer", "_6_5Creedmoor_AP", "_6_5Creedmoor_Basic",
        "_6_5Creedmoor_HP", "_6_5Creedmoor_Match", "_6_5Creedmoor_Tracer", "_6_5Grendel_AP",
        "_6_5Grendel_Basic", "_6_5Grendel_HP", "_6_5Grendel_Match", "_6_5Grendel_Tracer",
        "_762NATO_AP", "_762NATO_Basic", "_762NATO_HP", "_762NATO_Match", "_762NATO_Tracer",
        "_762WP_AP", "_762WP_Basic", "_762WP_HP", "_762WP_Match", "_762WP_Tracer", "_7_5x54_AP",
        "_7_5x54_Basic", "_7_5x54_HP", "_7_5x54_Match", "_7_5x54_Tracer", "_7_62x25_AP",
        "_7_62x25_Basic", "_7_62x25_HP", "_7_62x25_Match", "_7_62x25_Tracer", "_7_62x54_AP",
        "_7_62x54_Basic", "_7_62x54_HP", "_7_62x54_Match", "_7_62x54_Tracer", "_7_65x21_AP",
        "_7_65x21_Basic", "_7_65x21_HP", "_7_65x21_Match", "_7_65x21_Tracer", "_7_92x33_AP",
        "_7_92x33_Basic", "_7_92x33_HP", "_7_92x33_Match", "_7_92x33_Tracer", "_7_92x57_AP",
        "_7_92x57_Basic", "_7_92x57_HP", "_7_92x57_Match", "_7_92x57_Tracer", "_9mm_AP",
        "_9mm_Basic", "_9mm_HP", "_9mm_Match", "_9mm_Shock", "_9mm_Subsonic", "_9mm_Tracer",
        "_9x18_AP", "_9x18_Basic", "_9x18_HP", "_9x18_Match", "_9x18_Tracer", "_9x39_AP",
        "_9x39_Basic", "_9x39_HP", "_9x39_Match", "_9x39_Tracer", "_44CAL_Subsonic"
    }

    local extra_tables = {
        _12gauge_Breacher = clb.Slug,
        _556_AP = clb.IntermediateCalsAPparams,
        _5_45x39_AP = clb.IntermediateCalsAPparams
    }

    local id_dict = {}
    for _, id in ipairs(id_list) do
        local tbl = {}
        if extra_tables[id] then
            table.insert(tbl, extra_tables[id])
        end
        id_dict[id] = tbl
    end

    for id, v in pairs(id_dict) do
        ApplyAmmoParams(id, classdefs[id], v)
    end
end

function OnMsg.zCore_ClassesGenerate()
    ApplyAmmoParams("_44CAL_Subsonic", _44CAL_Subsonic, {})
end

function print_ammos()
    ForEachPreset("InventoryItemCompositeDef", function(p)
        if p.object_class == "Ammo" then
            print(p.id)
        end

    end)
end
