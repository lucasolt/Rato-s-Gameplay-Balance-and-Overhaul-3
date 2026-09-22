
---- Gate on the mod id: reading an undefined global (_G.X) raises in the mod env, it is not nil
local TOG_PATCH_ID = "Dau6w"

local function reapply_tog_components()
    if not IsMod_loaded(TOG_PATCH_ID) or not WeaponComponents.WideScope then
        return
    end
    local ok, err = pcall(RatoTOGComponents)
    if not ok then
        print("GBO: RatoTOGComponents reapply failed --", err)
    end
end

---- RatoGBOComponents replaces the Mag* Visuals lists, wiping the ToG RevMags entries (MAC11_1 etc.)
local function reapply_tog_revmag_visuals()
    if not IsMod_loaded(TOG_PATCH_ID) then
        return
    end
    for _, fn in ipairs{GBOTOG_RevMag_WeaponComponentVisualPatch_manual, GBOTOG_RevMag_WeaponComponentVisualPatch} do
        local ok, err = pcall(fn)
        if not ok then
            print("GBO: ToG RevMag visual reapply failed --", err)
        end
    end
end

function GBO_GeneralComponentPatch()
    RatoGBOComponents()
    reapply_tog_revmag_visuals()
    --ApplyApertureItemParams() -- override de comps enquanto o aperture esta ligado
	reapply_tog_components()
	GBO_ApplyComponentCompose() -- BEFORE ancestors, otherwise the children wont have the traits
	GBO_ApplyComponentAncestorEffect() -- LAST. Copies ancestor effect and param tables, should be after the ancestors are set
end

function OnMsg.ClassesGenerate()
    RatoGBO_WepPatch()
end

function OnMsg.ModsReloaded()
	GBO_GeneralComponentPatch()	
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

