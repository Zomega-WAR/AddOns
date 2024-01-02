if (not PP)
then
    PP = {}
end

PP.settings =
{
    persistent = false,
    ordering =
    {
        L"Default",
        L"Name",
        L"Count"
    },
    type =
    {
        L"Diffuse (\"flat\") only",     -- Type 1
        L"Specular (\"shiny\") only",   -- Type 2
        L"Diffuse and Specular"
    },
    filter = "",
    windows =
    {
        ["main"] =
        {
            name = "PPMain",
            width = 0,
            height = 0,
            x = 0,
            y = 0,
            minimized = false,
            anchor = {}
        }
    },
    items =
    {
        { slot = 15, iconNum = 11, dyes = {} },
        { slot =  9, iconNum =  9, dyes = {} },
        { slot = 10, iconNum = 10, dyes = {} },
        { slot = 13, iconNum = 13, dyes = {} },
        { slot =  6, iconNum =  6, dyes = {} },
        { slot =  7, iconNum =  7, dyes = {} },
        { slot = 14, iconNum = 14, dyes = {} },
        { slot =  8, iconNum =  8, dyes = {} }
    },
    itemsPersist =
    {
        { slot = 15, iconNum = 11, dyes = {} },
        { slot =  9, iconNum =  9, dyes = {} },
        { slot = 10, iconNum = 10, dyes = {} },
        { slot = 13, iconNum = 13, dyes = {} },
        { slot =  6, iconNum =  6, dyes = {} },
        { slot =  7, iconNum =  7, dyes = {} },
        { slot = 14, iconNum = 14, dyes = {} },
        { slot =  8, iconNum =  8, dyes = {} }
    },
    items_defaults =
    {
        ["primary"]   = { r = 0, g = 0, b = 0, a = 0.1 },
        ["secondary"] = { r = 0, g = 0, b = 0, a = 0.1 }
    }
}

PP.selectedDyeIndex = 1

PP.introText = L"This addon lets you preview all available dyes in game."
PP.introGuide = L"1. Select a dye from the Dye Picker. A specific dye can be located by entering the name of the dye into the Name filter, or by changing the Ordering method for the list. \n2. Apply the selected dye to an item slot using left/right mouse buttons. Alternatively color the All slot, to apply the same dyes to all item slots. \n3. The character model is now recolored with the selected dyes."
PP.itemWindowGuide = L"Click an item slot to apply a selected dye.\n\nLeft Click: Set primary color\nRight Click: Set secondary color\n\nClick twice to remove the dye"

PP.toolTips =
{
    items =
    {
        [15] = L"Apply dye to all Items.\n\nThis has lower priorty then setting a color for a specific item slot.",
        [ 9] = L"Helm",
        [10] = L"Shoulders",
        [13] = L"Back",
        [ 6] = L"Body",
        [ 7] = L"Gloves",
        [14] = L"Belt",
        [ 8] = L"Boots"
    }
}

local debug_mode = false
if (debug_mode)
then

    d ("HighlightWindow( window ) : available")

    function HighlightWindow (window_name)

        if (WindowGetShowing (HelpTips.FOCUS_WINDOW_NAME) == true)
        then
            WindowStopAlphaAnimation (HelpTips.FOCUS_WINDOW_NAME)
            WindowSetShowing (HelpTips.FOCUS_WINDOW_NAME, false)
        end

        HelpTips.SetFocusOnWindow (window_name)

    end

end

function PP.Initialize ()

    local window_name = "PPMain"

    LibSlash.RegisterSlashCmd ("pp", function () WindowSetShowing (window_name, true) end)

    TextLogAddEntry ("Chat", SystemData.ChatLogFilters.SAY, L"Pocket Palette: Type /PP to show window")

    RegisterEventHandler (SystemData.Events.ITEM_SET_DATA_ARRIVED, "PP.UpdateItemSlots")
    RegisterEventHandler (SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "PP.UpdateItemSlots")
    RegisterEventHandler (SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED, "PP.UpdateItemSlots")

    PP.CreateWindow ()
    PP.PersistentSettings ()
    PP.GetDyeData ()
    PP.UpdateDyeList ()

    RegisterEventHandler (SystemData.Events.LOADING_END, "PP.PreviewDyes")

