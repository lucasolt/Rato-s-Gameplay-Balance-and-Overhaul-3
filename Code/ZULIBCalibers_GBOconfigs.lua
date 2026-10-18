-- function OnMsg.DataLoaded()
--     zz_vanillasToSwap["Winchester1894"] = "_44CAL"
--     zz_vanillasToSwap["ColtAnaconda"] = "_44CAL"
--     zz_vanillasToSwap["DesertEagle"] = "_44CAL"
-- end
function OnMsg.zCore_ClassesGenerate()
    zz_vanillasToSwap["Winchester1894"] = nil -- "_44CAL"
    zz_vanillasToSwap["ColtAnaconda"] = nil -- "_44CAL"
    ---- ships in .50 AE; its .50 barrel conversion is retired
    zz_vanillasToSwap["DesertEagle"] = "50AE"
end

function OnMsg.ClassesBuilt()
    DesertEagle.Description = T(738216450917, --[[GBO DesertEagle Description]]
        "Everybody knows the Desert Eagle as a .50 caliber hand cannon, and this one is no exception.")
end
