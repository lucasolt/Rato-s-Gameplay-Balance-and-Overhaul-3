---------------------------------------------------------------------------------------------------
---- LIGHT SOURCES -- brighter, wider flares and glowsticks.
---------------------------------------------------------------------------------------------------

---- Stealth lighting comes from the FX light's radius/intensity, not AreaOfEffect; keep AoE in step
RAT_FLARE_AOE = 6
RAT_FLARE_LIGHT = {radius = 8000, intensity0 = 40, intensity1 = 50}
---- Glowstick is a plain PointLight: Intensity drives it (vanilla 10)
RAT_GLOWSTICK_LIGHT = {intensity = 16}

local flare_actors = {"Weapon_FlareStick", "Weapon_FlareStick_OnGround"}
local glowstick_actors = {"Weapon_GlowStick", "Weapon_GlowStick_OnGround"}

---- Edits the presets in place: FXRules holds the same objects. Lights already spawned keep old values.
function Rat_PatchLightSourceFXs()
    for _, fx in ipairs(FXLists.ActionFXLight or empty_table) do
        if table.find(flare_actors, fx.Actor) then
            -- PointLightFlicker ignores Intensity
            fx.Radius = RAT_FLARE_LIGHT.radius
            fx.Intensity0 = RAT_FLARE_LIGHT.intensity0
            fx.Intensity1 = RAT_FLARE_LIGHT.intensity1
        elseif table.find(glowstick_actors, fx.Actor) then
            fx.Intensity = RAT_GLOWSTICK_LIGHT.intensity
        end
    end
    FXCache = false
end

function OnMsg.GetCustomFXInheritActorRules()
    Rat_PatchLightSourceFXs()
end

---- ModsReloaded runs after every mod's ClassesGenerate, so an Explosive Overhaul preset can't undo it
function OnMsg.ModsReloaded()
    g_Classes.FlareStick.AreaOfEffect = RAT_FLARE_AOE
end
