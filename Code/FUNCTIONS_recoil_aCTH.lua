---------------------------------------------------------------------------------------------------
---- RECOIL, SECOND ORDER -- the muzzle has a POSITION and a VELOCITY, and the shooter's
---- counter-force acts on the VELOCITY. Modelled on JA2 1.13 NCTH (CalcCounterForceChange).
----
---- Why velocity: with position alone, control can only be a coin -- there is nothing continuous
---- to modulate -- and overshoot is impossible, because subtracting from a position never sweeps
---- past the target and out the other side. Here the shooter runs a PD controller trying to put
---- (p, v) back at (0, 0) and misses it by a mandatory error. Undershoot the correction and the
---- muzzle stays on the kick side; overshoot it and the muzzle crosses the target and keeps going.
---- Same mechanism, two signs.
----
---- UNITS: everything is angular, in MINUTES of arc and minutes per shot -- the same unit as theta
---- (167' for a standing torso at 10 tiles). "The second shot must still threaten" is then a
---- direct comparison and not a guess. INTERNALLY the state is in centiminutes: the gains are 1/T
---- and 1/T^2 and would round to zero in whole minutes. The conversion lives in Rat_RecoilProfile
---- and in the two readouts, nowhere else.
----
---- THE CALIBER GATE: at steady state the shooter needs |cf| = |kick|, but |cf| is capped at
---- CFMax. So if CFMax < KickMag the muzzle can NEVER be stabilised -- v grows every shot and the
---- burst runs off the target however well the correction is aimed. That is "not strong enough for
---- this caliber", stated as two numbers in the same unit instead of as a stat breakpoint.
----
---- The dispersion cone is untouched and still applies around p on every shot: recoil moves where
---- the gun points, it does not widen the cone.
---------------------------------------------------------------------------------------------------

local function P()
    return const.Combat.Aperture
end

---------------------------------------------------------------------------------------------------
---- Integer vector helpers. Centiminutes throughout.
---------------------------------------------------------------------------------------------------

local function vlen(x, y)
    return Rat_ISqrt(x * x + y * y)
end

---- Pythagorean, never per-axis: these are forces, and a per-axis cap would make the diagonal
---- stronger than the vertical. Compares SQUARES first -- Rat_ISqrt is the hot spot of the whole
---- model and the vector is under the cap on most shots.
local function vclamp(x, y, maxlen)
    if maxlen <= 0 then
        return 0, 0
    end
    local d2 = x * x + y * y
    if d2 <= maxlen * maxlen then
        return x, y
    end
    local len = Rat_ISqrt(d2)
    return MulDivRound(x, maxlen, len), MulDivRound(y, maxlen, len)
end

---- One axis of the mandatory error, 1.13's shape verbatim: always at least `floor_err`, sign free.
local function err_term(rnd, floor_err, mag)
    local e = floor_err + ((mag > 0) and rnd(mag + 1) or 0)
    return (rnd(2) == 0) and e or -e
end

---------------------------------------------------------------------------------------------------
---- PROFILE: the constants of one attack, resolved once. Everything the shooter and the weapon
---- contribute enters here and nowhere else.
----
---- The tuned chain in FUNCTIONS_recoil.lua survives whole; only its two outputs get pointed at
---- different things:
----   gun = mod / control  -- the weapon alone (stance-invariant, measured) -> KickMag
----   control              -- everything the shooter brings, base 100      -> CFMax, inverted
---------------------------------------------------------------------------------------------------
function Rat_RecoilProfile(attacker, action, weapon, num_shots, test)
    local a = P()
    if not attacker or not IsKindOf(weapon, "Firearm") then
        return nil
    end

    local _, _, control, gun = Rat_GetRecoilBaseMod(attacker, action, weapon, num_shots)
    control = cRound(control)

    local kick = MulDivRound(a.RecoilKickBase or 0, cRound(gun), 100)
    kick = Max(0, MulDivRound(kick, const.Combat.R_Recoil or 100, 100))

    ---- a mounted MG holds itself: the mount is force the shooter did not have to bring
    local aid = action and action.id
    if aid == "GrizzlyPerk" or
        (aid == "MGBurstFire" and
            (test or (g_Overwatch[attacker] and g_Overwatch[attacker].permanent))) then
        control = cRound(control * const.Combat.Recoil.MGSetupMul)
    end

    ---- control only spans ~85..117 in practice; the gain stretches that band around 100 before it
    ---- inverts into force, so skill can decide the marginal calibers instead of nothing.
    ---- The floor caps CFMax at 100/30 of the base: a mounted MG sends control near 50, which the
    ---- gain drives negative, and without it one point of control would swing the force wildly.
    local ctl = Max(30, 100 + MulDivRound(control - 100, a.RecoilControlGain or 100, 100))
    local cf_max = MulDivRound(a.RecoilCFMaxBase or 0, 100, ctl)
    local max_inc = Max(1, a.RecoilMaxIncrement or 1)

    ---- rate of fire shortens the time between shots, so it shrinks the SHOOTER's side. The
    ---- cartridge's kick does not change with how fast the trigger is pulled.
    if not IsKindOf(weapon, "Shotgun") then
        local ROF = Rat_GetROF(weapon, (aid == "GrizzlyPerk") and "MGBurstFire" or (aid or ""))
        local rof100 = ROF and cRound(ROF * 100) or 100
        if rof100 > 100 then
            cf_max = MulDivRound(cf_max, 100, rof100)
            max_inc = Max(1, MulDivRound(max_inc, 100, rof100))
        end
    end

    local T = Max(1, a.RecoilSettleShots or 3)
    local ang = Clamp(a.RecoilKickAngle or 0, -90, 90) * 60

    return {
        ---- centiminutes per shot, which is what the step runs in
        kick_x = MulDivRound(kick * 100, sin(ang), 4096),
        kick_y = MulDivRound(kick * 100, cos(ang), 4096),
        cf_max = cf_max * 100,
        max_inc = max_inc * 100,
        min_err = MulDivRound(max_inc * 100, a.RecoilMinErrorPct or 0, 100),
        ---- gains by 1000. Double root at 1 - 1/T gives Kd = 2/T and Kp = 1/T^2.
        kp = MulDivRound(1000, 1, T * T),
        kd = MulDivRound(2000, a.RecoilDamping or 100, 100 * T),
        err_ratio = a.RecoilErrorRatio or 0,
        ---- Dexterity raw: the one stat the tuned chain does not already spend, so nothing is
        ---- counted twice. It never removes the floor, only the error above it.
        accuracy = Clamp(attacker.Dexterity or 0, 0, 100),
        ---- minutes, for reading and for the gate: kick_min > cf_min means unstabilisable
        kick_min = kick,
        cf_min = cf_max,
        control = control
    }
end

---------------------------------------------------------------------------------------------------
---- STATE AND STEP
---------------------------------------------------------------------------------------------------

function Rat_RecoilState()
    return {px = 0, py = 0, vx = 0, vy = 0, cx = 0, cy = 0}
end

---- One shot of dynamics; `st` advances in place. The bullet leaves from `st` BEFORE this runs.
---- `rnd(n)` returns 0..n-1 -- the real shot passes the synced rng and the estimator a seeded one,
---- so there is exactly one implementation of the recoil and prediction cannot drift from it.
function Rat_RecoilStep(prof, st, rnd)
    ---- where the shooter wants the velocity to go: PD aiming (p, v) at (0, 0)
    local ax = -(MulDivRound(st.px, prof.kp, 1000) + MulDivRound(st.vx, prof.kd, 1000))
    local ay = -(MulDivRound(st.py, prof.kp, 1000) + MulDivRound(st.vy, prof.kd, 1000))

    ---- the counter-force also has to cancel the incoming kick, and the grip cannot change
    ---- instantly, so only max_inc of the shortfall is attempted this shot
    local dx, dy = vclamp(ax - prof.kick_x - st.cx, ay - prof.kick_y - st.cy, prof.max_inc)

    ---- error on the CHANGE, proportional to the size of the correction attempted: hauling a big
    ---- caliber back generates more of it than nudging a small one, so caliber difficulty falls
    ---- out of the mechanism instead of being tuned in per weapon
    local mag = Max(prof.min_err, MulDivRound(MulDivRound(vlen(dx, dy), prof.err_ratio, 100),
                                              100 - prof.accuracy, 100))
    dx = dx + err_term(rnd, prof.min_err, mag)
    dy = dy + err_term(rnd, prof.min_err, mag)

    st.cx, st.cy = vclamp(st.cx + dx, st.cy + dy, prof.cf_max)

    st.vx, st.vy = st.vx + prof.kick_x + st.cx, st.vy + prof.kick_y + st.cy
    st.px, st.py = st.px + st.vx, st.py + st.vy
end

---- Muzzle offset in MINUTES: lateral, vertical, radial. The only part of the state the bullet reads.
function Rat_RecoilPoint(st)
    local x, y = MulDivRound(st.px, 1, 100), MulDivRound(st.py, 1, 100)
    return x, y, Rat_ISqrt(x * x + y * y)
end

---- Muzzle angular speed in minutes/shot. The hit percentage says a burst went wrong; this says why.
function Rat_RecoilSpeed(st)
    return MulDivRound(vlen(st.vx, st.vy), 1, 100)
end

---------------------------------------------------------------------------------------------------
---- ESTIMATOR: runs the same step and measures. A second-order stochastic system has no closed
---- form per-shot hit probability and needs none -- nobody displays this number, it exists to
---- balance against. Seeded, so the same profile always gives the same ladder: it does not flicker
---- between calls, it cannot desync co-op, and a specific bad volley can be replayed exactly.
---------------------------------------------------------------------------------------------------
function Rat_EstimateBurst(prof, theta, sigma, num_shots, samples, seed)
    local a = P()
    num_shots = Max(1, num_shots or 1)
    samples = Max(1, samples or a.RecoilEstimateSamples or 128)
    local rnd = BraidRandomCreate(seed or a.RecoilEstimateSeed or 1)

    local cth, sx, sy, s2, off, spd = {}, {}, {}, {}, {}, {}
    for i = 1, num_shots do
        cth[i], sx[i], sy[i], s2[i], off[i], spd[i] = 0, 0, 0, 0, 0, 0
    end

    ---- the cone is drawn analytically instead of sampled: it is the same Rayleigh LUT the bullet
    ---- inverts, so this costs no fidelity and removes the noise the samples would have to beat
    local measure = theta and theta >= 1 and sigma and sigma >= 1

    local st = Rat_RecoilState()
    for _ = 1, samples do
        st.px, st.py, st.vx, st.vy, st.cx, st.cy = 0, 0, 0, 0, 0, 0
        for i = 1, num_shots do
            local x, y, r = Rat_RecoilPoint(st)
            if measure then
                cth[i] = cth[i] + Rat_RiceCTH(theta, sigma, r)
            end
            sx[i], sy[i] = sx[i] + x, sy[i] + y
            s2[i] = s2[i] + x * x + y * y
            off[i] = off[i] + r
            spd[i] = spd[i] + Rat_RecoilSpeed(st)
            Rat_RecoilStep(prof, st, rnd)
        end
    end

    local out = {cth = {}, px = {}, py = {}, spread = {}, offset = {}, speed = {},
                 samples = samples}
    for i = 1, num_shots do
        out.cth[i] = measure and MulDivRound(cth[i], 1, samples) or nil
        out.px[i], out.py[i] = MulDivRound(sx[i], 1, samples), MulDivRound(sy[i], 1, samples)
        out.offset[i] = MulDivRound(off[i], 1, samples)
        out.speed[i] = MulDivRound(spd[i], 1, samples)
        ---- radial spread about the MEAN point, E[|p|^2] - |E[p]|^2: the width of the group there
        out.spread[i] = Rat_ISqrt(Max(0, MulDivRound(s2[i], 1, samples) - out.px[i] * out.px[i] -
                                          out.py[i] * out.py[i]))
    end
    return out
end
