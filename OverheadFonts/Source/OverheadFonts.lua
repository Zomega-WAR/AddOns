local FONTS =
{
  "Stylized",
  "Simple",
  "alert_outline_giant",
  "alert_outline_gigantic",
  "alert_outline_half_giant",
  "alert_outline_half_gigantic",
  "alert_outline_half_huge",
  "alert_outline_half_large",
  "alert_outline_half_medium",
  "alert_outline_half_small",
  "alert_outline_half_tiny",
  "alert_outline_huge",
  "alert_outline_large",
  "alert_outline_medium",
  "alert_outline_small",
  "alert_outline_tiny",
  "chat_text",
  "chat_text_bold",
  "chat_text_no_outline",
  "chat_window_game_rating_text",
  "clear_default",
  "clear_large",
  "clear_large_bold",
  "clear_medium",
  "clear_medium_bold",
  "clear_small",
  "clear_small_bold",
  "clear_tiny",
  "default_heading",
  "default_medium_heading",
  "default_sub_heading",
  "default_sub_heading_no_outline",
  "default_text",
  "default_text_giant",
  "default_text_gigantic",
  "default_text_huge",
  "default_text_large",
  "default_text_no_outline",
  "default_text_small",
  "default_war_heading",
  "guild_MP_R_17",
  "guild_MP_R_19",
  "guild_MP_R_23",
  "heading_20pt_no_shadow",
  "heading_22pt_no_shadow",
  "heading_big_noshadow",
  "heading_default",
  "heading_default_no_shadow",
  "heading_huge",
  "heading_huge_no_shadow",
  "heading_huge_noshadow",
  "heading_large",
  "heading_large_noshadow",
  "heading_medium",
  "heading_medium_noshadow",
  "heading_rank",
  "heading_small_no_shadow",
  "heading_target_mouseover_name",
  "heading_tiny_no_shadow",
  "heading_unitframe_con",
  "heading_unitframe_large_name",
  "heading_zone_name_no_shadow",
  "journal_body",
  "journal_body_large",
  "journal_heading",
  "journal_heading_smaller",
  "journal_small_heading",
  "journal_sub_heading",
  "journal_text",
  "journal_text_huge",
  "journal_text_italic",
  "journal_text_large",
  "name_plate_names",
  "name_plate_names_old",
  "name_plate_titles",
  "name_plate_titles_old",
  "title_window_game_rating_text"
}

-- Controlled by Mythic's UI
local WINDOW_SETTINGS = SettingsWindowTabTargetting.contentsName .. "SettingsNames"

local WINDOW_SETTINGS_NAMES_COMBO = WINDOW_SETTINGS .. "FontCombo"
local WINDOW_SETTINGS_NAMES_LABEL = WINDOW_SETTINGS .. "Font"

-- Controlled by this add-on.
local WINDOW_SETTINGS_OTHER_COMBO = "OverheadFonts_OtherCombo"
local WINDOW_SETTINGS_OTHER_LABEL = "OverheadFonts_OtherLabel"


OverheadFonts = {}
OverheadFonts.SavedVariables = {}
OverheadFonts.SavedVariables.font_names_index = 1
OverheadFonts.SavedVariables.font_other_index = 1

function OverheadFonts.OnInitialize ()

  -- Step 1: resize the main frame from 310 to 330 pixels high as we are
  -- inserting a new label and combobox.
  WindowSetDimensions (WINDOW_SETTINGS, 500, 340)

  -- Step 2: Create and update the label for the guilds/titles fonts.
  CreateWindowFromTemplate (WINDOW_SETTINGS_OTHER_LABEL, "T_" .. WINDOW_SETTINGS_OTHER_LABEL, WINDOW_SETTINGS)
  LabelSetText (WINDOW_SETTINGS_OTHER_LABEL, L"Guilds/Titles Font")
  WindowSetShowing (WINDOW_SETTINGS_OTHER_LABEL, true)

  -- Step 3: Create the combobox for the guilds/titles fonts.
  CreateWindowFromTemplate (WINDOW_SETTINGS_OTHER_COMBO, "T_" .. WINDOW_SETTINGS_OTHER_COMBO, WINDOW_SETTINGS)
  WindowSetShowing (WINDOW_SETTINGS_OTHER_COMBO, true)

  -- Step 4: add localized versions of the "Stylized" and "Simple" names to the
  -- guilds/titles combo box. `SettingsWindowTabTargetting.Initialize` has
  -- already created these for the names combobox.
  ComboBoxAddMenuItem (WINDOW_SETTINGS_OTHER_COMBO, GetString (StringTables.Default.LABEL_NAMES_SETTING_FONT_STYLIZED))
  ComboBoxAddMenuItem (WINDOW_SETTINGS_OTHER_COMBO, GetString (StringTables.Default.LABEL_NAMES_SETTING_FONT_SIMPLE))

  -- Step 5: add all of the additional fonts provided by this addon to both
  -- combo boxes. We start from index 3 as index 1 and 2 are the stylized/simple
  -- fonts which have already been added.
  for font_index = 3, #FONTS
  do
    ComboBoxAddMenuItem (WINDOW_SETTINGS_NAMES_COMBO, StringToWString (FONTS[font_index]))
    ComboBoxAddMenuItem (WINDOW_SETTINGS_OTHER_COMBO, StringToWString (FONTS[font_index]))
  end

  -- Step 6: update the UI so that the saved fonts are selected.
  ComboBoxSetSelectedMenuItem (WINDOW_SETTINGS_NAMES_COMBO, OverheadFonts.SavedVariables.font_names_index)
  ComboBoxSetSelectedMenuItem (WINDOW_SETTINGS_OTHER_COMBO, OverheadFonts.SavedVariables.font_other_index)

  -- Step 7: now we need to push the checkbox UI elements down as currently the
  -- new guilds/titles combo box has been inserted. This is done by changing the
  -- anchor for the elements below from the names label to being below the
  -- guilds/titles label.
  WindowClearAnchors (WINDOW_SETTINGS .. "YourName")
  WindowAddAnchor (WINDOW_SETTINGS .. "YourName", "bottomleft", WINDOW_SETTINGS_OTHER_LABEL, "topleft", 0, 20)

  -- Apply the fonts.
  SettingsWindowTabTargetting.ApplyCurrent ()

