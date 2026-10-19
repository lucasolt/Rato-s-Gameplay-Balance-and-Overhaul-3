---------------------------------------------------------------------------------------------------
---- SHARED hipfire/snapshot multipliers (GetWeaponHipfireOrSnapshotMul): old CTH scales its points,
---- aCTH scales the A.AimStep excess. The point penalties live in __OldCTHParams.lua.
---------------------------------------------------------------------------------------------------
const.Combat.SnapshotHipfire = {}
const.Combat.Hipfire = {}
const.Combat.Snapshot = {}


-- TODO: Make a patch that set the constants as param, minding the Aperture change patch
const.Combat.SnapshotHipfire.Components = {
    LaserMul = 90,--0.90, -- 0.88,
    VerticalGripMul = 0.97, -- 0.95,
    TacticalGripMul = 0.86, -- 0.92,
    LightStockMul = 0.94 -- 0.92
}

const.Combat.SnapshotHipfire.RunAndGunMul = 1.20
const.Combat.SnapshotHipfire.MobileShotMul = 1.20
const.Combat.SnapshotHipfire.MeleeWeaponMul = 0.85

const.Combat.Hipfire.Components = {
    BullpupMul = 1.08,
    LongBarrelMul = {Pistol = 0.96, Revolver = 0.94, Other = 0.90},
    ShortBarrelMul = {Pistol = 1.04, Revolver = 1.06, Other = 1.10}
}

const.Combat.Hipfire.Other = {Prone = 1.10, Crouch = 1.05}

const.Combat.Snapshot.Components = {
    DrumMagMul = 1.05,
    NoStockMul = 0.90,
    BullpupMul = 0.95,
    LongBarrelMul = {Pistol = 1.04, Revolver = 1.05, Other = 1.10},
    ShortBarrelMul = {Pistol = 0.92, Revolver = 0.93, Other = 0.90},
    LightBarrelMul = 0.90, -- {Pistol = 1.02, Revolver = 1.03, Other = 0.92},
    HeavyBarrelMul = 1.10, -- {Pistol = 0.98, Revolver = 0.97, Other = 0.94},
    HeavyStockMul = 1.10,
    BipodUnbracedMul = 1.10 -- bipod off the ground: a heavier front end swings slower
}

function OnMsg.ClassesGenerate()
    AppendClass.Firearm = {
        properties = {
            {id = "class_base_hipfire_mul", editor = "number", default = 100, no_edit = true},
            {id = "class_base_snapshot_mul", editor = "number", default = 100, no_edit = true}
        }
    }

    Pistol.class_base_hipfire_mul = 145
    Revolver.class_base_hipfire_mul = 138
    SubmachineGun.class_base_hipfire_mul = 120
    Shotgun.class_base_hipfire_mul = 105
    ---
    Pistol.class_base_snapshot_mul = 60
    Revolver.class_base_snapshot_mul = 60
    SubmachineGun.class_base_snapshot_mul = 85
    Shotgun.class_base_snapshot_mul = 115
    SniperRifle.class_base_snapshot_mul = 135
    AssaultRifle.class_base_snapshot_mul = 125
    MachineGun.class_base_snapshot_mul = 165 -- long and heavy: slow off-target; set-up OW compensated by MGSetupInterruptStepMul
end
