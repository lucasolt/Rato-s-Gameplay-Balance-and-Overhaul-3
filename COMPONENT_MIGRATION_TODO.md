# Components still outside the compositor

Generated from the live process on 2026-09-11, after the two migration commits.
Nothing here is broken -- these components work, they are just still hand-authored
presets instead of trait compositions.

| Bucket | Components |
| --- | ---: |
| Composed from traits | 99 |
| Inherited via `GBO_ComponentAncestor` | ~310 |
| No effects and no params (cosmetic) | 258 |
| **Left to decide** | **251** |
| Total `WeaponComponents` | 933 |

`signature` below is `effects | params`, read straight off the preset.
`%` marks a `PresetParamPercent`. Groups are sorted by size: the top ones are
whole weapon families that share one authored block and would collapse into a
single trait.

## Blocked, not merely pending

`_Master_Handguard_ext_TOG` and `_Master_Handguard_short_TOG` cannot be written as
recipes as the compositor stands. The `handguard_ext` / `handguard_short` effects own
a parameter literally named `snapshot_mul`, and `snapshot_mul` is also one of the
compositor's canonical signed stats (`GBO_STAT_EMIT`). A recipe declaring it would
have the value consumed and re-emitted as `snap_mul_inc` on a `DecreaseSnapshotMul`
effect the component never had. Fixing this means renaming one side or teaching
`GBO_STAT_EMIT` to skip names an effect in the list already claims.

## The 157 groups

### x12 &nbsp; `IncreaseRange,IncreaseAimAccuracy`

- params: `AimAccuracyIncrease=2,RangeIncrease=6`
- ids: BM59_barrel_ext, C96R_barrel_ext_1, EM2_barrel_ext_1, FAMAE_barrel_ext_1, FN2000_barrel_ext_1, FNMD_barrel_ext_1, L85A1_barrel_ext_1, M48_barrel_ext_1, M82_barrel_ext_1, MAC2429_barrel_ext_1, U100_Barrel_ext_1, mk23_barrel_ext_1

### x11 &nbsp; `ReduceReliability,ReduceRange,ReduceShootAP`

- params: `RangeDecrease=4,ReliabilityDecrease=10,ShootAPDecrease=1`
- ids: BM59_barrel_shrt, C96R_barrel_shrt_1, EM2_barrel_shrt_1, FAMAE_barrel_shrt_1, FNMD_barrel_shrt_1, L85A1_barrel_shrt_1, M48_barrel_shrt_1, M82_barrel_shrt_1, MAC2429_barrel_shrt_1, U100_Barrel_shrt_1, mk23_barrel_shrt_1

### x9 &nbsp; `ReduceAimAccuracy,ExtraOverwatchShots`

- params: `accuracy_penalty=-50%,crit_display=15%,extra_attacks=1`
- ids: BM59MK3_stock, EM2_stock_erg_1, FNMD_stock_erg_1, MAC2429_Stock_erg_1, Type56A_stock_erg_c, Type56B_stock_erg_c, Type56C_stock_erg_c, Type56D_stock_erg_c, U100_Stock_erg_1

### x8 &nbsp; `BonusAccuracyWhenFullyAimed`

- params: `bonus_cth=10%,range=10`
- ids: BM59MK2_stock, EM2_stock_hvy_1, MAC2429_Stock_hvy_1, Type56A_stock_hvy_c, Type56B_stock_hvy_c, Type56C_stock_hvy_c, Type56D_stock_hvy_c, U100_Stock_hvy_1

### x5 &nbsp; `ReduceAimAccuracy,ReduceRange,zzBipodEquipped`

- params: `RangeDecrease=5%`
- ids: AR10_bipod_fld, BM59_bipod_fld, FNMD_bipod_fld_1, MAC2429_Bipod_fld_1, NTW20_bipod_fld_1

### x5 &nbsp; `AccuracyBonusProne,IncreaseRange,IncreaseOverwatchAngle,zzBipodEquipped`

- params: `OverwatchAngleIncrease=90%,RangeIncrease=5%`
- ids: AR10_bipod_unfld, BM59_bipod_unfld, FNMD_bipod_unfld_1, MAC2429_Bipod_unfld_1, NTW20_bipod_unfld_1

