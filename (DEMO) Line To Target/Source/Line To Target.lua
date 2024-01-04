local WINDOW_LINE = "LTT_Line"
local WINDOW_LINE_DI = "LTT_Line_DynamicImage"
local WINDOW_TEST = "LTT_Test"

local target_object_id = 0

local scroll_pixels_current = 0
local scroll_pixels_max = 62      -- width of the texture
local scroll_pixels_rate = 62     -- pixels per second

function LTT_OnInitialize ()

  CreateWindow (WINDOW_LINE, true)
  CreateWindow (WINDOW_TEST, true)

  RegisterEventHandler (SystemData.Events.PLAYER_TARGET_UPDATED, "LTT_OnPlayerTargetUpdated")

end

function LTT_OnPlayerTargetUpdated (target_type, object_id, object_type)

  -- Only process changes to the friendly target.
  if (target_type ~= "selffriendlytarget")
  then
    return
  end

  target_object_id = object_id

end

function LTT_OnUpdate (time_delta_seconds)

  -- Reset the test window.
  WindowSetShowing (WINDOW_TEST, true)

  -- Calculate current UI scaling by trying to move the test window to the
  -- middle of the screen and seeing where it actually ends up. Scaling should
  -- be identical for the X and Y axis.
  WindowClearAnchors (WINDOW_TEST)
  WindowAddAnchor (WINDOW_TEST, "topleft", "Root", "topleft", SystemData.screenResolution.x / 2, SystemData.screenResolution.y / 2)

  local anchored_x = WindowGetScreenPosition (WINDOW_TEST)
  local scale_xy = (SystemData.screenResolution.x / 2) / anchored_x

  -- Early-out if there is no friendly target.
  if (target_object_id == 0)
  then
    WindowSetAlpha (WINDOW_LINE, 0.0)
    return
  end

  -- Early-out if the anchor point for the target object is off-screen.
  MoveWindowToWorldObject (WINDOW_TEST, target_object_id, 1.0)

  if (WindowGetShowing (WINDOW_TEST) == false)
  then
    WindowSetAlpha (WINDOW_LINE, 0.0)
    return
  end

  -- Scroll the texture. Needs to be done before rotation/etc.
  scroll_pixels_current = scroll_pixels_current + scroll_pixels_rate * time_delta_seconds
  scroll_pixels_current = math.fmod (scroll_pixels_current, scroll_pixels_max)

  -- We need to scroll towards the end point which in this case means negating
  -- the scroll value. If we were scrolling towards the start point then the
  -- positive value would be used.
  DynamicImageSetTexture (WINDOW_LINE_DI, "LTT_Texture_Line", -scroll_pixels_current, 0)

  -- The line will be drawn from the middle of the screen to the target point.
  -- The middle of the line is centered in the middle of the screen and the line
  -- will then be rotated around that point. To begin with, we need to calculate
  -- the middle of the screen, the line's anchor point, the rotation angle, and
  -- the distance between the start end end. Don't actually start moving the
  -- line window yet.
  local end_x, end_y = WindowGetScreenPosition (WINDOW_TEST)
  local start_x = SystemData.screenResolution.x / 2
  local start_y = SystemData.screenResolution.y / 2

  local diff_x = end_x - start_x
  local diff_y = end_y - start_y
  local length = math.sqrt ((diff_x * diff_x) + (diff_y * diff_y))

  local mid_x = start_x + (diff_x / 2)
  local mid_y = start_y + (diff_y / 2)

  local dir_x = diff_x / length
  local dir_y = diff_y / length

  local angle = math.atan2 (dir_y, dir_x) / (math.pi / 180)

  -- Rotate the image first around an un-anchored mid-point. Clearing the anchor
  -- of the parent seemed to fix a lot of weird rotation issues and allowed it
  -- to rotate in place. The length has to be scaled by scale_xy otherwise it
  -- will end up too show as WindowSetDimentions will modify the input based on
  -- the current UI scale. 14 is the height of the image/window.
  WindowClearAnchors (WINDOW_LINE)
  WindowSetDimensions (WINDOW_LINE_DI, length * scale_xy, 14)
  DynamicImageSetRotation (WINDOW_LINE_DI, angle)
  WindowSetAlpha (WINDOW_LINE, 1.0)

  -- Now the rotation is done, move the mid-point of the line window. Needs to
  -- be scaled as WindowAddAnchor also modifies the inputs based on UI scale
  -- which we do not want.
  WindowAddAnchor (WINDOW_LINE, "topleft", "Root", "topleft", mid_x * scale_xy, mid_y * scale_xy)

end