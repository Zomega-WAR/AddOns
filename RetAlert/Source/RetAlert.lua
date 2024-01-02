local alert_ability_id = 1450      -- Slayer: Retribution

local alert_active_duration = nil
local WINDOW_NAME = "RetAlert_Main"

--------------------------------------------------------------------------------
-- ADDON SETTINGS (SAVED BY THE CLIENT)
--------------------------------------------------------------------------------

RetAlert_Settings = {}
RetAlert_Settings.duration = 1.5       -- Seconds
RetAlert_Settings.window_alpha = 1.0   -- 0.0 = transparent, 1.0 = solid
RetAlert_Settings.enabled = true
RetAlert_Settings.sound_id = 1
RetAlert_Settings.window_layer = Window.Layers.POPUP

--------------------------------------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------------------------------------

local function RetAlert_Disable ()

  alert_active_duration = nil
  WindowSetAlpha (WINDOW_NAME, 0.0)

  UnregisterEventHandler (SystemData.Events.UPDATE_PROCESSED, "RetAlert_OnUpdate")
  UnregisterEventHandler (SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "RetAlert_OnWorldObjCombatEvent")

  RetAlert_Settings.enabled = false

end

local function RetAlert_Enable ()

  alert_active_duration = nil
  WindowSetAlpha (WINDOW_NAME, 0.0)

  RegisterEventHandler (SystemData.Events.UPDATE_PROCESSED, "RetAlert_OnUpdate")
  RegisterEventHandler (SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "RetAlert_OnWorldObjCombatEvent")

  RetAlert_Settings.enabled = true

end

local function RetAlert_LayoutEditor_Callback (edit_mode)

  if (edit_mode == LayoutEditor.EDITING_BEGIN)
  then

    WindowSetAlpha (WINDOW_NAME, RetAlert_Settings.window_alpha)

  elseif (edit_mode == LayoutEditor.EDITING_END)
  then

    RetAlert_Settings.window_alpha = WindowGetAlpha (WINDOW_NAME)

    alert_active_duration = nil
    WindowSetAlpha (WINDOW_NAME, 0.0)

  end

end

local function RetAlert_Trigger ()

  alert_active_duration = 0
  WindowSetAlpha (WINDOW_NAME, RetAlert_Settings.window_alpha)

  if (RetAlert_Settings.sound_id >= 0)
  then
    PlaySound (RetAlert_Settings.sound_id)
  end

end

--------------------------------------------------------------------------------
-- EVENTS
--------------------------------------------------------------------------------

function RetAlert_OnInitialize ()

  -- TODO: RetAlert_OnSlashCmd can probably be made local as it's passed/called by object rather than by name.
  LibSlash.RegisterSlashCmd ("retalert", RetAlert_OnSlashCmd)

  CreateWindow (WINDOW_NAME, true)
  WindowSetAlpha (WINDOW_NAME, 0.0)
  WindowSetLayer (WINDOW_NAME, RetAlert_Settings.window_layer)

  -- Internal window name, display name, description, allow resizing X, allow resizing Y, allow hiding, on-hide call-back.
  LayoutEditor.RegisterWindow (WINDOW_NAME, L"RetAlert", L"RetAlert", true, true, true, nil)
  LayoutEditor.RegisterEditCallback (RetAlert_LayoutEditor_Callback)

  if (RetAlert_Settings.enabled == true)
  then
    RetAlert_Enable ()
  end

end

