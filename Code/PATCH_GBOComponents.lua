-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

function RatoGBOComponents()
	print("Running RatoGBOComponents...")
	WeaponComponents["MagLargeFine"].ModificationEffects = table.copy(WeaponComponents["_Master_MagLargeFine"].ModificationEffects)
	WeaponComponents["MagLargeFine"].Parameters = table.copy(WeaponComponents["_Master_MagLargeFine"].Parameters)
	WeaponComponents["MagLargeFine"].Visuals = table.copy(WeaponComponents["_Master_MagLargeFine"].Visuals)
	WeaponComponents["MagLargeFine"].GBO_ComponentAncestor = "_Master_MagLargeFine"
	WeaponComponents["MagLargeFine"]:PostLoad()
	WeaponComponents["MagLarge"].ModificationEffects = table.copy(WeaponComponents["_Master_MagLarge"].ModificationEffects)
	WeaponComponents["MagLarge"].Parameters = table.copy(WeaponComponents["_Master_MagLarge"].Parameters)
	WeaponComponents["MagLarge"].Visuals = table.copy(WeaponComponents["_Master_MagLarge"].Visuals)
	WeaponComponents["MagLarge"].GBO_ComponentAncestor = "_Master_MagLarge"
	WeaponComponents["MagLarge"]:PostLoad()
	WeaponComponents["MagNormalFine"].ModificationEffects = table.copy(WeaponComponents["_Master_MagNormalFine"].ModificationEffects)
	WeaponComponents["MagNormalFine"].Parameters = table.copy(WeaponComponents["_Master_MagNormalFine"].Parameters)
	WeaponComponents["MagNormalFine"].Visuals = table.copy(WeaponComponents["_Master_MagNormalFine"].Visuals)
	WeaponComponents["MagNormalFine"].GBO_ComponentAncestor = "_Master_MagNormalFine"
	WeaponComponents["MagNormalFine"]:PostLoad()
	WeaponComponents["MagNormal"].ModificationEffects = table.copy(WeaponComponents["_Master_MagNormal"].ModificationEffects)
	WeaponComponents["MagNormal"].Parameters = table.copy(WeaponComponents["_Master_MagNormal"].Parameters)
	WeaponComponents["MagNormal"].Visuals = table.copy(WeaponComponents["_Master_MagNormal"].Visuals)
	WeaponComponents["MagNormal"].GBO_ComponentAncestor = "_Master_MagNormal"
	WeaponComponents["MagNormal"]:PostLoad()
	WeaponComponents["foldable_StockNormal"].ModificationEffects = table.copy(WeaponComponents["StockNormal"].ModificationEffects)
	WeaponComponents["foldable_StockNormal"].Parameters = table.copy(WeaponComponents["StockNormal"].Parameters)
	WeaponComponents["foldable_StockNormal"].GBO_ComponentAncestor = "StockNormal"
	WeaponComponents["foldable_StockNormal"]:PostLoad()
	WeaponComponents["StockFolded"].ModificationEffects = table.copy(WeaponComponents["StockNo"].ModificationEffects)
	WeaponComponents["StockFolded"].Parameters = table.copy(WeaponComponents["StockNo"].Parameters)
	WeaponComponents["StockFolded"].GBO_ComponentAncestor = "StockNo"
	WeaponComponents["StockFolded"]:PostLoad()
	print("Running RatoGBOComponents Done")
end
