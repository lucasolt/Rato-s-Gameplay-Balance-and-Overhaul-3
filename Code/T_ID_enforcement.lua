function rat_AppendCodeTextToTranslationTable(TID_table)

    if GetLanguage() == "English" then
        print("GBO - appending code text to translation table")
        for _, table_ in pairs(TID_table) do
            for k, v in pairs(table_) do
                if not TranslationTable[k] or not (TranslationTable[k] == TID_table[k]) then
                    TranslationTable[k] = v
                end
            end
        end
    else
        for _, table_ in pairs(TID_table) do
            for k, v in pairs(table_) do
                if not TranslationTable[k] then ---in case of no translation, set the english text
                    TranslationTable[k] = v
                end
            end
        end
    end
end

function rat_GetEnglishVanillaTable(id)
    local csv = {}
    local path = GetExecDirectory() .. "ModTools\\Game.csv"
    local fields = {[1] = "id", [2] = "text", [5] = "context"}
    LoadCSV(path, csv, fields, "omit_captions")
    if csv == {} then
        assert(true, "GBO - Could not find english table at " .. path ..
                   "for function at T_ID_enforcement.lua")
        return csv
    end
    local return_Table = {}

    for i, line in ipairs(csv) do
        return_Table[tonumber(line.id)] = line.text
    end
    if id then
        print(id, "=", return_Table[id])
        return return_Table[id]
    end
    return return_Table

end

function rat_BuildExportableTableBeforeExport(TID_table)
    local english_table = rat_GetEnglishVanillaTable()
    local exportable_table = {}
    for filepath, table_ in pairs(TID_table) do
        local count = 1
        for k, v in pairs(table_) do
            if english_table[k] and (english_table[k] == v) then -- wont export vanilla text as it will already have translations
                print("GBO - vanilla text detected", k, v)
            else
                table.insert(exportable_table, {
                    id = k,
                    text = v,
                    translation = "",
                    context = "rat_" .. filepath .. "_" .. count,
                    voice = ""
                })
                count = count + 1
            end
        end
    end
    return exportable_table
end

function OnMsg.DataLoaded()
    rat_AppendCodeTextToTranslationTable(ratG_T_table)
end

function OnMsg.TranslationChanged()
    rat_AppendCodeTextToTranslationTable(ratG_T_table)
end

local original_GedOpGenTTableMod = GedOpGenTTableMod

function GedOpGenTTableMod(socket, root)

    if root[1].id == "cfahRED" then
        -----------
        -- if not GetLanguage() == "English" then
        -- assert("Rato, set language to english before exporting translation table")
        -- return false
        -- end

        local code_text_table = rat_BuildExportableTableBeforeExport(ratG_T_table)
        -- enforce_mod_itemsID("cfahRED")
        -----------

        local csv = {}
        local modDef = root[1]

        modDef:ForEachModItem(function(item)
            table.iappend(csv, item:GenTTable())
        end)

        -- if true then
        --     Inspect(csv)
        --     -- return csv
        -- end
        -----------
        for _, line in ipairs(code_text_table) do
            table.iappend(csv, {line})
        end
        ------------

        local csv_filename = modDef.path .. "/ModTexts.csv"
        local fields = {"id", "text", "translation", "voice", "context"}
        local field_captions = {"ID", "Text", "Translation", "VoiceActor", "Context"}
        local err = SaveCSV(csv_filename, csv, fields, field_captions, ",")
        if err then
            socket:ShowMessage("Error", "Failed to export a translation table to\n" ..
                                   ConvertToOSPath(csv_filename) .. "\nError: " .. err)
        else
            socket:ShowMessage("Success", "Successfully exported a translation table to\n" ..
                                   ConvertToOSPath(csv_filename))
        end
    else
        original_GedOpGenTTableMod(socket, root)
    end
end