end

function PP.OnShown ()

    if (debug_mode)
    then
        d ("PP.OnShown")
    end

    PP.PreviewDyes ()
    PP.UpdateDyeCounts ()
    PP.UpdateItemSlots ()

end

function PP.OnClose ()

    if (debug_mode)
    then
        d ("PP.OnClose")
    end

    PP.ResetPreviewDyes ()

    WindowSetShowing (PP.settings.windows.main.name, false)

end

function PP.CreateWindow ()

    if (debug_mode)
    then
        d ("PP.CreateWindow")
    end

    local window_name_main = "PPMain"
    CreateWindow (window_name_main, false)
    LabelSetText (window_name_main.."TitleBarText", L"Pocket Palette")
    ButtonSetText (window_name_main.."CharacterWindowBtn", L"Paperdoll")
    ButtonSetText (window_name_main.."TogglePickerBtn", L"Hide")
    LabelSetText (window_name_main.."IntroText", PP.introText)
    LabelSetText (window_name_main.."IntroGuide", PP.introGuide)
    LabelSetText (window_name_main.."SaveSettingsLabel", L"Persistent settings")
    ButtonSetPressedFlag (window_name_main.."SaveSettingsButton", PP.settings.persistent)

    local window_name_dye = "DyeWindow"
    LabelSetText (window_name_dye.."TitleBarText", L"Dye Picker")
    LabelSetText (window_name_dye.."SelectedDye", L"Selected Dye")
    LabelSetText (window_name_dye.."Filter", L"Name filter:")
    LabelSetText (window_name_dye.."DyeOrder", L"Ordering:")
    LabelSetText (window_name_dye.."DyeType", L"Type:")

    for key, value in pairs (PP.settings.ordering)
    do
        ComboBoxAddMenuItem (window_name_dye.."DyeOrderCombo", value)
    end

    ComboBoxSetSelectedMenuItem (window_name_dye.."DyeOrderCombo", 1)

    for key, value in pairs (PP.settings.type)
    do
        ComboBoxAddMenuItem (window_name_dye.."DyeTypeCombo", value)
    end

    ComboBoxSetSelectedMenuItem (window_name_dye.."DyeTypeCombo", 3)

    local window_name_item = "ItemWindow"
    LabelSetText (window_name_item.."TitleBarText", L"Item Slots")
    LabelSetText (window_name_item.."Guide", PP.itemWindowGuide)

    PP.settings.windows["main"].width, PP.settings.windows["main"].height = WindowGetDimensions (PP.settings.windows["main"].name)

    local i, j, k, l, m = WindowGetAnchor (PP.settings.windows["main"].name, 1)
    PP.settings.windows["main"].anchor.x = l
    PP.settings.windows["main"].anchor.y = m

end

function PP.PersistentSettings ()

    if (PP.settings.persistent == false)
    then
        PP.settings.items = PP.settings.itemsPersist
    end

end

function PP.PersistantToggle ()

    local window_name = "PPMain".."SaveSettings".."Button"

    PP.settings.persistent = PP.settings.persistent == false

    ButtonSetPressedFlag (window_name, PP.settings.persistent)

end

function PP.GetDyeData ()

    local function skip_dye_name (dye_name)
        return (dye_name == nil) or (dye_name == '') or (dye_name == '0') or (dye_name == 0) or (dye_name == 'PLAYER DYES') or (string.find (dye_name, "color", 1, true) == 1)
    end

    PP.DyeData = {}

    BuildTableFromCSV ("Interface/Addons/PocketPalette/PocketPalette.csv", "PP._DyeData")

    for dye_key, dye_value in pairs (PP._DyeData)
    do
        if (not skip_dye_name (PP._DyeData[dye_key].Name))
        then
            if (PP._DyeData[dye_key])
            then
                PP.DyeData[dye_key] = PP._DyeData[dye_key]
                PP.DyeData[dye_key].ID = dye_key
                PP.DyeData[dye_key].Count = 0

                if (PP.DyeData[dye_key].SpecularIntensity ~= nil) and (PP.DyeData[dye_key].SpecularIntensity > 0)
                then
                    PP.DyeData[dye_key].Type = 2    -- Specular
                    --d(PP.DyeData[dye_key].Name)
                else
                    PP.DyeData[dye_key].Type = 1    -- Diffuse
                end

            end
        end
    end

    PP._DyeData = nil

    PP.UpdateDyeCounts ()