function RetAlert_OnSlashCmd (text)

  local params = {}

  -- Build a list of each word in the slash text. The initial "retalert" is already removed by LibSlash.
  for param in text:gmatch ("%S+")
  do
    table.insert (params, param)
  end

  ----------------------------------------------------------------------------
  -- Duration
  ----------------------------------------------------------------------------

  if (params[1] == "duration")
  then
      
    local duration = tonumber (params[2])

    if (type (duration) ~= "number") or (duration < 0)
    then
      TextLogAddEntry ("Chat", 0, L"RetAlert: invalid value for alert duration: " .. towstring (params[2]))
      return
    end

    RetAlert_Settings.duration = duration
    TextLogAddEntry ("Chat", 0, L"RetAlert: alert duration changed to " .. towstring (RetAlert_Settings.duration) .. L" seconds.")

  ----------------------------------------------------------------------------
  -- Help
  ----------------------------------------------------------------------------

  elseif (params[1] == "help")
  then

    TextLogAddEntry ("Chat", 0, L"---------------------------------------------")
    TextLogAddEntry ("Chat", 0, L"/retalert")
    TextLogAddEntry ("Chat", 0, L"- Displays the current settings.")
    TextLogAddEntry ("Chat", 0, L"")
    TextLogAddEntry ("Chat", 0, L"/retalert duration #")
    TextLogAddEntry ("Chat", 0, L"- How long to show the alert window for. # is in seconds.")
    TextLogAddEntry ("Chat", 0, L"")
    TextLogAddEntry ("Chat", 0, L"/retalert help")
    TextLogAddEntry ("Chat", 0, L"- Displays a list of all RetAlert chat commands.")
    TextLogAddEntry ("Chat", 0, L"")
    TextLogAddEntry ("Chat", 0, L"/retalert layer #")
    TextLogAddEntry ("Chat", 0, L"- Sets which UI layer to show the alert window on. # can be: background, default, overlay, popup or secondary.")
    TextLogAddEntry ("Chat", 0, L"")
    TextLogAddEntry ("Chat", 0, L"/retalert off")
    TextLogAddEntry ("Chat", 0, L"- Disables the alert.")
    TextLogAddEntry ("Chat", 0, L"")
    TextLogAddEntry ("Chat", 0, L"/retalert on")
    TextLogAddEntry ("Chat", 0, L"- Enables the alert.")
    TextLogAddEntry ("Chat", 0, L"")
    TextLogAddEntry ("Chat", 0, L"/retalert sound")
    TextLogAddEntry ("Chat", 0, L"- Which UI sound effect to play. Set to -1 to disable sounds.")
    TextLogAddEntry ("Chat", 0, L"")
    TextLogAddEntry ("Chat", 0, L"/retalert test")
    TextLogAddEntry ("Chat", 0, L"- Trigger the alert. For testing purposes.")
    TextLogAddEntry ("Chat", 0, L"---------------------------------------------")

  ----------------------------------------------------------------------------
  -- Layer
  ----------------------------------------------------------------------------

  elseif (params[1] == "layer")
  then

    local layer = params[2]

        if (layer == "background") then RetAlert_Settings.window_layer = Window.Layers.BACKGROUND
    elseif (layer == "default")    then RetAlert_Settings.window_layer = Window.Layers.DEFAULT
    elseif (layer == "overlay")    then RetAlert_Settings.window_layer = Window.Layers.OVERLAY
    elseif (layer == "popup")      then RetAlert_Settings.window_layer = Window.Layers.POPUP
    elseif (layer == "secondary")  then RetAlert_Settings.window_layer = Window.Layers.SECONDARY
    else
      TextLogAddEntry ("Chat", 0, L"RetAlert: invalid window layer. Valid options are: background, default, overlay, popup and secondary.")
    end

    WindowSetLayer (WINDOW_NAME, RetAlert_Settings.window_layer)
    TextLogAddEntry ("Chat", 0, L"RetAlert: alert window layer changed to: " .. towstring (layer))

  ----------------------------------------------------------------------------
  -- Off
  ----------------------------------------------------------------------------

  elseif (params[1] == "off")
  then

    if (RetAlert_Settings.enabled == true)
    then
      RetAlert_Disable ()
      TextLogAddEntry ("Chat", 0, L"RetAlert: the alert is turned off.")
    else
      TextLogAddEntry ("Chat", 0, L"RetAlert: the alert is already turned off.")
    end

  ----------------------------------------------------------------------------
  -- On
  ----------------------------------------------------------------------------

  elseif (params[1] == "on")
  then

    if (RetAlert_Settings.enabled == false)
    then
      RetAlert_Enable ()
      TextLogAddEntry ("Chat", 0, L"RetAlert: the alert is turned on.")
    else
      TextLogAddEntry ("Chat", 0, L"RetAlert: the alert is already turned on.")
    end

  ----------------------------------------------------------------------------
  -- Sound
  ----------------------------------------------------------------------------

  elseif (params[1] == "sound")
  then

    local sound_id = tonumber (params[2])

    if (type (sound_id) ~= "number")
    then
      TextLogAddEntry ("Chat", 0, L"RetAlert: invalid value for sound ID: " .. towstring (params[2]))
      return
    end

    RetAlert_Settings.sound_id = sound_id
    TextLogAddEntry ("Chat", 0, L"RetAlert: alert sound ID changed to " .. towstring (RetAlert_Settings.sound_id))

  ----------------------------------------------------------------------------
  -- Test
  ----------------------------------------------------------------------------

  elseif (params[1] == "test")
  then

    if (RetAlert_Settings.enabled == true)
    then
      RetAlert_Trigger ()
      TextLogAddEntry ("Chat", 0, L"RetAlert: manually triggered.")
    else
      TextLogAddEntry ("Chat", 0, L"RetAlert: cannot test the alert when disabled.")
    end

  ----------------------------------------------------------------------------
  -- ???
  ----------------------------------------------------------------------------

  else

    TextLogAddEntry ("Chat", 0, L"RetAlert: missing or unknown command. Valid options are: duration, help, layer, off, on, sound and test.")

  end

end

function RetAlert_OnShutdown ()
end

function RetAlert_OnUpdate (time_delta)

  if (alert_active_duration == nil)
  then
    return
  end

  alert_active_duration = alert_active_duration + time_delta

  -- If enough time has passed then stop the alert.
  if (alert_active_duration >= RetAlert_Settings.duration)
  then
    WindowSetAlpha (WINDOW_NAME, 0.0)
    alert_active_duration = nil
  end

end

function RetAlert_OnWorldObjCombatEvent (world_object_id, ability_value, ability_type, ability_id)

  -- Only check combat events that happen to the player.
  if (world_object_id ~= GameData.Player.worldObjNum)
  then
    return
  end

  if (ability_id == alert_ability_id)
  then
    RetAlert_Trigger ()
  end

end