end

-- Hook `SettingsWindowTabTargetting.ApplyCurrent`
local old_ApplyCurrent = SettingsWindowTabTargetting.ApplyCurrent

SettingsWindowTabTargetting.ApplyCurrent = function ()

  -- We have to save `new_font_names_index` as the call to `old_ApplyCurrent`
  -- afterwards will likely amend the combo box option.
  local new_font_names_index = ComboBoxGetSelectedMenuItem (WINDOW_SETTINGS_NAMES_COMBO)
  local new_font_other_index = ComboBoxGetSelectedMenuItem (WINDOW_SETTINGS_OTHER_COMBO)

  -- We have to hook the entire handler for the settings tab, so call the
  -- original handler.
  old_ApplyCurrent ()

  -- Now we perform the font checks using the data saved at the start of this
  -- function. This is just some sanity checks to ensure the indices are valid.
  if not FONTS[new_font_names_index]
  then
    new_font_names_index = 1
  end

  if not FONTS[new_font_other_index]
  then
    new_font_other_index = 1
  end

  -- Update the UI with the validated indices. This is not done within the
  -- checks above as putting them here also handles the case where
  -- `old_ApplyCurrent` modified the names font index.
  ComboBoxSetSelectedMenuItem (WINDOW_SETTINGS_NAMES_COMBO, new_font_names_index)
  ComboBoxSetSelectedMenuItem (WINDOW_SETTINGS_OTHER_COMBO, new_font_other_index)

  -- Save the indices.
  OverheadFonts.SavedVariables.font_names_index = new_font_names_index
  OverheadFonts.SavedVariables.font_other_index = new_font_other_index

  -- Actually update the nameplate fonts.
  SettingsWindowTabTargetting.SetNameplateFont ()

end

-- Fully replace `SettingsWindowTabTargetting.SetNameplateFont`. No need to keep
-- track of the original function.
SettingsWindowTabTargetting.SetNameplateFont = function ()

  -- Validation checks. Inspired by the original version of this function.
  if not InterfaceCore.inGame or
     not FONTS[OverheadFonts.SavedVariables.font_names_index] or
     not FONTS[OverheadFonts.SavedVariables.font_other_index]
  then
      return
  end

  -- Determine which font to use for the names.
  local font_names

  -- Stylized
  if OverheadFonts.SavedVariables.font_names_index == 1 then
    font_names = "font_name_plate_names_old"

  -- Simple
  elseif OverheadFonts.SavedVariables.font_names_index == 2 then
    font_names = "font_name_plate_names"

  -- OverheadFonts custom font
  else
    font_names = "font_" .. FONTS[OverheadFonts.SavedVariables.font_names_index]

  end

  -- Determine which font to use for the guilds/titles.
  local font_other

  -- Stylized
  if OverheadFonts.SavedVariables.font_other_index == 1 then
    font_other = "font_name_plate_titles_old"

  -- Simple
  elseif OverheadFonts.SavedVariables.font_other_index == 2 then
    font_other = "font_name_plate_titles"

  -- OverheadFonts custom font
  else
    font_other = "font_" .. FONTS[OverheadFonts.SavedVariables.font_other_index]

  end

  -- Tell the client what fonts to use.
  SetNamesAndTitlesFont (font_names, font_other)

end

-- Hook `SettingsWindowTabTargetting.UpdateSettings`
local old_UpdateSettings = SettingsWindowTabTargetting.UpdateSettings

SettingsWindowTabTargetting.UpdateSettings = function ()

  -- Call the original function as that updates the settings for the entire tab.
  old_UpdateSettings ()
  
  -- Validation checks for the names font.
  if not FONTS[OverheadFonts.SavedVariables.font_names_index]
  then
    OverheadFonts.SavedVariables.font_names_index = 1
  end

  -- Validation checks for the guilds/titles font.
  if not FONTS[OverheadFonts.SavedVariables.font_other_index]
  then
    OverheadFonts.SavedVariables.font_other_index = 1
  end

  -- Update the UI with the chosen fonts.
  ComboBoxSetSelectedMenuItem (WINDOW_SETTINGS_NAMES_COMBO, OverheadFonts.SavedVariables.font_names_index)
  ComboBoxSetSelectedMenuItem (WINDOW_SETTINGS_OTHER_COMBO, OverheadFonts.SavedVariables.font_other_index)

end