end

function PP.UpdateDyeCounts ()

    local inventory_dyes = {}

    local items = GetInventoryItemData ()

    for index, value in ipairs (items)
    do
        if (value.id ~= 0) and (value.type == GameData.ItemTypes.DYE)
        then
            if (inventory_dyes[value.uniqueID])
            then
                inventory_dyes[value.uniqueID].count = inventory_dyes[value.uniqueID].count + value.stackCount
            else
                inventory_dyes[value.uniqueID] =
                {
                    name = tostring (value.name),
                    id = value.uniqueID,
                    count = value.stackCount
                }
            end
        end
    end

    items = GetBankData ()

    for index, value in ipairs (items)
    do
        if (value.id ~= 0) and (value.type == GameData.ItemTypes.DYE)
        then
            if inventory_dyes[value.uniqueID]
            then
                inventory_dyes[value.uniqueID].count = inventory_dyes[value.uniqueID].count + value.stackCount
            else
                inventory_dyes[value.uniqueID] =
                {
                    name = tostring (value.name),
                    id = value.uniqueID,
                    count = value.stackCount
                }
            end
        end
    end

    items = nil

    if (debug_mode)
    then
        inventory_dyes["TEST"] =
        {
            name = tostring ("Chaos Black Dye"),
            id = 99,
            count = 999
        }
    end

    for dye_key, dye_value in pairs (PP.DyeData)
    do
        for inventory_key, inventory_value in pairs (inventory_dyes)
        do
            if (string.gsub (dye_value.Name,' %(.*%)','').." Dye" == inventory_value.name)
            then
                PP.DyeData[dye_key].Count = inventory_value.count
            end
        end
    end

end

function PP.ShowPaperDoll ()

    if (WindowGetShowing ("CharacterWindow") == true)
    then
        WindowSetShowing ("CharacterWindow", false)
    else
        WindowSetShowing ("CharacterWindow", true)
    end
end

function PP.ToggleWindow ()

    local b = PP.settings.windows["main"].name

    local l, m = WindowGetScreenPosition (b)
    local w, w = WindowGetDimensions (b)

    local x = {}
    local y = WindowGetAnchorCount (b)

    for z = 1, y
    do
        table.insert (x, { WindowGetAnchor (b, z) })
    end

    local A = 200

    if (PP.settings.windows["main"].minimized == true)
    then
        WindowSetShowing ("DyeWindow", true)
        WindowSetShowing ("ItemWindow", true)
        WindowClearAnchors (b)

        local B = x[1][5] - (A / 2 - PP.settings.windows["main"].height / 2)
        WindowAddAnchor (b, x[1][1], x[1][3], x[1][2], x[1][4], B)
        WindowSetDimensions (b, PP.settings.windows["main"].width, PP.settings.windows["main"].height)
        WindowForceProcessAnchors (b)
        ButtonSetText (b.."TogglePickerBtn", L"Hide")

        PP.settings.windows["main"].minimized = false
    else
        WindowSetShowing ("DyeWindow", false)
        WindowSetShowing ("ItemWindow", false)
        WindowClearAnchors (b)

        local B = x[1][5] - (PP.settings.windows["main"].height / 2 - A / 2)
        WindowAddAnchor (b, x[1][1], x[1][3], x[1][2], x[1][4], B)
        WindowSetDimensions (b, PP.settings.windows["main"].width, A)
        WindowForceProcessAnchors (b)
        ButtonSetText (b.."TogglePickerBtn", L"Show")
        PP.settings.windows["main"].minimized = true
    end
end

