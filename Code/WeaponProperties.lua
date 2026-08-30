function OnMsg.ClassesGenerate()

    AppendClass.FirearmProperties = {
        properties = {
            {
                -- category = "Caliber",
                id = "SingleShotCustomDeltaAP",
                name = "SingleShotCustomDelta AP",
                help = "(not in scale)",
                editor = "number",
                default = 0,
                template = true,
                min = -50,
                max = 50,
                modifiable = true
            }, {
                -- category = "Caliber",
                id = "AutoFireCustomDeltaAP",
                name = "AutoFireCustomDelta AP",
                help = "(not in scale)",
                editor = "number",
                default = 0,
                template = true,
                min = -50,
                max = 50,
                modifiable = true
            }, {
				category = "GBO",
                id = "ConditionDegradationMul",
                name = "ConditionDegradationMul",
                help = "",
                editor = "number",
                default = 100,
                template = true,
                min = 0,
                max = 1000,
                modifiable = true
			}, {
				category = "GBO_aCTH",
                id = "HandlingMul",
                name = "HandlingMul",
                help = "",
                editor = "number",
                default = 100,
                template = true,
                min = 0,
                max = 1000,
                modifiable = true

			}

        }
    }

    SubmachineGun.SingleShotCustomDeltaAP =
        1
	
end

