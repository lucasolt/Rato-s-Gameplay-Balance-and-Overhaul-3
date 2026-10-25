---------------------------------------------------------------------------------------------------
---- LIGHT SOURCES -- brighter, wider flares and glowsticks.
---------------------------------------------------------------------------------------------------

---- Stealth lighting comes from the FX light's radius/intensity, not AreaOfEffect; keep AoE in step
RAT_FLARE_AOE = 6
RAT_FLARE_LIGHT = {radius = 8000, intensity0 = 32, intensity1 = 40}
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

local function FlareLight(flare)
    for _, obj in ipairs(flare.visual_obj:GetAttaches("Weapon_FlareStick_OnGround") or empty_table) do
        if obj:GetAttach("Light") then
            return obj
        end
    end
end

---- A burnt-out stick (Despawn false) keeps remaining_time -1; rebuilding its visual on load spawned the light again
local Rat_FlareSetDynamicData = FlareOnGround.SetDynamicData
function FlareOnGround:SetDynamicData(data)
    Rat_FlareSetDynamicData(self, data)
    local class = g_Classes[self.item_class]
    if self.remaining_time >= 0 or not (class and class.Expires) then
        return
    end
    ---- the light comes from deferred Spawn FX a few frames after the visual
    CreateMapRealTimeThread(function(flare)
        for _ = 1, 50 do
            Sleep(100)
            if not IsValid(flare) or not IsValid(flare.visual_obj) then
                return
            end
            local obj = FlareLight(flare)
            if obj then
                PlayFX("Flare", "end", flare.visual_obj)
                PlayFX("Flare", "end", obj)
                ResetVoxelStealthParamsCache()
                return
            end
        end
    end, self)
end
