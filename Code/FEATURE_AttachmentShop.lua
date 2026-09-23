---- Bobby Ray sells the attachment items on a page of their own. This is what makes the whole
---- feature a progression curve instead of a parts sink: tier decides when an optic can show up at
---- all, RestockWeight how often, MaxStock how many, and Cost what it asks for.
----
---- Categories are keyed by the subcategory's Category field, not by its preset group: re-placing a
---- preset under a different group leaves a stale copy in the old one (measured), so every category
---- gets the same Category driven GetSubCategories instead. That is also what moves Revised Mags'
---- five magazine pages off the Ammo page without touching that mod.

RAT_ATT_SHOP_ENABLED = true
RAT_ATT_SHOP_CATEGORY = "Attachments"

---- The devices that do not magnify. Everything else is an optic.
RAT_ATT_SHOP_SIGHTS = {
    RAT_Att_RedDot = true,
    RAT_Att_UVDot = true,
    RAT_Att_Flashlight = true,
    RAT_Att_TacticalDevice = true,
    RAT_Att_CompactReflexSight1x = true,
    RAT_Att_AssaltoReflexSight1x = true,
    RAT_Att_AssaltoReflexSight1xPistol = true,
    RAT_Att_VigilanteReflexSight1x = true,
    RAT_Att_ReflexSight = true
}

---- Muzzle devices and the underbarrel gear (bipod, grenade launchers) get their own pages; everything
---- else is an optic or a sight. Family items are muzzle devices unless underbarrel, so only the chokes need naming.
RAT_ATT_SHOP_MUZZLE = {
    RAT_Att_DuckbillChoke = true,
    RAT_Att_FullChoke = true
}
RAT_ATT_SHOP_SUPPORT = {RAT_Att_Bipod = true}

---- The curve: a tier 3 optic unlocks late, turns up rarely and never more than one at a time.
RAT_ATT_SHOP_TIERS = {
    {MaxStock = 3, RestockWeight = 100},
    {MaxStock = 2, RestockWeight = 60},
    {MaxStock = 1, RestockWeight = 30}
}

---- Percent applied to the tier weight, per page. Weights compete across the whole Attachments
---- category (magazines included), so this shifts the mix without changing how many items restock.
RAT_ATT_SHOP_PAGE_WEIGHT = {
    RatSights = 100,
    RatOptics = 100,
    RatMuzzle = 100,
    RatSupport = 100
}

---- Revised Mags files these under Ammo. A magazine is something you bolt onto a gun, so they move
---- here; the ids and sort order are theirs.
RAT_ATT_SHOP_MAGS = {
    {id = "PistolMags", name = "Pistol Mags", sort = 100},
    {id = "SMGMags", name = "SMG Mags", sort = 110},
    {id = "RifleMags", name = "Rifle Mags", sort = 120},
    {id = "MGMags", name = "MG Mags", sort = 130},
    {id = "OtherMags", name = "Other Mags", sort = 140}
}

