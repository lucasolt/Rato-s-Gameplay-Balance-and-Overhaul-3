function OnMsg.ClassesGenerate()
    RatoGBO_WepPatch()
end

function OnMsg.ModsReloaded()
    RatoGBOComponents()
    ApplyApertureItemParams() -- override de opticas enquanto o aperture esta ligado
    GBO_patch_WeaponsPresetsClass()
end

local function isModActiveInVersion(modId, version)
    local activeMods = GetLoadedModsSavegameData() or {}
    for _, mod in ipairs(activeMods) do
        if mod.id == modId and Mods[mod.id]:CompareVersion(version, "ignore_revision") >= 0 then
            return true
        end
    end
    return false
end

local function openZulibVersionWarning()
    local properZulibVersion = isModActiveInVersion("Tc3ajdY",
                                                    {version_major = 1, version_minor = 6})
    if properZulibVersion then
        return
    end

    local parent = false
    local pda = GetDialog("PDADialog")
    if pda then
        parent = pda.idDisplayPopupHost
    end

    local msg = {
        SortKey = 100,
        Title = T("Zulib Weapons Core compability issue"), -- Header
        Text = T(
            "Zulib Weapons Core mod is outdate\n\nPlease use this version instead:\n\nZulib Weapons Core - unreleased 1.06 version\nhttps://steamcommunity.com/sharedfiles/filedetails/?id=3309452207"), -- Text
        group = "Default",
        id = "ZulibMsg",
        open_as_read = true
    }
    local messagesContext = {ZulibMsg = msg}
    messagesContext[1] = msg

    local popupUI = XTemplateSpawn("GBOMessagePopup", parent, messagesContext)
    popupUI:Open()
    popupUI.idTitle:SetText(T("Message from Rato's Gameplay Balance and Overhaul"))
    popupUI.idPopupTitle:SetText(msg.Title)
    popupUI.idText:SetText(msg.Text)
end

function OnMsg.ModsReloaded()
    openZulibVersionWarning()
end

