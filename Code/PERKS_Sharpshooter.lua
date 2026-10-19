---- Sharpshooter (Instagib): Settled stacks from starting turns on the same tile boost every aim level
---- of the first attack each turn (aim accuracy, crit chance, crit damage). Never on interrupts.

GameVar("gv_Rat_Settled", function() return {} end)

local function SameTile(a, b)
    return a and b and a:Dist(b) < const.SlabSizeX / 2
end

---- attacker_pos: where the shot is evaluated from (AI/preview at another tile gets nothing)
function Rat_SettledStacks(unit, opportunity_attack, attacker_pos)
    if opportunity_attack or not IsKindOf(unit, "Unit") or unit.placeholder or not g_Combat then
        return 0
    end
    ---- covers retaliations and other interrupts that are not flagged opportunity_attack
    if g_Teams[g_CurrentTeam] ~= unit.team then
        return 0
    end
    local perk = unit:GetStatusEffect("Instagib")
    if not perk or not perk:ResolveValue("available") then
        return 0
    end
    local s = gv_Rat_Settled[unit.session_id]
    if not s or s.stacks <= 0 or not SameTile(s.pos, unit:GetPos()) then
        return 0
    end
    if attacker_pos and not SameTile(s.pos, attacker_pos) then
        return 0
    end
    return s.stacks
end

function Rat_SettledAimAcc(unit, opportunity_attack, attacker_pos)
    return Rat_SettledStacks(unit, opportunity_attack, attacker_pos) * const.Combat.Perks.SharpshooterAccPerStack
end

function Rat_SettledCritChance(unit, aim, opportunity_attack)
    if (aim or 0) <= 0 then
        return 0
    end
    return Rat_SettledStacks(unit, opportunity_attack) * aim * const.Combat.Perks.SharpshooterCritPerAimPerStack
end

function Rat_SettledCritDamage(unit, aim, opportunity_attack)
    if (aim or 0) <= 0 then
        return 0
    end
    return Rat_SettledStacks(unit, opportunity_attack) * aim * const.Combat.Perks.SharpshooterCritDmgPerAimPerStack
end

local file_str = "PERKS_Sharpshooter.lua"

local function SettledBeginTurn(self, unit)
    self:SetParameter("available", true)
    local pos = unit:GetPos()
    local s = gv_Rat_Settled[unit.session_id]
    if s and SameTile(s.pos, pos) then
        local stacks = Min(s.stacks + 1, const.Combat.Perks.SharpshooterMaxStacks)
        if stacks > s.stacks then
            s.stacks = stacks
            local text = "Settled <stacks>"
            ratT(file_str, 483920175331, text)
            CreateFloatingText(unit, T {483920175331, text, stacks = stacks})
        end
    else
        gv_Rat_Settled[unit.session_id] = {pos = pos, stacks = 0}
    end
end

---- anchor at combat start, so a merc that waited in position is Settled on its first turn
function OnMsg.CombatStart()
    gv_Rat_Settled = {}
    for _, unit in ipairs(g_Units) do
        if unit.session_id and HasPerk(unit, "Instagib") then
            gv_Rat_Settled[unit.session_id] = {pos = unit:GetPos(), stacks = 0}
        end
    end
end

function OnMsg.CombatEnd()
    gv_Rat_Settled = {}
end

function Rat_SharpshooterDescription()
    local p = const.Combat.Perks
    local text = "Start your turn on the tile where you started the previous one to become <em>Settled</em> (up to <max> stacks). Moving loses all stacks.\n\nEach stack gives <em>every aim level</em> of your <em>first attack</em> each turn <em>+<acc> Aim Accuracy</em>, <em>+<crit>% Crit Chance</em> and <em>+<critdmg>% Crit Damage</em>.\n\nDoes not apply to <GameTerm('Interrupt')> attacks."
    ratT(file_str, 483920175333, text)
    return T {483920175333, text, max = p.SharpshooterMaxStacks, acc = p.SharpshooterAccPerStack,
              crit = p.SharpshooterCritPerAimPerStack, critdmg = p.SharpshooterCritDmgPerAimPerStack}
end

function OnMsg.ClassesGenerate(classdefs)
    local perk = classdefs.Instagib
    if not perk then
        return
    end
    ---- drops the vanilla bonus aims and Marksmanship damage
    perk.unit_reactions = {
        PlaceObj('UnitReaction', {
            Event = "OnBeginTurn",
            Handler = SettledBeginTurn
        }),
        PlaceObj('UnitReaction', {
            Event = "OnUnitAttack",
            Handler = function(self, target, attacker, action, attack_target, results, attack_args)
                if target == attacker and not (attack_args and attack_args.opportunity_attack) then
                    self:SetParameter("available", false)
                end
            end
        })
    }
    perk.Description = Rat_SharpshooterDescription()
end