### x4 &nbsp; `OpportunityAttackBonusCth,IncreaseOverwatchAngle`

- params: `OverwatchAngleIncrease=140,bonus_cth=10%`
- ids: G11_Rail_8, Leovision_Falcon, MP7_Scope_1, Sovitron_Kentaur

### x4 &nbsp; `FirstAimBonusModifier`

- params: _none_
- ids: FNMD_Handle_1, M1918A2_handle_def_1, U100_handle_1, VerticalGrip_AUG

### x4 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=10%`
- ids: AWP_Muzzle_1, FN2000_Muzzle_1, L85A1_muzzle_def_1, ThunderTech_Tornado_1

### x3 &nbsp; `IncreaseAimAccuracy,zzStockEquipped`

- params: `AimAccuracyIncrease=3`
- ids: BM59MK3_unfld, FAMAE_stock_unfld_1, Spas12_Stock_unfold_1

### x3 &nbsp; `IgnoreInTheDark,StealthKillBonusPerAim`

- params: `stealth_kill_bonus=2%`
- ids: FlashlightDot_Anaconda, FlashlightDot_PSG_M1, G11_Rail_11

### x3 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=25%`
- ids: NoiseX_Muffler, Silentium_Whisper, Suppressor_Anaconda

### x3 &nbsp; `HalfRangeDmgIncrease,IncreaseRange`

- params: `RangeIncrease=4`
- ids: CondorN_Barrel_ext_1, Condor_Barrel_ext_1, M1897_barrel_ext

### x3 &nbsp; `FirstShotIncreasedAim`

- params: _none_
- ids: G11_Rail_6, L85A1_scope_1, Leovision_Eagle

### x3 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=200,ReloadAPIncrease=1`
- ids: A91_762_mag_ext_1, M1918A2_mag_ext_1, NTW20_Magazine_ext_1

### x3 &nbsp; `MarkWhenFullyAimed`

- params: _none_
- ids: G11_Rail_13, MK23_laser_1, ToG_Red_Dot_1

### x3 &nbsp; `GrenadeLauncher`

- params: _none_
- ids: A91_GrenadeLauncher, FN2000_grndl_1, GrenadeLauncher_Galil

### x3 &nbsp; `IncreaseAimAccuracy,IncreaseMaxAimActions`

- params: `AimAccuracyIncrease=3,MaxAimActionsIncrease=1`
- ids: AWP_Scope_1, G11_Rail_9, NTW_20_Scope_1

### x3 &nbsp; `IncreaseMaxAimActions`

- params: `MaxAimActionsIncrease=1`
- ids: AN94_Scope_1, FN2000_Scope_1, G11_Rail_7

### x2 &nbsp; `MinAim`

- params: _none_
- ids: G11_Rail_14, ToG_UV_Dot_1

### x2 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=20%`
- ids: Silentium_Ninja, Silentium_Phantom

### x2 &nbsp; `MinorAccuracyBonus`

- params: _none_
- ids: FN2000_ironsight_1, FP6_Ironsight_1

### x2 &nbsp; `AccuracyBonusProne`

- params: _none_
- ids: AK47_Bipod, Bipod_Galil

### x2 &nbsp; `bolt_action_ap`

- params: `ap_manual=3`
- ids: single_action, single_action_tex

### x2 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=7,crit=26%`
- ids: NoiseX_MufflerPro, Silentium_Whisper_1

### x2 &nbsp; `MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=200,OverwatchAngleDecrease=84`
- ids: MagLargeFine_11, MagLargeFine_5

### x2 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=150,ReloadAPIncrease=1`
- ids: M82_mag_ext_1, mk23_mag_ext_1

### x2 &nbsp; `IgnoreInTheDarkWhenFullyAimed,IgnoreCoverCtHWhenFullyAimed,IgnoreLightOfSightWhenFullyAimed,IgnoreInTheDarkWhenFullyAimed,IgnoreGrazingHitsWhenFullyAimed,IncreaseRange,ScopePenalty2,DecreaseOverwatchAngle`

- params: `APincrease=1,OverwatchAngleDecrease=55,RangeIncrease=10`
- ids: ThermalScope_1, ThermalScope_2

