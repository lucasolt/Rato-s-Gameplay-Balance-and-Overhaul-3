---- Corner badges over barrel component icons on the weapon bench (slot buttons and the part popup).
---- Keyed by the composed effect, so ToG barrels that carry the same effect get the badge too.
RAT_COMPONENT_BADGES = {
    {effect = "heavy_barrel_effect", image = "Mod/cfahRED/Images/Badges/barrel_heavy.png"},
    {effect = "hipfire_light_barrel", image = "Mod/cfahRED/Images/Badges/barrel_light.png"},
    {effect = "IncreaseReliability", image = "Mod/cfahRED/Images/Badges/barrel_improved.png"},
}
RAT_COMPONENT_BADGE_SIZE = 28

---- Normal-length variants show the normal barrel and let the badge tell them apart; these have no items.lua copy.
RAT_BADGED_BASE_ICONS = {BarrelNormalImproved = "UI/Icons/Upgrades/default_barrel"}

function OnMsg.DataLoaded()
    for id, icon in pairs(RAT_BADGED_BASE_ICONS) do
        local comp = WeaponComponents[id]
        if comp then
            comp.Icon = icon
        end
    end
end

function Rat_ComponentBadges(comp)
    if not comp or comp.Slot ~= "Barrel" then
        return empty_table
    end
    local effects = comp.ModificationEffects or empty_table
    local out = {}
    for _, badge in ipairs(RAT_COMPONENT_BADGES) do
        if table.find(effects, badge.effect) then
            out[#out + 1] = badge.image
        end
    end
    return out
end

function Rat_SetComponentBadges(icon, comp)
    if not icon then
        return
    end
    local images = Rat_ComponentBadges(comp)
    ---- held on the icon, not by Id: an Id would land on the button's node
    local holder = rawget(icon, "rat_badges")
    if #images == 0 then
        if holder then
            holder:SetVisible(false)
        end
        return
    end
    if not holder then
        holder = XTemplateSpawn("XWindow", icon)
        rawset(icon, "rat_badges", holder)
        holder:SetLayoutMethod("VList")
        holder:SetLayoutVSpacing(2)
        holder:SetHAlign("left")
        holder:SetVAlign("bottom")
        holder:SetMargins(box(4, 0, 0, 4))
        holder:SetUseClipBox(false)
        holder:SetHandleMouse(false)
        if icon.window_state == "open" then
            holder:Open()
        end
    end
    holder:DeleteChildren()
    local size = RAT_COMPONENT_BADGE_SIZE
    for _, image in ipairs(images) do
        local img = XTemplateSpawn("XImage", holder)
        img:SetImage(image)
        img:SetImageFit("stretch")
        img:SetMinWidth(size)
        img:SetMaxWidth(size)
        img:SetMinHeight(size)
        img:SetMaxHeight(size)
        img:SetUseClipBox(false)
        img:SetHandleMouse(false)
        ---- follows the unaffordable greying the popup puts on the icon
        img:SetDesaturation(icon:GetDesaturation())
        if holder.window_state == "open" then
            img:Open()
        end
    end
    holder:SetVisible(true)
end

local function wrap_context_update(element, item_of)
    if element.rat_badges_wrapped then
        return
    end
    local orig = element.OnContextUpdate
    ---- SetProperty, not assignment: it drops the spawn cache that would keep the old function
    element:SetProperty("OnContextUpdate", function(self, context, ...)
        orig(self, context, ...)
        Rat_SetComponentBadges(rawget(self, "idIcon"), item_of(self))
    end)
    element.rat_badges_wrapped = true
end

---- Every match: the part popup declares its component button twice.
local function wrap_all(node, prop, value, item_of)
    if type(node) ~= "table" then
        return
    end
    if rawget(node, prop) == value and node.OnContextUpdate then
        wrap_context_update(node, item_of)
    end
    for _, child in ipairs(node) do
        wrap_all(child, prop, value, item_of)
    end
end

local function slot_item(self)
    local weapon = ResolvePropObj(self.context)
    local slot = self.context and self.context.slot
    local id = weapon and slot and weapon.components and weapon.components[slot.SlotType]
    return id and WeaponComponents[id]
end

local function choice_item(self)
    return self.context and self.context.item
end

---- After CommonLib's ChangeUI, which replaces the slot button's OnContextUpdate on mod load.
function OnMsg.ModsReloaded()
    wrap_all(XTemplates.WeaponComponentWindow, "Id", "idCurrent", slot_item)
    wrap_all(XTemplates.WeaponModChoicePopup, "FXPress", "WeaponModificationComponentClick", choice_item)
end
