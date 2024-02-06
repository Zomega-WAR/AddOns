AutoMark = {}

local enabled = true
local marker_array = {}
local WINDOW_NAME_TEST = "AutoMark_Tester"

local function CreateMarker (object_id, career_id)

  local window_name = "AutoMark_M" .. object_id

  CreateWindowFromTemplate (window_name, "T_AutoMark_Marker", "Root")
  WindowSetShowing (window_name, true)

  local career_icon_id = Icons.GetCareerIconIDFromCareerLine (career_id)
  local texture_name, texture_x, texture_y = GetIconData (career_icon_id)
  DynamicImageSetTexture (window_name .. "_Icon", texture_name, texture_x, texture_y)

  local marker = {}

  marker.object_id = object_id
  marker.window_name = window_name

  return marker

end

local function DestroyMarker (marker)

  DestroyWindow (marker.window_name)

end

function AutoMark.OnInitialize ()

  if (enabled == true)
  then
    RegisterEventHandler (SystemData.Events.PLAYER_TARGET_UPDATED, "AutoMark.OnPlayerTargetUpdated")
  end

  LibSlash.RegisterSlashCmd ("automark", AutoMark.OnSlashCommand)

  CreateWindow (WINDOW_NAME_TEST, true)

end

function AutoMark.OnPlayerTargetUpdated (target_type, object_id, object_type)

  -- Ignore friendly target changes.
  if (target_type == "selffriendlytarget")
  then
    return
  end

  -- Must be an enemy player.
  if (object_type ~= SystemData.TargetObjectType.ENEMY_PLAYER)
  then
    return
  end

  -- Ignore objects that have already been marked.
  for index = 1, #marker_array
  do
    if (marker_array[index].object_id == object_id)
    then
      return
    end
  end

  -- Create the marker.
	TargetInfo:UpdateFromClient ()

  local marker = CreateMarker (object_id, TargetInfo:UnitCareer (target_type))

  table.insert (marker_array, marker)

end

function AutoMark.OnSlashCommand (text)

  -- Delete all current markers.
  if (text == "clear")
  then

    for index = 1, #marker_array
    do
      DestroyMarker (marker_array[index])
    end

    marker_array = {}

  -- Stop tracking new targets.
  elseif (text == "off")
  then

    if (enabled == true)
    then
      enabled = false
      UnregisterEventHandler (SystemData.Events.PLAYER_TARGET_UPDATED, "AutoMark.OnPlayerTargetUpdated")
    end

    TextLogAddEntry ("Chat", 0, L"AutoMark is no longer tracking new enemies. To clear existing marks, type \"/automark clear\".")

  -- Start tracking new enemy players.
  elseif (text == "on")
  then

    if (enabled == false)
    then
      enabled = true
      RegisterEventHandler (SystemData.Events.PLAYER_TARGET_UPDATED, "AutoMark.OnPlayerTargetUpdated")
    end

    TextLogAddEntry ("Chat", 0, L"AutoMark is now tracking new enemy players.")

  -- Invalid slash command.
  else

    TextLogAddEntry ("Chat", 0, L"Invalid option. Valid options are \"clear\", \"off\" and \"on\".")

  end

end