### x2 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=4,cth=6%`
- ids: Sovitron_Kmrad, ThunderTech_Cyclone

### x2 &nbsp; `FreeWeaponSwap`

- params: `accuracy=5%`
- ids: MP7_Grip_fld_1, ToG_Revolver_freeswap

### x2 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=6%`
- ids: Sovitron_Kmrad_1, ThunderTech_Cyclone_1

### x2 &nbsp; `ReduceShootAP,ReduceRange,IncreaseBuckshotAngle,ReduceReliability`

- params: `BuckshotAngleIncrease=115,RangeDecrease=2,ReliabilityDecrease=10,ShootAPDecrease=1`
- ids: CondorN_Barrel_shrt_1, Condor_Barrel_shrt_1

### x2 &nbsp; `CritBonusSameTarget,SilentShots`

- params: `crit=25%`
- ids: FN2000_silencer_1, ToG_Shotgun_Silencer

### x2 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=26%`
- ids: NoiseX_SoundGuard, Silentium_Shadow

### x2 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=8,crit=27%`
- ids: NoiseX_SoundGuardPro, Silentium_Shadow_1

### x2 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=400,ReloadAPIncrease=1`
- ids: Papovka2_Mag_ext_c_1, Papovka_Mag_ext_c_1

### x2 &nbsp; `FreeWeaponSwap`

- params: _none_
- ids: MicroUZI_freeswap, handgun_freeswap

### x2 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=28%`
- ids: NoiseX_Sonic, Silentium_Nighthawk

### x2 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=10,crit=29%`
- ids: NoiseX_SonicPro, Silentium_Nighthawk_1

### x2 &nbsp; `ReduceAimAccuracy,ExtraOverwatchShots,zzStockEquipped`

- params: `accuracy_penalty=-50%,crit_display=15%,extra_attacks=1`
- ids: BM59MK3_fld, FAMAE_stock_fld_1

### x1 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=6,crit=24%`
- ids: Silentium_Ninja_1

### x1 &nbsp; `SilentShots,ReduceRange`

- params: `RangeDecrease=2,crit=10%`
- ids: Silentium_Basic

### x1 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=30%`
- ids: NoiseX_Symphony

### x1 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=5,crit=23%`
- ids: Silentium_Phantom_1

### x1 &nbsp; `ReduceAimAccuracy,ExtraOverwatchShots,ReduceShootAP,zzStockEquipped`

- params: `ShootAPDecrease=1,accuracy_penalty=-50%,crit_display=15%,extra_attacks=1`
- ids: Spas12_Stock_fold_1

### x1 &nbsp; `SilentShots,ReduceRange,IncreaseReliability,CritBonusSameTarget`

- params: `RangeDecrease=1,ReliabilityIncrease=2,crit=17%`
- ids: Silentium_Assasin_1

### x1 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=11,crit=31%`
- ids: NoiseX_SymphonyPro

### x1 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=9,crit=28%`
- ids: Silentium_Mute_1

### x1 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=19%`
- ids: Silentium_Ghost

### x1 &nbsp; `DASA_action_ap`

- params: `ap_double_action=1,ap_manual=3`
- ids: SADA_action

### x1 &nbsp; `SilentShots,ReduceRange,IncreaseReliability,CritBonusSameTarget`

- params: `RangeDecrease=1,ReliabilityIncrease=2,crit=15%`
- ids: Silentium_Basic_1

### x1 &nbsp; `SilentShots,ReduceRange`

- params: `RangeDecrease=1,crit=15%`
- ids: Silentium_Assasin

### x1 &nbsp; `ChangeCaliberTo556,ReduceDamage,IncreaseOverwatchAngle`

- params: `DamageReduced=6,OverwatchAngleIncrease=110`
- ids: RAT_TOG_SteyrS_Barrel_def_555

### x1 &nbsp; `EnableFullAuto,Enable_BurstFire,recoil_bump`

- params: _none_
- ids: StockBump

### x1 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=4,crit=21%`
- ids: Silentium_Ghost_1

### x1 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=27%`
- ids: Silentium_Mute