function PP.DyeWindowPopulateDisplay ()

    if (not DyeWindowList.PopulatorIndices)
    then

        if (debug_mode)
        then
            d("DyeWindowList: List was empty")
        end

        return

    end

    for index, value in ipairs (DyeWindowList.PopulatorIndices)
    do
        local E = "DyeWindow"
        local F = E.."ListRow"..index
        local dye = PP.DyeData[value]

        WindowSetTintColor (F.."Color", dye.DiffuseRed, dye.DiffuseGreen, dye.DiffuseBlue)
        WindowSetAlpha (F.."Color", dye.DiffuseIntensity)
        LabelSetText (F.."Name", towstring (dye.Name))
        LabelSetText (F.."Count", towstring (dye.Count))

        PP.UpdateListRow (value, F)
    end

end

function PP.UpdateListRow (D, F)

    F = F or nil

    if (D == PP.selectedDyeIndex)
    then
        WindowSetTintColor (F.."Background", 200, 200, 200)
        WindowSetAlpha (F.."Background", 0.4)
        WindowSetTintColor ("DyeWindowSelectedDyeColor", PP.DyeData[PP.selectedDyeIndex].DiffuseRed, PP.DyeData[PP.selectedDyeIndex].DiffuseGreen, PP.DyeData[PP.selectedDyeIndex].DiffuseBlue)
        WindowSetAlpha ("DyeWindowSelectedDyeColor", PP.DyeData[PP.selectedDyeIndex].DiffuseIntensity / 2)
        LabelSetText ("DyeWindowSelectedDyeName", towstring (PP.DyeData[PP.selectedDyeIndex].Name))
        LabelSetText("DyeWindowSelectedDyeCount", towstring(PP.DyeData[PP.selectedDyeIndex].Count))
    else
        WindowSetAlpha(F.."Background", 0)
    end

end

function PP.UpdateDyeList () 

    local H = function (I, J, K, M)

        direction = direction or false

        local N = {}

        for f, g in pairs (I)
        do
            table.insert (N, { f, g[J] })
        end

        if (not M)
        then
            table.sort (N, function (O, P) return O[2] < P[2] end)
        else
            table.sort (N, function (O, P) return O[2] > P[2] end)
        end

        for r, s in pairs (N)
        do
            table.insert (K, s[1])
        end

    end

    local function Q (R, S)

        if (type (R) ~='table')
        then
            return R
        end

        if (S and S[R])
        then
            return S[R]
        end

        local p = S or {}
        local T = setmetatable ({}, getmetatable (R))
        p[R] = T

        for f, g in pairs (R)
        do
            T[Q (f, p)] = Q(g, p)
        end

        return T

    end

    PP.DyeDataVisible = Q (PP.DyeData)

    if PP.settings.filter ~= ""
    then
        for f, g in pairs (PP.DyeDataVisible)
        do
            if (string.find (string.lower (tostring (g.Name)), PP.settings.filter))
            then
            else
                PP.DyeDataVisible[f] = nil
            end
        end
    end

    -- Hide diffuse or specular?
    local selected_type = ComboBoxGetSelectedMenuItem ("DyeWindowDyeTypeCombo")

    -- 3 == show all
    if (selected_type ~= 3)
    then
        for f, g in pairs (PP.DyeDataVisible)
        do
            if (g.Type == selected_type)
            then
            else
                PP.DyeDataVisible[f] = nil
            end
        end
    end



    local U = {}
    local V =
    {
        [1] = function ()
            H (PP.DyeDataVisible, "ID", U)
            --[[for r, s in pairs (PP.DyeDataVisible)
            do
                table.insert (U, r)
            end]]
        end,

        [2] = function ()
            H (PP.DyeDataVisible, "Name", U)
        end,

        [3] = function ()
            H (PP.DyeDataVisible, "Count", U, true)
        end,

        [4] = function ()
            for r, s in pairs (PP.DyeDataVisible)
            do
                table.insert (U, 1, r)
            end
        end
    }

    local W = V[ComboBoxGetSelectedMenuItem ("DyeWindowDyeOrderCombo")]

    if (W)
    then
        W ()
    else
        V[1] ()
    end

    ListBoxSetDisplayOrder ("DyeWindowList", U)

