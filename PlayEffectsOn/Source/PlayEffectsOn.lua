--------------------------------------------------------------------------------
-- PlayEffectsOn
--
-- A button to quickly and easily change the 'Play ability effects on' setting.
-- Right click on the button to bring up the menu.
--------------------------------------------------------------------------------

if not PlayEffectsOn then
  PlayEffectsOn = {}
end

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- DO NOT MODIFY. The values match the client's internal values.
local MODE_NONE    = 1
local MODE_SELF    = 2
local MODE_PARTY   = 3
local MODE_WARBAND = 4
local MODE_ALL     = 5

-- Shortened names for convenience.
local PERF_CUSTOM_1 = SystemData.Settings.Performance.PERF_LEVEL_CUSTOM1
local PERF_CUSTOM_2 = SystemData.Settings.Performance.PERF_LEVEL_CUSTOM2

-- The add-on's UI window names.
local WINDOW_NAME_MAIN = "PlayEffectsOn_Main"

--------------------------------------------------------------------------------
-- Internal Functions
--------------------------------------------------------------------------------

local function GetMode ()

  local perf = SystemData.Settings.Performance.perfLevel

  if (perf == PERF_CUSTOM_1) then
    return SystemData.Settings.Performance["custom1"]["abilityEffects"]

  elseif (perf == PERF_CUSTOM_2) then
    return SystemData.Settings.Performance["custom2"]["abilityEffects"]

  else
    return nil

  end

end

local function SetMode (mode)

  local perf = SystemData.Settings.Performance.perfLevel

  if (perf == PERF_CUSTOM_1) then
    SystemData.Settings.Performance["custom1"]["abilityEffects"] = mode

  elseif (perf == PERF_CUSTOM_2) then
    SystemData.Settings.Performance["custom2"]["abilityEffects"] = mode

  else
    TextLogAddEntry ("Chat", 0, L"PlayEffectsOn: Unable to change the setting as you are not using a custom video performance option.")

  end

  -- Broadcast the event anyway as it'll force a refresh of the PlayEffectsOn UI.
  BroadcastEvent (SystemData.Events.USER_SETTINGS_CHANGED)

end

local function UpdateUI ()

  local mode = GetMode ()

  if (mode == MODE_NONE) then
    DynamicImageSetTexture (WINDOW_NAME_MAIN, "PlayEffectsOn_Texture_None", 0, 0)

  elseif (mode == MODE_SELF) then
    DynamicImageSetTexture (WINDOW_NAME_MAIN, "PlayEffectsOn_Texture_Self", 0, 0)

  elseif (mode == MODE_PARTY) then
    DynamicImageSetTexture (WINDOW_NAME_MAIN, "PlayEffectsOn_Texture_Party", 0, 0)

  elseif (mode == MODE_WARBAND) then
    DynamicImageSetTexture (WINDOW_NAME_MAIN, "PlayEffectsOn_Texture_Warband", 0, 0)

  elseif (mode == MODE_ALL) then
    DynamicImageSetTexture (WINDOW_NAME_MAIN, "PlayEffectsOn_Texture_All", 0, 0)

  else
    DynamicImageSetTexture (WINDOW_NAME_MAIN, "PlayEffectsOn_Texture_Error", 0, 0)

  end

end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

function PlayEffectsOn.OnInitialize ()

  CreateWindow (WINDOW_NAME_MAIN, true)

  RegisterEventHandler (SystemData.Events.USER_SETTINGS_CHANGED, "PlayEffectsOn.OnUserSettingsChanged")

  -- Fake the event call to set the initial UI state.
  PlayEffectsOn.OnUserSettingsChanged ()

  local mods = ModulesGetData ()

  for _, mod in ipairs (mods) do
    if (mod.name == "PlayEffectsOn") then
      TextLogAddEntry ("Chat", 0, L"<icon00057> PlayEffectsOn " .. towstring (mod.version) .. L" initialized.")
      return
    end
  end

end

function PlayEffectsOn.OnRButtonUp ()

  -- If the two params match then return a ticked box icon. If different then return an empty box icon.
  local function Checkbox (current_mode, menu_mode)

    if (current_mode == menu_mode) then
      return L"<icon00057> "
    else
      return L"<icon00058> "
    end

  end

  local function Option (value)
    return function () SetMode (value) end
  end

  local mode = GetMode ()

  EA_Window_ContextMenu.CreateContextMenu (
    SystemData.MouseOverWindow.name,
    EA_Window_ContextMenu.CONTEXT_MENU_1,
    GetStringFromTable ("UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_ON) .. L"..."
  )

  -- Params for AddMenuItem: text, callback, is_disabled?, close_on_click?

  EA_Window_ContextMenu.AddMenuItem (
    Checkbox (mode, MODE_NONE) .. GetStringFromTable ("UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_NONE) .. L" (0)",
    Option (MODE_NONE),
    false,
    true)

  EA_Window_ContextMenu.AddMenuItem (
    Checkbox (mode, MODE_SELF) .. GetStringFromTable ("UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_SELF) .. L" (1)",
    Option (MODE_SELF),
    false,
    true)

  EA_Window_ContextMenu.AddMenuItem (
    Checkbox (mode, MODE_PARTY) .. GetStringFromTable ("UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_PARTY) .. L" (6)",
    Option (MODE_PARTY),
    false,
    true)

  EA_Window_ContextMenu.AddMenuItem (
    Checkbox (mode, MODE_WARBAND) .. GetStringFromTable ("UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_WARBAND) .. L" (24)",
    Option (MODE_WARBAND),
    false,
    true)

  EA_Window_ContextMenu.AddMenuItem (
    Checkbox (mode, MODE_ALL) .. GetStringFromTable ("UserSettingsStrings", StringTables.UserSettings.PERFORMANCE_ABILITY_EFFECTS_ALL) .. L" (*)",
    Option (MODE_ALL),
    false,
    true)

  EA_Window_ContextMenu.Finalize ()

end

function PlayEffectsOn.OnUserSettingsChanged ()

  UpdateUI ()

end