### x1 &nbsp; `IncreaseRange,IncreaseAimAccuracy,longbarrel,ReduceDamage,ChangeCaliberTo556,StanceAPincrease,DecreaseOverwatchAngle`

- params: `APincrease=1,AimAccuracyIncrease=2,DamageReduced=5,OverwatchAngleDecrease=90,RangeIncrease=4`
- ids: RAT_TOG_SteyrS_Barrel_ext_556

### x1 &nbsp; `SilentShots,ReduceRange,IncreaseReliability,CritBonusSameTarget`

- params: `RangeDecrease=1,ReliabilityIncrease=3,crit=19%`
- ids: Silentium_Hush_1

### x1 &nbsp; `SilentShots,ReduceRange`

- params: `RangeDecrease=1,crit=17%`
- ids: Silentium_Hush

### x1 &nbsp; `BonusAccuracyWhenFullyAimed,NoFullAuto,stockheavy_effect_recoil,stance_ap_inc_STR`

- params: `APincrease=1,STR_threshold=85,StanceIncreaseSTR=1,bonus_cth=10%,range=10`
- ids: StockHeavy_AR_BurstOnly

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=4%`
- ids: ThunderTech_Bolt_1

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=1,cth=2%`
- ids: ThunderTech_Basic

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=334,ReloadAPIncrease=1`
- ids: U100_magazine_ext_1

### x1 &nbsp; `ReduceAimAccuracy,ReduceRange,zzBipodEquipped`

- params: `RangeDecrease=10%`
- ids: WA2000_Bipod_Fold_1

### x1 &nbsp; `AccuracyBonusProne,IncreaseRange,zzBipodEquipped`

- params: `RangeIncrease=10%`
- ids: WA2000_Bipod_Unfold_1

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=7%`
- ids: ThunderTech_Whirlwind_1

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=5,cth=7%`
- ids: ThunderTech_Whirlwind

### x1 &nbsp; `bolt_action_ap`

- params: `ShootAPIncrease=1,ap_manual=2`
- ids: lever_action

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=8%`
- ids: ThunderTech_Typhoon_1

### x1 &nbsp; `ReduceAimAccuracy`

- params: _none_
- ids: WA2000_NoScope_1

### x1 &nbsp; `DecreaseOverwatchAngle,handguard_ext,IncreaseAimAccuracy`

- params: `AimAccuracyIncrease=1,OverwatchAngleDecrease=97,hipfire_mul=95,pb_bonus_hg=-3,recoil_mul=95,snapshot_mul=105`
- ids: _Master_Handguard_ext_TOG

### x1 &nbsp; `MinorAccuracyBonus`

- params: `bonus_cth=7%`
- ids: browning_bipod

### x1 &nbsp; `shortbarrel,StanceAPdecrease`

- params: `APdecrease=1`
- ids: barrel_confidante

### x1 &nbsp; `IncreaseAimAccuracy,IncreaseMaxAimActions,CritBonusWhenFullyAimed`

- params: `AimAccuracyIncrease=5,MaxAimActionsIncrease=1,crit=5%`
- ids: WA2000_Scope_1

### x1 &nbsp; `bullpup,IncreaseOverwatchAngle`

- params: `OverwatchAngleIncrease=115`
- ids: bullup

### x1 &nbsp; `IncreaseOverwatchAngle,handguard_short`

- params: `OverwatchAngleIncrease=103,hipfire_mul=105,pb_bonus_hg=2,recoil_mul=105,snapshot_mul=95`
- ids: _Master_Handguard_short_TOG

### x1 &nbsp; `IncreaseShootAP`

- params: `ShootAPIncrease=1`
- ids: double_action

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=6,cth=8%`
- ids: ThunderTech_Typhoon

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=11%`
- ids: ThunderTech_Titan_1

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=5%`
- ids: ThunderTech_Hurricane_1

### x1 &nbsp; `AccuracyBonusSameTarget,IncreasedSingleShotAccuracy,IncreaseReliability`

- params: `ReliabilityIncrease=10,cth=11%`
- ids: ThunderTech_Hyperion

### x1 &nbsp; `AccuracyBonusSameTarget,IncreasedSingleShotAccuracy`

- params: `cth=11%`
- ids: ThunderTech_Hyperion_1

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=3,cth=5%`
- ids: ThunderTech_Hurricane

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=2%`
- ids: ThunderTech_Basic_1

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=2,cth=4%`
- ids: ThunderTech_Bolt

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=8,cth=10%`
- ids: ThunderTech_Tornado

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=7,cth=9%`
- ids: ThunderTech_Monsoon

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=10,cth=12%`
- ids: ThunderTech_Storm

### x1 &nbsp; `m14_recoil`

- params: _none_
- ids: m14_component_recoil

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=9%`
- ids: ThunderTech_Monsoon_1