function AutoMark.OnUpdate (delta_time_seconds)

  -- For very fast erasing of markers from the array we iterate over the array
  -- backwards and use the "swap and pop" idiom (that might be a C++ term...) to
  -- remove markers for objects that no longer exist.

  -- These have been made local for performance reasons as they might get called
  -- a LOT depending on how many markers currently exist.
  local MoveWindowToWorldObject = MoveWindowToWorldObject
  local table_remove = table.remove
  local WindowAddAnchor = WindowAddAnchor
  local WindowClearAnchors = WindowClearAnchors
  local WindowGetScreenPosition = WindowGetScreenPosition
  local WindowGetShowing = WindowGetShowing
  local WindowSetAlpha = WindowSetAlpha
  local WindowSetShowing = WindowSetShowing

  --[[

  If a window is attached to a world object then there is a bug that means
  sometimes the window is not deleted when the world object vanishes. To work
  around that, we do all of the checks and movement manually using the
  MoveWindowToWorldObject function.
  
  That function has 3 outcomes depending on whether the world object exists and
  if it's on-screen or not:
  
  1) The window is hidden. This means the world object exists but is off-screen.
  
  2) The window remains visible and moves. This means the world object exists
     and is on-screen.
  
  3) The window remains visible but does not move. This means: a) the world
     object exists and is located at the exact position that the window was
     originally located at, or b) the world object no longer exists. To rule out
     a), we then repeat part of the process with a different starting position
     for the window to see if it now moves. If so then 2) applies, if not then
     3b) applies.

  To do the tests, we use the most basic window possible - a window with no size
  and no child windows.

  ]]

  -- Reset the visibility of the test window.
  WindowSetShowing (WINDOW_NAME_TEST, true)

  -- The first reset point is the middle of the screen.
  local reset1_anchor_x = SystemData.screenResolution.x / 2
  local reset1_anchor_y = SystemData.screenResolution.y / 2

  -- Move the test window to the reset point and see where it actually ends up after UI scaling/etc.
  WindowClearAnchors (WINDOW_NAME_TEST)
  WindowAddAnchor (WINDOW_NAME_TEST, "topleft", "Root", "topleft", reset1_anchor_x, reset1_anchor_y)

  local reset1_actual_x, reset1_actual_y = WindowGetScreenPosition (WINDOW_NAME_TEST)

  -- The second reset point (for "3b)" in the blurb above needs to be different
  -- from the first reset point.
  local reset2_anchor_x = reset1_anchor_x + 10
  local reset2_anchor_y = reset1_anchor_y + 10

  -- Move the test window to the reset point and see where it actually ends up after UI scaling/etc.
  WindowClearAnchors (WINDOW_NAME_TEST)
  WindowAddAnchor (WINDOW_NAME_TEST, "topleft", "Root", "topleft", reset2_anchor_x, reset2_anchor_y)

  local reset2_actual_x, reset2_actual_y = WindowGetScreenPosition (WINDOW_NAME_TEST)

  -- Now test every single marker to see if the world object it is linked to
  -- still exists. If it does, update the marker accordingly. If not then delete
  -- the marker.
  for index = #marker_array, 1, -1 do

    local marker = marker_array[index]
    local object_id = marker.object_id

    -- Reset the test window to the initial test position, and then try to move
    -- it to the world object.

    WindowClearAnchors (WINDOW_NAME_TEST)
    WindowAddAnchor (WINDOW_NAME_TEST, "topleft", "Root", "topleft", reset1_anchor_x, reset1_anchor_y)

    MoveWindowToWorldObject (WINDOW_NAME_TEST, object_id, 1.0)

    -- Check 1: If the test window is now invisible then this means that the
    -- world object exists but is currently off-screen.
    if (WindowGetShowing (WINDOW_NAME_TEST) == false)
    then

      -- Reset the test window's visibility ready for the next object.
      WindowSetShowing (WINDOW_NAME_TEST, true)

      -- Hide the marker window.
      WindowSetAlpha (marker.window_name, 0.0)

      -- Move on to the next marker.
      continue

    end

    -- Check 2: Check to see if MoveWindowToWorldObject caused the test window
    -- to move. If it did then that means that the world object exists and is
    -- on-screen.
    local object_x, object_y = WindowGetScreenPosition (WINDOW_NAME_TEST)

    if (reset1_actual_x ~= object_x) or (reset1_actual_y ~= object_y)
    then

      -- Move and show the marker.
      MoveWindowToWorldObject (marker.window_name, object_id, 1.0)
      WindowSetAlpha (marker.window_name, 1.0)

      -- Move on to the next marker.
      continue
  
    end

    -- Test with the second reset point to see if the window now moves.
    WindowClearAnchors (WINDOW_NAME_TEST)
    WindowAddAnchor (WINDOW_NAME_TEST, "topleft", "Root", "topleft", reset2_anchor_x, reset2_anchor_y)

    MoveWindowToWorldObject (WINDOW_NAME_TEST, object_id, 1.0)

    object_x, object_y = WindowGetScreenPosition (WINDOW_NAME_TEST)

    -- Check 3a: if the window has now moved then the world object must exist.
    if (reset2_actual_x ~= object_x) or (reset2_actual_y ~= object_y)
    then

      -- Move and show the marker.
      MoveWindowToWorldObject (marker.window_name, object_id, 1.0)
      WindowSetAlpha (marker.window_name, 1.0)

      -- Move on to the next marker.
      continue

    end

    -- "Check" 3b: at this point, we know the world object no longer exists. The
    -- marker can be destroyed and then removed from the array using the "swap
    -- and pop" idiom.
    DestroyMarker (marker)

    marker_array[index] = marker_array[#marker_array]
    table_remove (marker_array)

  end

end