end

function PP.UpdateDyeFilter ()

    PP.settings.filter = string.lower (tostring (TextEditBoxGetText ("DyeWindowFilterEditBox")))

    PP.UpdateDyeList ()

end

function PP.SelectDye ()

    local window_id = WindowGetId (SystemData.MouseOverWindow.name)

    PP.selectedDyeIndex = ListBoxGetDataIndex ("DyeWindowList", window_id)

    local E = "DyeWindow"

    for index, value in ipairs (DyeWindowList.PopulatorIndices)
    do
        local window_name_list_row = E.."ListRow"..index
        PP.UpdateListRow (value, window_name_list_row)
    end

end

function PP.UpdateItemSlots ()

    local equipment = GetEquipmentData ()
    local h = "ItemWindow"

    for item_index, item in ipairs (PP.settings.items)
    do
        local _ = 0

        if item.slot ~= 15 and equipment[item.slot].iconNum ~= 0
        then
            _ = equipment[item.slot].iconNum
        else
            _ = CharacterWindow.EquipmentSlotInfo[item.iconNum].iconNum
        end

        local texture_name, texture_x, texture_y = GetIconData (_)
        DynamicImageSetTexture (h.."EquipmentSlot"..item.slot.."IconBase", texture_name, texture_x, texture_y)
        WindowSetTintColor (h.."EquipmentSlot"..item.slot.."IconPri", PP.settings.items_defaults.primary.r, PP.settings.items_defaults.primary.g, PP.settings.items_defaults.primary.b)
        WindowSetAlpha (h.."EquipmentSlot"..item.slot.."IconPri", PP.settings.items_defaults.primary.a)
        WindowSetTintColor (h.."EquipmentSlot"..item.slot.."IconSec", PP.settings.items_defaults.secondary.r, PP.settings.items_defaults.secondary.g, PP.settings.items_defaults.secondary.b)
        WindowSetAlpha (h.."EquipmentSlot"..item.slot.."IconSec", PP.settings.items_defaults.secondary.a)
    end

    PP.UpdateItemDyes ()

end

function PP.UpdateItemDyes ()

    local b = "ItemWindow"

    for item_index, item in ipairs (PP.settings.items)
    do
        local a1 = b.."EquipmentSlot"..item.slot

        if (item.dyes.primary == nil)
        then
            WindowSetTintColor (a1 .."IconPri", PP.settings.items_defaults.primary.r, PP.settings.items_defaults.primary.g, PP.settings.items_defaults.primary.b)
            WindowSetAlpha (a1 .."IconPri", PP.settings.items_defaults.primary.a)
        else
            WindowSetTintColor (a1 .."IconPri", PP.DyeData[item.dyes.primary].DiffuseRed, PP.DyeData[item.dyes.primary].DiffuseGreen, PP.DyeData[item.dyes.primary].DiffuseBlue)
            WindowSetAlpha (a1 .."IconPri", PP.DyeData[item.dyes.primary].DiffuseIntensity)
        end

        if (item.dyes.secondary == nil)
        then
            WindowSetTintColor (a1 .."IconSec", PP.settings.items_defaults.secondary.r, PP.settings.items_defaults.secondary.g, PP.settings.items_defaults.secondary.b)
            WindowSetAlpha (a1 .."IconSec", PP.settings.items_defaults.secondary.a)
        else
            WindowSetTintColor (a1 .."IconSec", PP.DyeData[item.dyes.secondary].DiffuseRed, PP.DyeData[item.dyes.secondary].DiffuseGreen, PP.DyeData[item.dyes.secondary].DiffuseBlue)
            WindowSetAlpha (a1 .."IconSec", PP.DyeData[item.dyes.secondary].DiffuseIntensity)
        end
    end

end