---- Every subcategory whose Category names this one, in sort order. Replaces the vanilla version,
---- which reads the preset group and so cannot follow a page that moved.
local function rat_shop_subcats(self)
    local list = {}
    ForEachPreset("BobbyRayShopSubCategory", function(p)
        if p.Category == self.id and p.id ~= "Missing" then
            list[#list + 1] = p
        end
    end)
    table.sort(list, function(a, b)
        return (a.SortKey or 0) < (b.SortKey or 0)
    end)
    return list
end

local function rat_shop_subcat(id, name, sort)
    if not FindPreset("BobbyRayShopSubCategory", id) then
        PlaceObj('BobbyRayShopSubCategory', {
            Category = RAT_ATT_SHOP_CATEGORY,
            DisplayName = Untranslated(name),
            SortKey = sort,
            group = RAT_ATT_SHOP_CATEGORY,
            id = id
        })
    else
        FindPreset("BobbyRayShopSubCategory", id).Category = RAT_ATT_SHOP_CATEGORY
    end
end

function Rat_AttShopEnsureCategories()
    if not FindPreset("BobbyRayShopCategory", RAT_ATT_SHOP_CATEGORY) then
        PlaceObj('BobbyRayShopCategory', {
            DisplayName = Untranslated("Attachments"),
            GetSubCategories = rat_shop_subcats,
            UrlSuffix = "/attachments",
            SortKey = 50,
            group = "Default",
            id = RAT_ATT_SHOP_CATEGORY
        })
    end
    ForEachPreset("BobbyRayShopCategory", function(c)
        c.GetSubCategories = rat_shop_subcats
    end)

    rat_shop_subcat("RatSights", "Sights", 10)
    rat_shop_subcat("RatOptics", "Optics", 20)
    rat_shop_subcat("RatMuzzle", "Muzzle", 30)
    rat_shop_subcat("RatSupport", "Support", 40)
    for _, mag in ipairs(RAT_ATT_SHOP_MAGS) do
        rat_shop_subcat(mag.id, mag.name, mag.sort)
    end
end

---- A CategoryPair with no preset behind it makes PrepareShopItemsForRestock index a nil category
---- and take the whole restock down with it. Seen live with Revised Gear's LBE, Backpack and
---- Holster pages: their DataLoaded handler had not registered them. Give the orphans a page.
function Rat_AttShopRepairOrphans()
    local missing = {}
    ForEachPreset("InventoryItemCompositeDef", function(p)
        local class = g_Classes[p.id]
        local pair = class and class.CanAppearInShop and class.CategoryPair
        if pair and not FindPreset("BobbyRayShopSubCategory", pair) then
            missing[pair] = true
        end
    end)
    for pair in pairs(missing) do
        PlaceObj('BobbyRayShopSubCategory', {
            Category = "Other",
            DisplayName = Untranslated(pair),
            SortKey = 900,
            group = "Other",
            id = pair
        })
        print("Rat_AttShop: " .. pair .. " had items but no page -- filed under Other")
    end
end

---- The shop properties live on the class: PrepareShopItemsForRestock reads g_Classes, not the
---- preset. The preset gets them too, because the store UI reads that one.
---- Stock parts (AUG Swarovski, G11 ZO-1) come off the gun they belong to, so the shop never sells them.
function Rat_AttShopEnsureItems()
    local _, stock = Rat_AttCompatible()
    for _, def in ipairs(RAT_ATT_ITEMS) do
        local hidden = def.reserved or (stock[def.id] and not def.weight)
        local tier = RAT_ATT_SHOP_TIERS[def.tier]
        local page = ((def.family == "grenadelauncher" or RAT_ATT_SHOP_SUPPORT[def.id]) and "RatSupport") or
            ((def.family or RAT_ATT_SHOP_MUZZLE[def.id]) and "RatMuzzle") or
            (RAT_ATT_SHOP_SIGHTS[def.id] and "RatSights") or "RatOptics"
        local weight = def.weight or
            MulDivRound(tier.RestockWeight, RAT_ATT_SHOP_PAGE_WEIGHT[page] or 100, 100)
        local props = {
            CanAppearInShop = not hidden,
            Tier = def.tier,
            MaxStock = def.max_stock or tier.MaxStock,
            RestockWeight = hidden and 0 or weight,
            CanBeConsumed = true,
            ShopStackSize = 1,
            CategoryPair = page
        }
        for _, target in ipairs({g_Classes[def.id] or false, InventoryItemDefs[def.id] or false}) do
            if target then
                for k, v in pairs(props) do
                    target[k] = v
                end
            end
        end
    end
end

---- The four store buttons are hardcoded windows in the template, so a fifth category needs one
---- built by hand. Cloned off the Other button and dropped in front of the Order button.
function Rat_AttShopEnsureButton()
    local row, at, already
    local function walk(node)
        for i, child in ipairs(node) do
            if type(child) == "table" then
                if child.Id == "idButtonOther" then
                    row, at = node, i
                elseif child.Id == "idButtonRatAttachments" then
                    already = true
                end
                walk(child)
            end
        end
    end
    walk(XTemplates.PDABrowserBobbyRay_Store)
    if not row then
        return
    end

    local model = row[at]
    local button = not already and PlaceObj('XTemplateWindow', {
        '__context', function(parent, context)
            return RAT_ATT_SHOP_CATEGORY
        end,
        '__class', "PDABobbyRayPopupButtonClass",
        'Id', "idButtonRatAttachments",
        'Margins', box(0, 0, 10, 0),
        'Dock', "left",
        'HAlign', "center",
        'VAlign', "center",
        'MinWidth', 130,
        'LayoutMethod', model.LayoutMethod,
        'DisabledBackground', model.DisabledBackground,
        'Image', model.Image,
        'FrameBox', model.FrameBox,
        'Columns', model.Columns,
        'SqueezeY', true,
        'TextStyle', model.TextStyle,
        'Translate', true,
        'Text', Untranslated("Attachments"),
        'ColumnsUse', model.ColumnsUse
    })
    if button then
        table.insert(row, at + 1, button)
    end

    ---- the row is 1035 wide; four buttons at 144 + 20 plus the Order button and the cart total
    ---- already fill it, so a fifth only fits if the gaps and the labels give back what it takes
    for _, child in ipairs(row) do
        if type(child) == "table" and child.Id ~= "idTextCart" then
            child.Margins = box(0, 0, 10, 0)
            if child.__class == "PDABobbyRayPopupButtonClass" then
                child.MinWidth = 124
            end
        end
    end
end

---- Guns Bobby Ray sells come without the attachments he also sells: a scope is bought once, on its
---- own page. Stock parts stay on the gun, since the shop never sells those.
RAT_ATT_SHOP_STRIP_GUNS = true

local function rat_sold(cid, weapon)
    local item = Rat_AttItemFor(cid, weapon) or RAT_ATT_EXTRA[cid]
    local class = item and g_Classes[item]
    return class and class.CanAppearInShop
end

---- Swaps every sold attachment for the slot default, an empty slot, or the first unsold option, in
---- that order. Returns how many non-default parts came off, which is what a used gun was priced on.
function Rat_AttStripWeapon(weapon)
    local stripped = 0
    for _, slot in ipairs(weapon.ComponentSlots or empty_table) do
        local cid = weapon.components[slot.SlotType]
        if cid and cid ~= "" and rat_sold(cid, weapon) then
            local default = slot.DefaultComponent
            local repl = default and default ~= "" and default ~= cid and not rat_sold(default, weapon) and default
            repl = repl or slot.CanBeEmpty and ""
            if not repl then
                for _, alt in ipairs(slot.AvailableComponents or empty_table) do
                    if alt ~= cid and not rat_sold(alt, weapon) then
                        repl = alt
                        break
                    end
                end
            end
            if repl then
                weapon:SetWeaponComponent(slot.SlotType, repl)
                if cid ~= default then
                    stripped = stripped + 1
                end
            end
        end
    end
    return stripped
end

local function rat_strip_on()
    return RAT_ATT_ENABLED and RAT_ATT_SHOP_ENABLED and RAT_ATT_SHOP_STRIP_GUNS
end

if not RAT_ATT_OrigRandomlyModifyWeapon then
    RAT_ATT_OrigRandomlyModifyWeapon = RandomlyModifyWeapon
end

---- Used guns: the random parts that are shop attachments come off, and so does their price bump.
function RandomlyModifyWeapon(weapon)
    local cost_modifier = RAT_ATT_OrigRandomlyModifyWeapon(weapon)
    if rat_strip_on() then
        local stripped = Rat_AttStripWeapon(weapon)
        cost_modifier = Max(0, cost_modifier - stripped * const.BobbyRay.Restock_UsedWeaponComponentPriceMod)
    end
    return cost_modifier
end

if not RAT_ATT_OrigRestockStandardItem then
    RAT_ATT_OrigRestockStandardItem = RestockStandardItem
end

---- New guns: the store copy is what the listing shows, so strip it too.
function RestockStandardItem(item_class)
    RAT_ATT_OrigRestockStandardItem(item_class)
    local item = rat_strip_on() and g_BobbyRayStore.standard[item_class]
    if IsKindOf(item, "Firearm") then
        Rat_AttStripWeapon(item)
    end
end

---- A new gun is delivered from a fresh instance with factory parts, not from the store copy.
function OnMsg.BobbyRayShopShipmentSent(shipment)
    if not rat_strip_on() then
        return
    end
    for _, item in ipairs(shipment.items or empty_table) do
        if IsKindOf(item, "Firearm") then
            Rat_AttStripWeapon(item)
        end
    end
end

---- Captured once; a hot reload re-wraps the vanilla function, not itself.
if not RAT_ATT_OrigShopStatsOther then
    RAT_ATT_OrigShopStatsOther = BobbyRayStoreGetStats_Other
end

---- Families whose items are named after their first calibre. Boosters span bores (NATO, AK), so
---- one calibre in the column would mislead.
RAT_ATT_SHOP_CAL_FAMILIES = {compensator = true, suppressor = true}

---- Calibre-bound compensators and suppressors fill the stats column the way magazines do.
function BobbyRayStoreGetStats_Other(item)
    local id = item.class or item.id
    for _, def in ipairs(RAT_ATT_ENABLED and RAT_ATT_ITEMS or empty_table) do
        if def.id == id then
            local cal = RAT_ATT_SHOP_CAL_FAMILIES[def.family] and def.calibers and
                            FindPreset("Caliber", def.calibers[1])
            if cal then
                return {{T(196962828215, "Cal"), cal.Name}}
            end
            break
        end
    end
    return RAT_ATT_OrigShopStatsOther(item)
end

function Rat_AttShopSetup()
    if not RAT_ATT_SHOP_ENABLED or not RAT_ATT_ENABLED then
        return
    end
    Rat_AttShopEnsureCategories()
    Rat_AttShopEnsureItems()
    Rat_AttShopRepairOrphans()
    Rat_AttShopEnsureButton()
    ---- stock from before the flag: new guns only, a used gun's price already includes its parts
    if rat_strip_on() and g_BobbyRayStore then
        for _, item in pairs(g_BobbyRayStore.standard or empty_table) do
            if IsKindOf(item, "Firearm") then
                Rat_AttStripWeapon(item)
            end
        end
    end
end

function OnMsg.DataLoaded()
    Rat_AttShopSetup()
end

function OnMsg.ModsReloaded()
    Rat_AttShopSetup()
end

---- Presets placed at runtime do not always survive to the point the store asks for them -- both
---- Revised mods lost theirs this way -- so the pages are rebuilt whenever the PDA opens a tab.
function OnMsg.PDATabOpened(mode)
    if mode == "bobby_ray_shop" then
        Rat_AttShopSetup()
    end
end

function Rat_AttShopReport()
    local per, weight = {}, {}
    for _, def in ipairs(RAT_ATT_ITEMS) do
        local class = g_Classes[def.id]
        if class and class.CanAppearInShop then
            local key = class.CategoryPair .. " t" .. tostring(class.Tier)
            per[key] = (per[key] or 0) + 1
            weight[key] = (weight[key] or 0) + class.RestockWeight
        end
    end
    for key, n in pairs(per) do
        print("Rat_AttShop: " .. key .. " -> " .. n .. " items, weight " .. weight[key])
    end
    local ok, err = pcall(PrepareShopItemsForRestock, 3, false)
    print("Rat_AttShop: restock builds = " .. tostring(ok) .. (ok and "" or (" " .. tostring(err))))
end
