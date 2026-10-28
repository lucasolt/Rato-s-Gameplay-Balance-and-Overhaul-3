function presets_char_effect()
	local file_str = "CharEffectCompositeDef_function.lua"
    ForEachPreset('CharacterEffectCompositeDef', function(p)

        if p.id == "Savior" then
            p.Description = T(154798321599,
                              "Restore <em><percent(bandageBonus)></em> more <em>HP</em> when using <em>Bandage</em>.\n\nAdditionally, when an ally dies or is downed, the unit will enter an <em>Adrenaline Rush</em>, having bonus AP and Free Move.")
        end

        if p.id == "DanceForMe" then
            p.Description = T(917852954786, --[[CharacterEffectCompositeDef DanceForMe Description]]
                              "<em>Ranged</em> attack against each enemy in a <em>cone</em>, targeting their <em>Legs</em>.\n\nApplies <GameTerm('Overwatch')> in the area afterwards.\n\nManually cycling revolvers cost less AP.")
        end

        if p.id == "HawksEye" then
            p.Description = T(984561732232, --[[CharacterEffectCompositeDef HawksEye Description]]
                              "<GameTerm('PinDown')> applies <GameTerm('Exposed')> to the target.\n\n<GameTerm('PinDown')> <em>AP</em> cost is reduced by <em><pindownCostOverwrite> AP</em>.\n\nScope also makes <GameTerm('Biscuits')>.")
            -- for _, param in ipairs(p.Parameters) do
            --     if param.Name == 'pindownCostOverwrite' then
            --         param.Value = 1
            --     end
            -- end
        end

		if p.id == "HeavyWeaponsTraining" then
			p.Description = ratT(file_str, 99865784235, "Reduces <em>Shooting Stance</em> and <em>Attack AP</em> cost for <em>Heavy Weapons</em> and <em>Machine Guns</em>.")
		end
        --------------------------------------------------------------------------------------------

        if p.id == "Hardened" then
            p.Description = T {448317095726, "At the end of your turn, <em>transfer</em> up to <em><maxReservedAP> unused AP</em> to the next turn.\n\nGain <em><tempHPperAP></em> <GameTerm('Grit')> per <em><ap> AP</em> transferred.",
                               ap = R_VanillaAPToDisplay(1)}
        end

        if p.id == 'SteadyBreathing' then
            p.Description = T {778949186487, "Grants the ability to <em>Sprint</em> in combat.<newline><newline>Mobile attacks can move <em><ap> AP</em> further.",
                               ap = R_VanillaAPToDisplay(const.Combat.Perks.FastRunnerMobileMoveAP)}
        end

        --------------------------------------------------------------------------------------------
        if p.id == 'TakeAim' then -----------TakeAim
            p.Description = T(771192369187, 'Improves <em>Recoil</em> control.')
            for _, param in ipairs(p.Parameters) do
                if param.Name == 'chanceToHitBonus' then
                    param.Value = 5 ---  not used anymore
                end
            end

        end

        --------------------------------------------------------------------------------------------
        if p.id == 'AutoWeapons' then ------------AutoWeapons
            p.Description = ratT(file_str, 483920175316, "Reduced <em>Recoil</em> with <em>Burst Fire</em> and <em>Auto Fire</em>.\n\nWalks long <em>Auto Fire</em> strings onto the target faster once the impacts show.\n\nLess likely to <em>overrun the trigger</em> in <em>Auto Fire</em>.")
            for _, param in ipairs(p.Parameters) do
                if param.Name == 'automatics_penalty_reduction' then
                    param.Value = 100 ---  not used anymore
                end
            end
            p.unit_reactions = {
                PlaceObj('UnitReaction', {
                    Event = "OnModifyCTHModifier",
                    Handler = function(self, target, id, attacker, attack_target, action, weapon1,
                                       weapon2, data)
                        return
                    end,
                    HandlerCode = function(self, attacker, cth_id, data)
                        return
                    end
                })
            }
        end

        --------------------------------------------------------------------------------------------
        if p.id == "OpportunisticKiller" then
            p.Description = ratT(file_str, 483920175318, "Gain an <em>extra attack</em> when using <GameTerm('Overwatch')>.\n\n<em>Automatic reload</em> if <GameTerm('Overwatch')> was used last turn.")
        end

        if p.id == "Killzone" then
            p.Description = ratT(file_str, 483920175319, "<GameTerm('Overwatch')> attacks have <em>3 aim levels</em> against the <em>first</em> enemy that triggers it and <em>2 aim levels</em> against the <em>second</em> one.\n\nEnables <GameTerm('Crits')> with <GameTerm('Overwatch')> attacks.\n\nDoes not apply to <em>Machine Gun Setup</em>.")
        end

        if p.id == "NightOps" then
            for _, param in ipairs(p.Parameters) do
                if param.Name == "night_vision_penalty_reduction" then
                    param.Value = const.EnvEffects.NightVisionSightReduction
                end
            end
            p.Description = ratT(file_str, 483920175320, "At <em>Night</em> and in <em>underground</em> Sectors, the <em>Accuracy</em> penalty is reduced by <em><night_acc_penalty_reduction>%</em> and the <em>Sight</em> penalty by <em><night_vision_penalty_reduction>%</em>.\n\nSame effect as <em>Night Vision Goggles</em>; the two do not stack.")
        end

        --------------------------------------------------------------------------------------------
        if p.id == "Psycho" then
            p.Description = ratT(file_str, 483920175317, "Can decide to use a more vicious attack than the one selected: a <em>Single Shot</em> becomes a burst, and <em>Auto Fire</em> fires up to twice as many rounds at no extra <em>AP</em>.\n\nMore likely to <em>overrun the trigger</em> in <em>Auto Fire</em>.\n\nAdditional <em>conversation options</em>.")
        end

        --------------------------------------------------------------------------------------------
        if p.id == "Ambidextrous" then
            p.Description = T(453925191822,
                              "Decreases <em>AP</em> cost and <em>Accuracy</em> penalty when <em>Dual-Wielding</em> firearms")
            for _, param in ipairs(p.Parameters) do
                if param.Name == 'PenaltyReduction' then
                    param.Value = 0
                end
            end
            p.unit_reactions = {
                PlaceObj('UnitReaction', {
                    Event = "OnModifyCTHModifier",
                    Handler = function(self, target, id, attacker, attack_target, action, weapon1,
                                       weapon2, data)
                        return
                    end,
                    HandlerCode = function(self, attacker, cth_id, data)
                        return
                    end
                })
            }
        end

        --------------------------------------------------------------------------------------------
        if p.id == "RecklessAssault" then
            p.Description = T(254222471844,
                              "Make a longer <color EmStyle>Run and Gun</color>, firing more shots. \n\nSmiley will be <color EmStyle>Out of Breath</color> for a turn after use. \n\nCan't be used when <color EmStyle>Out of Breath</color>.")
        end
        ---------------------------------------------------------------	  
        local min_accuracy = 5

        if p.id == "Spiritual" then
            for _, param in ipairs(p.Parameters) do
                if param.Name == 'minAccuracy' then
                    param.Value = min_accuracy
                end
            end
        end

        -----------------------------------------------------------------------------
        if p.id == "Protected" then
            for _, param in ipairs(p.Parameters) do
                if param.Name == 'max_ap_carried' then
                    param.Value = R_VanillaAPToDisplay(2) -- read back as value * const.Scale.AP
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------		
        if p.id == "GruntyPerk" then
            p.Description = T(313423416367,
                              "<em>Attacks</em> the <em>closest</em> enemy with a firearm when <em>combat starts</em>, if possible. \n\nThe attack will have 3 aim levels and bonus accuracy.\n\nCan't be used with Heavy Weapons.")
        end

        ------------------------------------------------------------------------------------------------------------		
        if p.id == "CQCTraining" then
            for _, param in ipairs(p.Parameters) do
                if param.Name == "cqc_bonus_max" then
                    param.Value = 14
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------		
        if p.id == "MartialArts" then
            p.Description = T(158619792866,
                              "<em>Unarmed attacks</em> have extra damage scaling based on <em>Dexterity</em>.\n\nImproved <em>Defense</em> against <em>Melee Attacks</em>.")
        end
        ------------------------------------------------------------------------------------------------------------		
    end)
