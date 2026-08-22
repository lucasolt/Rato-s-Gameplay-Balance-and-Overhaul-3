const.Combat.Recoil = {Components = {}, Perks = {}, Other = {}}

const.Combat.Recoil.MarksmanshipMaxReduction = 0.85 -- 0.77
const.Combat.Recoil.MarksmanshipMinStat = 50

const.Combat.Recoil.BasePenalty = -5 ----- -5
const.Combat.Recoil.MaxPenalty = -90 --- -50
const.Combat.Recoil.MaxDistforPenalty = 36 -- 26 ----- -18
const.Combat.Recoil.StacksMultiplier = 0.35 ---- * -- for Persistant Recoil
const.Combat.Recoil.MGSetupMul = 0.60 ---- * -- MG Setup recoil reduction
const.Combat.Recoil.RunAndGunExtraPenalty = -5

const.Combat.Recoil.Components = {
    VerticalGripMul = 0.95, ---0.92, 
    FoldableGripMul = 0.97, ---0.97,
    NoStockMul = {SubmachineGun = 1.40, Other = 1.70},
    CompensatorMul = 0.90, -- 0.90,
    RecoilBoosterMul = 0.97, -- 0.96,
    IntegratedMuzzleBrakeMul = 0.91, -- 0.91,
    SuppressorMul = 0.93,
    ImprovisedSuppressorMul = 0.97,
    LongBarrelMul = {Pistol = 0.96, Revolver = 0.95, SubmachineGun = 0.93, Other = 0.90},
    ShortBarrelMul = {Pistol = 1.04, Revolver = 1.05, SubmachineGun = 1.07, Other = 1.10},
    LightBarrelMul = {Pistol = 1.02, Revolver = 1.03, SubmachineGun = 1.04, Other = 1.05},
    HeavyBarrelMul = {Pistol = 0.98, Revolver = 0.97, SubmachineGun = 0.96, Other = 0.95},
    HeavyStockMul = 0.88,
    LightStockMul = 1.05,
    RecoilBumpMul = 1.06,
    BipodMul = 0.80,
    FullChokeRecoilMul = 1.09
}
----- Perks
const.Combat.Recoil.Perks.TakeAimMul = 0.85
const.Combat.Recoil.Perks.AutoWeaponsMul = 0.85
----
const.Combat.Recoil.Other = {Prone = 0.88, Crouch = 0.93, Tracer = 0.89, AP = 1.04}

function OnMsg.ClassesGenerate()
    AppendClass.FirearmProperties = {
        properties = {{id = "class_base_recoil", editor = "number", default = 100, no_edit = true}}
    }

    Pistol.class_base_recoil = 195
    Revolver.class_base_recoil = 188
    SubmachineGun.class_base_recoil = 138
    MachineGun.class_base_recoil = 90
    Shotgun.class_base_recoil = 90
end
