const.Combat.SnapshotHipfire = {}
const.Combat.Hipfire = {}
const.Combat.Snapshot = {}

---------------
--- Hipfire
const.Combat.Hipfire.BasePenalty = -10 --- - 18
const.Combat.Hipfire.MaxPenalty = -123 ---- -75
const.Combat.Hipfire.MaxDistforPenalty = 28 -- 26
-- Snapshot
const.Combat.Snapshot.BasePenalty = -6 ---- -10
const.Combat.Snapshot.MaxPenalty = -61
const.Combat.Snapshot.MaxDistforPenalty = 40 --- tiles
const.Combat.Snapshot.MGSetupInterruptMul = 80 -- MulDivRound
---- MachineGun em ataque de oportunidade: usa estes dois no lugar dos valores normais,
---- para que a distancia pese menos sem baratear o tiro. No turno normal a MG segue com
---- MaxDistforPenalty 40 e BasePenalty -6, como todas as outras classes.
const.Combat.Snapshot.MGInterruptBasePenalty = -16
const.Combat.Snapshot.MGInterruptMaxDist = 90 --- tiles
const.Combat.Snapshot.InterruptMul = 140 --- MulDivRound
---------------

const.Combat.SnapshotHipfire.Components = {
    LaserMul = 0.90, -- 0.88,
    VerticalGripMul = 0.97, -- 0.95,
    TacticalGripMul = 0.92, -- 0.90,
    LightStockMul = 0.94 -- 0.92
}

const.Combat.SnapshotHipfire.RunAndGunMul = 1.20
const.Combat.SnapshotHipfire.MobileShotMul = 1.20
const.Combat.SnapshotHipfire.MeleeWeaponMul = 0.85

const.Combat.Hipfire.Components = {
    BullpupMul = 1.08,
    LongBarrelMul = {Pistol = 0.96, Revolver = 0.94, Other = 0.91},
    ShortBarrelMul = {Pistol = 1.04, Revolver = 1.06, Other = 1.09}
}

const.Combat.Hipfire.Other = {Prone = 1.06, Crouch = 1.02}

const.Combat.Snapshot.Components = {
    DrumMagMul = 1.08,
    NoStockMul = 0.94,
    BullpupMul = 0.98,
    LongBarrelMul = {Pistol = 1.04, Revolver = 1.05, Other = 1.08},
    ShortBarrelMul = {Pistol = 0.96, Revolver = 0.95, Other = 0.92},
    LightBarrelMul = 0.93, -- {Pistol = 1.02, Revolver = 1.03, Other = 0.92},
    HeavyBarrelMul = 1.07 -- {Pistol = 0.98, Revolver = 0.97, Other = 0.94},
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
    MachineGun.class_base_snapshot_mul = 135
end
