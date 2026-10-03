function FirearmBase:GetAutofireShots(action)
    if type(action) == "string" then
        action = CombatActions[action]
    end
    if action.rat_num_shots then
        return action.rat_num_shots
    end
    local shots = action:ResolveValue("num_shots") or 1
    --------------------------------

    local id = action.id
    if id == "RunAndGun" or id == "RecklessAssault" then
        id = Rat_ShortBurstAttackId(self)
    end
    ---- burst_shots is the selective burst; AutoFire is selectable (FEATURE_VariableAutofire), auto_shots is its default
    if id == "BurstFire" or id == "BuckshotBurst" then
        shots = self.burst_shots or 3
    elseif id == "AutoFire" then
        shots = self.auto_shots or 3
    elseif id == "MGBurstFire" or id == "GrizzlyPerk" then
        shots = self.long_shots or 6
    end

    -----------
    local shotsBoost = GetComponentEffectValue(self, "ExtraBurstShots", action.id)

    if shotsBoost then
        shots = shots + shotsBoost
    end

    return shots
end

----ok

