---------------------------------------------------------------------------------------------------
---- TRACER FX -- a mag of tracer ammo is loaded with a tracer every few rounds, not all of them: each
---- bullet from a gun with tracer == 1 rolls RAT_TRACER_FX.chance to fly as a long red-orange streak
---- with a glow that lights what it passes. Visual only (AsyncRand), gameplay sees every round alike.
---------------------------------------------------------------------------------------------------

RAT_TRACER_FX = {
    chance = 25,
    ---- streak sprite, cloned from vanilla Bullet_Small (width 400, length 3000 -> 1000)
    particles = "Rat_Bullet_Tracer",
    width = 600,
    length = 9000,
    tail = 6000,
    color_min = RGB(255, 45, 10),
    color_max = RGB(255, 75, 20),
    ---- moving point light; out of the stealth voxel scan, so it lights nothing for gameplay
    light_color = RGB(255, 90, 30),
    light_intensity = 10,
    light_radius = 150 * guic,
}

local function TracerParticles()
    local t = RAT_TRACER_FX
    local preset = ParticleSystemPresets[t.particles]
    if preset then
        return t.particles
    end
    local src = ParticleSystemPresets.Bullet_Small
    preset = ParticleSystemPreset:new{id = t.particles, group = src.group}
    for i, behavior in ipairs(src) do
        local b = behavior:Clone()
        if b.class == "ParticleBehaviorResize" then
            b.start_size_min, b.start_size_max, b.mid_size, b.end_size = t.width, t.width, t.width, t.width
            b.start_size2_min, b.start_size2_max, b.mid_size2, b.end_size2 = t.length, t.length, t.tail, t.tail
        elseif b.class == "ParticleBehaviorColorize" then
            b.start_color_min, b.start_color_max = t.color_min, t.color_max
        end
        preset[i] = b
    end
    ---- code-made presets skip PostLoad: register and push to the native side by hand
    preset:Register()
    preset:BindParams()
    ParticlesReload(t.particles)
    return t.particles
end

local function AttachTracer(projectile)
    local t = RAT_TRACER_FX
    local par = PlaceParticles(TracerParticles())
    par:SetGameFlags(const.gofAlwaysRenderable)
    projectile:Attach(par)
    ---- the sprite streaks along its Z; the bullet flies along X
    par:SetAttachAxis(axis_y)
    par:SetAttachAngle(90 * 60)
    local light = PlaceObject("PointLight")
    light:ClearEnumFlags(const.efVsPointLight | const.efVsSpotLight)
    ---- the renderer skips Lua-placed lights without it
    light:SetGameFlags(const.gofPermanent)
    light:SetColor(t.light_color)
    light:SetIntensity(t.light_intensity)
    light:SetAttenuationRadius(t.light_radius)
    projectile:Attach(light)
    return {par, light}
end

---- Vanilla copy (Weapon.lua), only the tracer roll and its attaches added
function Firearm:ProjectileFly(attacker, start_pt, end_pt, dir, speed, hits, target, attack_args)
    NetUpdateHash("ProjectileFly", attacker, start_pt, end_pt, dir, speed, hits)
    dir = SetLen(dir or end_pt - start_pt, 4096)

    local fx_actor = false
    if IsKindOf(attacker, "Unit") then
        fx_actor = attacker:CallReactions_Modify("OnUnitChooseProjectileFxActor", fx_actor)
    end

    local projectile = PlaceObject("FXBullet")
    projectile.fx_actor_class = fx_actor
    projectile:SetGameFlags(const.gofAlwaysRenderable)
    projectile:SetPos(start_pt)
    local axis, angle = OrientAxisToVector(1, dir) -- 1 = +X
    projectile:SetAxis(axis)
    projectile:SetAngle(angle)
    PlayFX("Spawn", "start", projectile)
    local tracer_fx = self.tracer == 1 and AsyncRand(100) < RAT_TRACER_FX.chance and AttachTracer(projectile)
    local fly_time = MulDivRound(projectile:GetDist(end_pt), 1000, speed)
    local end_time = GameTime() + fly_time
    projectile:SetPos(end_pt, fly_time)
    Sleep(const.Combat.BulletDelay)

    local wind_last_dist
    collision.Collide(start_pt, end_pt - start_pt, BulletVegetationCollisionQueryFlags, 0, BulletVegetationCollisionMask,
        function(o, _, hitX, hitY, hitZ)
            if o:IsKindOfClasses(BulletVegetationClasses) and not table.find(hits, "obj", o) then
                local hit = {
                    obj = o,
                    pos = point(hitX, hitY, hitZ),
                    distance = start_pt:Dist(hitX, hitY, hitZ),
                    vegetation = true,
                }
                table.insert(hits, hit)
                if not wind_last_dist or hit.distance - wind_last_dist >= WindModifiersVegetationMinDistance then
                    PlaceWindModifierBullet(hit.pos)
                    wind_last_dist = hit.distance
                end
            end
        end)
    if wind_last_dist then
        table.sortby_field(hits, "distance")
    end

    local context = {
        attacker = attacker,
        target = target,
        dir = dir,
        target_hit = false,
        last_unit_hit = false,
        water_hit = false,
        fx_target = false,
    }
    local last_start_pos = start_pt
    local last_time = 0
    for i, hit in ipairs(hits) do
        local hit_time = MulDivRound(hit.pos:Dist(last_start_pos), 1000, speed)
        if hit_time > last_time then
            Sleep(hit_time - last_time)
            last_time = hit_time
        end
        self:BulletHit(projectile, hit, context)
        if hit.ricochet and i < #hits then
            last_start_pos = hit.pos
            last_time = 0
            local ricochet_dir = SetLen(hits[i+1].pos - last_start_pos, 4096)
            local axis, angle = OrientAxisToVector(1, ricochet_dir) -- 1 = +X
            projectile:SetAxis(axis)
            projectile:SetAngle(angle)
            PlayFX("Ricochet", "start", projectile, context.fx_target, last_start_pos, ricochet_dir)
            local last_pos = hits[#hits].pos
            projectile:SetPos(last_pos, MulDivRound(last_pos:Dist(last_start_pos), 1000, speed))
        end
    end
    if IsValid(target) and not context.target_hit then
        PlayFX("TargetMissed", "start", target)
    end
    -- wait the projectile in case of no hits or long flight after the last hit
    Sleep(Max(0, end_time - GameTime()))
    PlayFX("Spawn", "end", projectile, false)
    for _, obj in ipairs(tracer_fx or empty_table) do
        DoneObject(obj)
    end
    DoneObject(projectile)
end
