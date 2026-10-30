---- Pinned Down (ANKmKG) hand-codes its AP in vanilla units (`n * const.Scale.AP`); copies below use R_VanillaAP.
---- Its effect params are covered by ScanModAPParams. It may load after us, so patch the built class.
local PANIC_AP = 12

local function HandleSuppression(self, target)
	if target.HireStatus == "Dead" then
		return
	end

	if not g_Combat then
		return
	end

	local suppression_level = target.suppression_level or 0

	local old_suppression_level = target.old_suppression_level or 0

	local consumed_ap = (suppression_level - old_suppression_level) * self.RemovedApPerLevel

	if consumed_ap > 0 then
		target:ConsumeAP(R_VanillaAP(consumed_ap))

		self:LogRemovedAps(target, R_VanillaAPToDisplay(consumed_ap))
	end

	if self:PanicRoll(target, 100) then
		target:GainAP(R_VanillaAP(PANIC_AP))
		target:AddStatusEffect("Panicked")
		self:LogPanicked(target, "Panicked")
	elseif self:PanicRoll(target, 120) then
		target:RemoveStatusEffect("PinnedDown")
		target:RemoveStatusEffect("SuppressedCustom")
		target:RemoveStatusEffect("UnderFire")
		target:RemoveStatusEffect("UnderHeavyFire")
		target:RemoveStatusEffect("ShotAt")
		target:GainAP(R_VanillaAP(PANIC_AP))
		target.suppression_level = 0
		target.suppression_meter = 0
		target:AddStatusEffect("Berserk")
		self:LogPanicked(target, "Berserk")
	else
		if not target.team.player_team then
			self:SpecialAIRules(target)
		end

		if target.stance ~= "Prone" then
			local go_prone = self:GoProneRoll(target)

			if go_prone then
				target:SetActionCommand("ChangeStance", nil, nil, "Prone")
			end
		end
	end
end

local function LogPanicked(self, target, status)
	if not target or IsPlayerEnemy(target) then
		return
	end

	local logLevel = SuppressedGetModOptions("consumed_aps_log_level", "short", "string")

	CombatLog(logLevel, T({
		Untranslated("<em><target></em> became <status> due to suppression and got <ap> AP"),
		target = target:GetDisplayName(),
		status = Untranslated(status),
		ap = R_VanillaAPToDisplay(PANIC_AP)
	}))
end

local function patch_pinned_down()
	local cls = g_Classes.SuppressionMeter
	if not IsMod_loaded("ANKmKG") or not cls then
		return
	end
	cls.HandleSuppression = HandleSuppression
	cls.LogPanicked = LogPanicked
	---- its per-hit suppression breakdown floods the combat log with 7 debug lines
	cls.LogToSnype = empty_func
end

OnMsg.ClassesBuilt = patch_pinned_down
OnMsg.AutorunEnd = patch_pinned_down