function PP.ItemSlotMouseOver ()

    local a2 = WindowGetId (SystemData.ActiveWindow.name)
    local a3 = PP.toolTips.items[a2]
    local a4 = Tooltips.COLOR_HEADING

    if a2 == 15 or CharacterWindow.equipmentData[a2].id == 0
    then
        a4 = Tooltips.COLOR_ITEM_DEFAULT_GRAY
    else
        a3 = a3 ..L" : "..CharacterWindow.equipmentData[a2].name

        if PP.ItemIsDyable (CharacterWindow.equipmentData[a2])
        then
        else
            a3 = a3 ..L"\n\n"..GetString (StringTables.Default.TEXT_CANNOT_DYE_ITEM)
            a4 = Tooltips.COLOR_FAILS_REQUIREMENTS
        end
    end

    for z, Z in ipairs (PP.settings.items)
    do
        if Z.slot == a2 then

            local a5 = L""

            if Z.dyes.primary ~= nil and Z.dyes.secondary ~= nil
            then
                local a6 = GetDyeNameString (Z.dyes.primary)
                local a7 = GetDyeNameString (Z.dyes.secondary)
                a5 = GetStringFormat (StringTables.Default.TEXT_TWO_DYE_COLOR, { a6, a7 })

            elseif Z.dyes.primary~=nil
            then
                local a8 = GetDyeNameString (Z.dyes.primary)
                a5 = GetStringFormat (StringTables.Default.TEXT_ONE_DYE_COLOR, { a8 })

            elseif Z.dyes.secondary ~= nil
            then
                local a9 = GetDyeNameString (Z.dyes.secondary)
                a5 = GetStringFormat (StringTables.Default.TEXT_ONE_DYE_COLOR, { a9 })

            end

            a3 = a3 ..L"\n\n"..a5

        end
    end

    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, a3)
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
    Tooltips.SetTooltipColorDef (1, 1, a4)
    Tooltips.Finalize ()

end

function PP.ItemSlotLMouse ()

    PP.SetItemDye (true)

end

function PP.ItemSlotRMouse ()

    PP.SetItemDye (false)

end

function PP.SetItemDye (aa)

    local a2 = WindowGetId (SystemData.ActiveWindow.name)
    local ab = aa and 'primary' or 'secondary'

    for z, Z in ipairs (PP.settings.items)
    do
        if a2 == Z.slot
        then
            if PP.settings.items[z].dyes[ab] == nil or PP.settings.items[z].dyes[ab] ~= PP.selectedDyeIndex
            then
                PP.settings.items[z].dyes[ab] = PP.selectedDyeIndex
            else
                PP.settings.items[z].dyes[ab] = nil
            end
        end
    end

    PP.UpdateItemDyes ()
    PP.ItemSlotMouseOver ()
    PP.PreviewDyes ()
end

function PP.ResetPreviewDyes ()

    if PP.settings.persistent == false
    then
        RevertAllDyePreview ()
    end
end

function PP.PreviewDyes ()

    PP.ResetPreviewDyes ()

    local ac = 0
    local ad = 0

    for z, Z in ipairs (PP.settings.items)
    do
        if Z.slot == 15
        then
            ac = Z.dyes.primary ~= nil and Z.dyes.primary or ac
            ad = Z.dyes.secondary ~= nil and Z.dyes.secondary or ad
        end
    end

    for z, Z in ipairs (PP.settings.items)
    do
        local ae = 0
        local af = 0

        if Z.slot ~= 15
        then
            local ae = ac ~= 0 and ac or CharacterWindow.equipmentData[Z.slot].dyeTintA
            local af = ad ~= 0 and ad or CharacterWindow.equipmentData[Z.slot].dyeTintB

            if Z.dyes.primary ~= nil
            then
                ae = Z.dyes.primary
            end

            if Z.dyes.secondary ~= nil
            then
                af = Z.dyes.secondary
            end

            DyeMerchantPreview (GameData.ItemLocs.EQUIPPED, Z.slot, ae, af)
        end
    end
end

function PP.ItemIsDyable (ag)

    local ah = GetDyeTintMasks (ag.id)

    return ag.flags[GameData.Item.EITEMFLAG_DYE_ABLE] == true and ah ~= GameData.TintMasks.NONE and not ag.broken

end

function PP.ItemIsBleachable (ag)

    return UseItemTargeting.ItemIsDyable (ag) and (ag.dyeTintA ~= 0 or ag.dyeTintB ~= 0)

end