---- Vanilla ends combat after 3 player turns where no team sees an enemy. The counter is saved after
---- that turn's check already ran, and a resumed MainLoop runs the check again -- each load counted
---- one extra blind turn, so a save on the 2nd blind turn ended combat as soon as it was loaded.
local SetDynamicData_orig = Combat.SetDynamicData

function Combat:SetDynamicData(combat_data)
    SetDynamicData_orig(self, combat_data)
    self.novis_resumed = true
end

local ShouldEndDueToNoVisibility_orig = Combat.ShouldEndDueToNoVisibility

function Combat:ShouldEndDueToNoVisibility()
    if self.novis_resumed then
        self.novis_resumed = nil
        self.turns_no_visibility = Max(0, self.turns_no_visibility - #g_Teams)
    end
    return ShouldEndDueToNoVisibility_orig(self)
end