function fireprop()

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "APStance",
        name = "Shooting Stance AP",
        help = "Ap to enter Shooting Stance (not in scale)",
        editor = "number",
        default = 3,
        template = true,
        min = 0,
        max = 50,
        modifiable = true
    }


    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "APStance_display",
        name = "Shooting Stance AP",
        help = "Ap to enter Shooting Stance (not in scale)",
        editor = "number",
        default = false,
        template = false,
        min = 0,
        max = 50,
        modifiable = false
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "description_hints",
        name = "description_hints",
        help = "description_hints",
        editor = "text",
        default = "",
        template = false,
        modifiable = false
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "default_long_barrel",
        name = "Default long barrel",
        help = "weapon default barrel is considered long",
        editor = "bool",
        default = false,
        template = true,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "STR_RECOIL",
        name = "STR_RECOIL",
        help = "STR_RECOIL",
        editor = "number",
        default = 1,
        template = false,
        min = 1,
        max = 100,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "PBbonus_display",
        name = "PBbonus_display",
        help = "PBbonus_display",
        editor = "number",
        default = 15,
        template = false,
        min = -50,
        max = 50,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "Recoil_mul",
        name = "Recoil_mul",
        help = "ARecoil_mul",
        editor = "number",
        default = 1,
        template = false,
        min = 0,
        max = 50,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "angle_display",
        name = "Shooting Angle in Degrees",
        help = "Shooting Angle in Degrees",
        editor = "number",
        default = 1,
        template = false,
        min = 0,
        max = 500,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "CritDamage",
        name = "Extra Critical Damage",
        help = "Weapon Critical Damage",
        editor = "number",
        default = 0,
        template = true,
        min = -200,
        max = 200,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "Hipfire_mul", -----Display
        name = "hipfire_mul",
        help = "hipfire_mul",
        editor = "number",
        default = 1,
        template = false,
        min = 0,
        max = 500,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "Snapshot_mul", -----Display
        name = "snapshot_mul",
        help = "snapshot_mul",
        editor = "number",
        default = 1,
        template = false,
        min = 0,
        max = 500,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "tracer",
        name = "Tracer Ammo Loaded",
        help = "Tracer Ammo Loaded",
        editor = "number",
        default = 0,
        template = false,
        min = 0,
        max = 1,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "ArmorPir",
        name = "AP Ammo Loaded",
        help = "AP Ammo Loaded",
        editor = "number",
        default = 0,
        template = false,
        min = 0,
        max = 1,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "wep_base_recoil_mul",
        name = "Weapon Base Recoil Multiplier",
        help = "Weapon Base Recoil Multiplier",
        editor = "number",
        default = 100,
        template = true,
        min = 0,
        max = 1000,
        modifiable = true
    }

    -- FirearmProperties.properties[#FirearmProperties.properties + 1] = {
    --     category = "Caliber",
    --     id = "placeholder_recoil",
    --     name = "placeholder_recoil",
    --     help = "placeholder_recoil",
    --     editor = "number",
    --     default = 100,
    --     template = true,
    --     min = 0,
    --     max = 1000,
    --     modifiable = true
    -- }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "burst_selective",
        name = "Selective Burst Fire",
        help = "Just for metaText display, normally coupled with lower burst delta",
        editor = "bool",
        default = false,
        template = true,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "auto_recoil_delta",
        name = "Autofire Recoil Delta",
        help = "Autofire Recoil Delta",
        editor = "number",
        default = 100,
        template = true,
        min = 0,
        max = 500,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "long_recoil_delta",
        name = "Long Burst Recoil Delta",
        help = "Long Burst Recoil Delta",
        editor = "number",
        default = 100,
        template = true,
        min = 0,
        max = 500,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "wep_base_hip_mul",
        name = "Weapon Base Hipfire Multiplier",
        help = "Weapon Base Hipfire Multiplier",
        editor = "number",
        default = 100,
        template = true,
        min = 0,
        max = 1000,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "wep_base_snapshot_mul",
        name = "Weapon Base Snapshot Multiplier",
        help = "Weapon Base Snapshot Multiplier",
        editor = "number",
        default = 100,
        template = true,
        min = 0,
        max = 1000,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "burst_shots",
        name = "Number of Burst Shots",
        help = "Number of Burst Shots",
        editor = "number",
        default = 3,
        template = true,
        min = 1,
        max = 20,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "auto_shots",
        name = "Number of Auto Fire Shots",
        help = "Number of Auto Fire Shots",
        editor = "number",
        default = 10,
        template = true,
        min = 1,
        max = 20,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "long_shots",
        name = "Number of Long Burst Shots",
        help = "Number of Long Burst Shots",
        editor = "number",
        default = 6,
        template = true,
        min = 1,
        max = 20,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "unwieldy_weapon",
        name = "Unwieldy Weapon",
        help = "Gives a penalty if fired without being prone",
        editor = "bool",
        default = false,
        template = true,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        category = "Caliber",
        id = "weigth_held_mul",
        name = "Penalty Multiplier for Held MG fire",
        help = "Penalty Multiplier for Held MG fire",
        editor = "number",
        default = 100,
        template = true,
        min = 1,
        max = 500,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "pistol_swap",
        name = "Pistol-like free swap",
        help = "Pistol-like free swap",
        editor = "bool",
        default = false,
        template = true,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {

        id = "rat_scope_block",
        name = "Scope Block Folding Stock",
        help = "Scope Block Folding Stock",
        editor = "bool",
        default = false,
        template = true,
        modifiable = true
    }

    --[[FirearmProperties.properties[#FirearmProperties.properties+1] = {
        --category = "Caliber",
        id = "R_cycling",
        name = "Cycling Mechanism",
        help = "1 = Semi Auto",
        editor = "text",
        default = "",
		template = true,
		modifiable = true
    }
	
	FirearmProperties.properties[#FirearmProperties.properties+1] = {
        --category = "Caliber",
        id = "lever_action",
        name = "Lever Action",
        help = "Lever Action",
        editor = "bool",
        default = false,
		template = true,
		modifiable = true
    }]]

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "Rat_swap_ap",
        name = "Swap AP",
        help = "Swap AP (not in scale)",
        editor = "number",
        default = 2,
        template = true,
        min = 0,
        max = 50,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "unbolted",
        name = "unbolted",
        help = "unbolted",
        editor = "bool",
        default = false,
        template = false,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "is_vanilla_firearm",
        name = "Vanilla Firearm",
        help = "Vanilla Firearm",
        editor = "bool",
        default = false,
        template = true,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "is_tog_patched",
        name = "Ratmod: TOG patched Firearm",
        help = "Ratmod: TOG patched Firearm",
        editor = "bool",
        default = false,
        template = true,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "rat_updated_in",
        name = "rat_updated_in",
        help = "rat_updated_in",
        editor = "number",
        default = 0,
        min = 0,
        max = 1000,
        template = false,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        id = "Rat_cycling",
        name = "Cycling Mechanism",
        help = "Cycling Mechanism",
        editor = "dropdownlist",
        items = rat_get_cycling(), -- {"BreakAction","PumpAction","BoltAction", "SingleAction", "DoubleAction", "Semi-Auto", "LeverAction", "Auto", ""},
        default = "",
        modifiable = true,
        template = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        id = "recoil_mechanism",
        name = "Mechanism",
        help = "Mechanism",
        editor = "dropdownlist",
        items = rat_get_mechanism(), -- {"BreakAction","PumpAction","BoltAction", "SingleAction", "DoubleAction", "Semi-Auto", "LeverAction", "Auto", ""},
        default = "",
        modifiable = true,
        template = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "rat_weigth",
        name = "Weight (g)",
        help = "Weight (g)",
        editor = "number",
        default = 4000,
        min = 0,
        max = 100000,
        template = true,
        modifiable = true
    }

    FirearmProperties.properties[#FirearmProperties.properties +
        1] = {
        -- category = "Caliber",
        id = "rat_barrel_len",
        name = "Barrel Length (mm)",
        help = "Barrel Length (mm)",
        editor = "number",
        default = 380,
        min = 0,
        max = 100000,
        template = true,
        modifiable = true
    }

end
fireprop()