end

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [453925191822] = "Decreases <em>AP</em> cost and <em>Accuracy</em> penalty when <em>Dual-Wielding</em> firearms",
    [254222471844] = "Make a longer <color EmStyle>Run and Gun</color>, firing more shots. \n\nSmiley will be <color EmStyle>Out of Breath</color> for a turn after use. \n\nCan't be used when <color EmStyle>Out of Breath</color>.",
    [313423416367] = "<em>Attacks</em> the <em>closest</em> enemy with a firearm when <em>combat starts</em>, if possible. \n\nThe attack will have 1 aim level and bonus accuracy.\n\nCan't be used with Heavy Weapons.",
    [158619792866] = "<em>Unarmed attacks</em> have extra damage scaling based on <em>Dexterity</em>.\n\nImproved <em>Defense</em> against <em>Melee Attacks</em>.",
    [778949186487] = "Grants the ability to <em>Sprint</em> in combat.",
    [917852954786] = "<em>Ranged</em> attack against each enemy in a <em>cone</em>, targeting their <em>Legs</em>.\n\nApplies <GameTerm('Overwatch')> in the area afterwards.\n\nManually cycling revolvers cost less AP.",
    [154798321599] = "Restore <em><percent(bandageBonus)></em> more <em>HP</em> when using <em>Bandage</em>.\n\nAdditionally, when an ally dies or is downed, the unit will enter an <em>Adrenaline Rush</em>, having bonus AP and Free Move."

}

ratG_T_table['CharEffectCompositeDef_function.lua'] = t_id_table
