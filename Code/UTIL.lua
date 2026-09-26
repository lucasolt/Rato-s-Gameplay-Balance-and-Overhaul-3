function cRound(num)
    local numf
    local sign = 1
    if num < 0 then
        sign = -1
        num = -num
    end

    local integerNum = num + 0.5
    integerNum = integerNum - integerNum % 1

    numf = sign * integerNum

    numf = tostring(numf)
    numf = string.format("%.0f", numf)
    numf = tonumber(numf)
    return numf
end


function ratT(file_str, id, text, return_untranslated)
	ratG_T_table[file_str] = ratG_T_table[file_str] or {}
	ratG_T_table[file_str][id] = text
	return return_untranslated and Untranslated(text) or T(id, text)
end

function GBO_ChangeParamAndUpdateCache(class, param, value)
    if class and class.Parameters then
        if not param then
            print("GBO - Error updating param: no param name provided")
            return
        end

        local found_param

        for i, p in ipairs(class.Parameters) do
            if p.Name == param then
                found_param = true
                p.Value = value
                break
            end
        end

        if not found_param then
            table.insert(class.Parameters,
                PlaceObj(
                    'PresetParamNumber', {
                        'Name', param,
                        'Value', value,
                        'Tag', "<" .. param .. ">"
                    }))
        end

        if g_PresetParamCache[class] then
            g_PresetParamCache[class][param] = value
        else
            print("GBO - Param cache failed to update: class missing for param '" .. param .. "'")
        end
    else
        print("GBO - Error updating param '" .. tostring(param) .. "': class or Parameters table is nil")
    end
end

function cRoundFlt(value, step)
    local step = step or 0.5
    local remainder = value % step
    if remainder < step / 2 then
        return value - remainder
    else
        return value + (step - remainder)
    end
end

function cRoundDown(num)
    local numf = num
    -- local sign = 1

    -- if num < 0 then
    -- sign = -1
    -- num = -num
    -- end

    -- local integerNum = num + 0.5
    -- print("num", integerNum)
    -- print("num int", integerNum % 1)
    -- integerNum = integerNum - integerNum % 1

    -- numf = sign * integerNum

    numf = tostring(numf)
    numf = string.match(numf, "([%-%d]+)")
    numf = tonumber(numf)

    return numf
end

function R_IsAI(unit)
    local side = unit and unit.team and unit.team.side or ''
    if (side == "player1" or side == "player2") then
        return false
    end
    return true
end

function R_tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function FindXtByProp(obj, prop, prop_value) ---------------------- made by Audakira
    if obj and obj[prop] and obj[prop] == prop_value then
        local res = {}
        table.insert(res, obj)
        return res
    end
    for _, xt in ipairs(obj) do
        local res = FindXtByProp(xt, prop, prop_value)
        if res then
            table.insert(res, obj)
            return res
        end
    end
end

function IsMod_loaded(mod_id) --- made by Toni
    local mod_check = table.find(ModsLoaded, 'id', mod_id) or nil -- Replace "Mod_Id" with exact case sensitive modID you're testing for.

    if mod_check then
        return true
    end
    return false
end