### x1 &nbsp; `AccuracyBonusSameTarget,IncreaseReliability`

- params: `ReliabilityIncrease=9,cth=11%`
- ids: ThunderTech_Titan

### x1 &nbsp; `AccuracyBonusSameTarget`

- params: `cth=12%`
- ids: ThunderTech_Storm_1

### x1 &nbsp; `IncreaseDamage,ChangeCaliberTo762wp,ReduceReliability`

- params: `DamageIncrease=4,ReliabilityDecrease=15`
- ids: rpk_to762wp

### x1 &nbsp; `ReduceAimAccuracy,no_stock,StanceAPdecrease,IncreaseOverwatchAngle,hipfire_no_stock,Enable_RunAndGun,zzStockEquipped,ReduceRange`

- params: `APdecrease=1,AimAccuracyDecrease=2,OverwatchAngleIncrease=110,RangeDecrease=6`
- ids: _Master_StockNormalFolded_TOG

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=200,OverwatchAngleDecrease=77,ReloadAPIncrease=2`
- ids: MagLarge_12

### x1 &nbsp; `SilentShots,CritBonusSameTarget`

- params: `crit=32%`
- ids: NoiseX_Mirage

### x1 &nbsp; `IncreaseBuckshotAngle,IncreasePointBlankAccuracyBonus,ReduceVerticalPelletSpread`

- params: `BuckshotAngleIncrease=230,PointBlankBonus=4,VerticalSpreadReduction=50`
- ids: DuckbillChoke

### x1 &nbsp; `ReduceReloadAP`

- params: `ReloadAPDecrease=2`
- ids: FAMAE_mag3_1

### x1 &nbsp; `IgnoreInTheDark,StealthKillBonusPerAim`

- params: `aim_bonus=1%,maxaims=1,stealth_kill_bonus=2%`
- ids: FlashlightDot_aa12

### x1 &nbsp; `IncreaseDamage`

- params: `DamageIncrease=4`
- ids: Condor_Mag_magn_1

### x1 &nbsp; `DecreaseBuckshotAngle,MinorAccuracyBonus,IncreaseRange`

- params: `BuckshotAngleDecrease=5,RangeIncrease=1`
- ids: Condor_Mag_XX_1

### x1 &nbsp; `IncreaseBuckshotAngle,IncreaseReliability,MinorAccuracyBonus`

- params: `BuckshotAngleIncrease=5,ReliabilityIncrease=5`
- ids: Condor_Mag_fed_1

### x1 &nbsp; `IncreaseCritChangeScaled,compensator_effect`

- params: `CritChangeScaledIncrease=10`
- ids: Compensator_Glock

### x1 &nbsp; `DecreaseBuckshotAngle,IncreaseRange,FullChokeRecoil`

- params: `BuckshotAngleDecrease=60,RangeIncrease=2`
- ids: FullChoke

### x1 &nbsp; `IgnoreInTheDarkWhenFullyAimed,IgnoreCoverCtHWhenFullyAimed,IgnoreLightOfSightWhenFullyAimed,IgnoreInTheDarkWhenFullyAimed,IgnoreGrazingHitsWhenFullyAimed`

- params: _none_
- ids: G11_Rail_10

### x1 &nbsp; `ExtraOverwatchShots`

- params: _none_
- ids: HIll_StockGalil_01

### x1 &nbsp; `MagazineSizeMultiplier,IncreaseReloadAP`

- params: `MagazineSizeMultiplier=300%,ReloadAPIncrease=2`
- ids: G11_Mag_ext2_1

### x1 &nbsp; `MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=140%`
- ids: Glock17_Mag_ext_1

### x1 &nbsp; `CritBonusWhenFullyAimed`

- params: `crit=15%`
- ids: G11_Rail_15

### x1 &nbsp; `IncreaseAimAccuracy`

- params: `AimAccuracyIncrease=1`
- ids: Galil_Brake_Default

### x1 &nbsp; `SilentShots,IncreaseConditionDegradationMul,DecreaseAimAccuracy,flanker,compensator_effect_ugly_silencer,DecreaseOverwatchAngle`

- params: `AimAccuracyDecrease=1,ConditionDegradationMulIncrease=20,NoiseMultiplier=50%,OverwatchAngleDecrease=95`
- ids: ImprovisedSuppressor

### x1 &nbsp; `IncreaseAimAccuracy,IncreaseMaxAimActions,CritBonusWhenFullyAimed`

- params: `AimAccuracyIncrease=2,MaxAimActionsIncrease=1,crit=2%`
- ids: Caws_Scope_1

### x1 &nbsp; `boltaction,bolt_action_ap`

- params: `ap_manual=2`
- ids: Bolt_action_scout

### x1 &nbsp; `IncreaseDamage,ReduceReliabilityPercent,ChangeCaliberToBMG`

- params: `DamageIncrease=10,ReliabilityDecreasePercent=30`
- ids: Automag_Barrel_50bmg_def

### x1 &nbsp; `IncreaseDamage,ReduceReliabilityPercent,ChangeCaliberToBMG,IncreaseRange,IncreaseAimAccuracy`

- params: `AimAccuracyIncrease=2,DamageIncrease=10,RangeIncrease=6,ReliabilityDecreasePercent=30`
- ids: Automag_Barrel_50bmg_ext

### x1 &nbsp; `compensator_effect`

- params: _none_
- ids: AUGCompensator_01

### x1 &nbsp; `IncreaseReliability,compensator_effect,IncreaseCritChangeScaled`

- params: `CritChangeScaledIncrease=10,ReliabilityIncrease=10`
- ids: AUGCompensator_03

### x1 &nbsp; `BonusAccuracyWhenFullyAimed`

- params: `bonus_cth=12%,range=10`
- ids: C96R_Stock_1

### x1 &nbsp; `FirstShotIncreasedAim,OpportunityAttackBonusCth`

- params: `bonus_cth=7%`
- ids: Automag_Scope_1

### x1 &nbsp; `FirstAimBonusModifier,MinorAccuracyBonus,zzStockEquipped`

- params: `accuracy=4%`
- ids: B93RR_grip_unfld_1

### x1 &nbsp; `boltaction,bolt_action_ap`

- params: `ShootAPIncrease=1,ap_manual=3`
- ids: Bolt_action

### x1 &nbsp; `BonusAccuracyWhenFullyAimed`

- params: `bonus_cth=8%,range=10`
- ids: Automag_Stock_1

### x1 &nbsp; ``

- params: `bonus_cth=5%`
- ids: BaseIronsight_Anaconda

### x1 &nbsp; `GrenadeLauncher,zzGrndlEquipped,zzDontShowFoldBayonet`

- params: _none_
- ids: BM59_grndl_unfld

### x1 &nbsp; `SilentShots,IncreaseReliability,CritBonusSameTarget`

- params: `ReliabilityIncrease=12,crit=33%`
- ids: NoiseX_MiragePro

### x1 &nbsp; `SilentShots`

- params: `crit=25%`
- ids: ImprovisedSuppressor_Anaconda

### x1 &nbsp; `OpportunityAttackBonusCth,IncreaseOverwatchAngle,FirstShotIncreasedAim`

- params: `OverwatchAngleIncrease=140,bonus_cth=10%`
- ids: Leovision_Harpy

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=194,OverwatchAngleDecrease=84,ReloadAPIncrease=1`
- ids: MagLarge_3

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=128,OverwatchAngleDecrease=90,ReloadAPIncrease=1`
- ids: MagLarge_4

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=200,OverwatchAngleDecrease=84,ReloadAPIncrease=1`
- ids: MagLarge_5

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=166,OverwatchAngleDecrease=82,ReloadAPIncrease=2`
- ids: MagLarge_2

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=400,OverwatchAngleDecrease=83,ReloadAPIncrease=1`
- ids: MagLarge_10

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=200,OverwatchAngleDecrease=83,ReloadAPIncrease=1`
- ids: MagLarge_11

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=146,OverwatchAngleDecrease=90,ReloadAPIncrease=1`
- ids: MagLarge_1

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=250,OverwatchAngleDecrease=79,ReloadAPIncrease=2`
- ids: MagLarge_6

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=400,OverwatchAngleDecrease=71,ReloadAPIncrease=2`
- ids: MagLarge_8

### x1 &nbsp; `ReduceReliability,ReduceRange,ReduceShootAP,HalfRangeDmgIncrease,zzRemove_cumbersome`

- params: `RangeDecrease=25,ReliabilityDecrease=15,ShootAPDecrease=3,subtract_cumbersome=1`
- ids: NTW_20_barrel_ext_1

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=140,OverwatchAngleDecrease=91,ReloadAPIncrease=1`
- ids: MagLarge_7

### x1 &nbsp; `AccuracyBonusProne,zzStockEquipped,MinorAccuracyBonus`

- params: _none_
- ids: NTW20_stock_unfld_1

### x1 &nbsp; `IncreaseReloadAP,MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=333,OverwatchAngleDecrease=74,ReloadAPIncrease=2`
- ids: MagLarge_9

### x1 &nbsp; `ExtraBurstShots,recoil_booster_effect`

- params: `dmg=4,extra_shots=5`
- ids: MuzzleBooster

### x1 &nbsp; `ExtraBurstShots`

- params: _none_
- ids: Internal_plus_burstshot

### x1 &nbsp; `MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=333,OverwatchAngleDecrease=79`
- ids: MagLargeFine_9

### x1 &nbsp; `MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=140,OverwatchAngleDecrease=91`
- ids: MagLargeFine_7

### x1 &nbsp; `IncreaseReliability,MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=80,ReliabilityIncrease=15`
- ids: M60_Mag_bag_1

### x1 &nbsp; `ExtraBurstShots`

- params: `dmg=4,extra_shots=5`
- ids: M60_Muzzle_def_1

### x1 &nbsp; `ReduceShootAP,ReduceRange,IncreaseBuckshotAngle,ReduceReliability`

- params: `BuckshotAngleIncrease=130,RangeDecrease=4,ReliabilityDecrease=15,ShootAPDecrease=2`
- ids: M1897_barrel_sshrt

### x1 &nbsp; `ExtraBurstShots`

- params: `extra_shots=6`
- ids: M134_Muzzlebooster

### x1 &nbsp; `ReduceShootAP,ReduceRange,IncreaseBuckshotAngle,ReduceReliability`

- params: `BuckshotAngleIncrease=115,RangeDecrease=2,ReliabilityDecrease=5,ShootAPDecrease=1`
- ids: M1897_barrel_shrt

### x1 &nbsp; `MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=400,OverwatchAngleDecrease=78`
- ids: MagLargeFine_8

### x1 &nbsp; `MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=146,OverwatchAngleDecrease=90`
- ids: MagLargeFine_1

### x1 &nbsp; `MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=200,OverwatchAngleDecrease=80`
- ids: MagLargeFine_12

### x1 &nbsp; `MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=400,OverwatchAngleDecrease=80`
- ids: MagLargeFine_10

### x1 &nbsp; `MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=128,OverwatchAngleDecrease=90`
- ids: MagLargeFine_4

### x1 &nbsp; `MagazineSizeMultiplier,drum_mag_hipfire`

- params: `MagazineSizeMultiplier=166,OverwatchAngleDecrease=84`
- ids: MagLargeFine_2

### x1 &nbsp; `MagazineSizeMultiplier`

- params: `MagazineSizeMultiplier=194,OverwatchAngleDecrease=84`
- ids: MagLargeFine_3

### x1 &nbsp; `StealthKillBonusPerAim,AccuracyBonusWhenAimed`

- params: `aim_bonus=1%,bonus_cth=3,maxaims=1,stealth_kill_bonus=4%`
- ids: stealth_ironsight_confidante

