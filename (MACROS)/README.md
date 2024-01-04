# Macros

Useful macros that don't really deserve their own addon. The macros are one-liners so be sure to copy everything if the text has been wrapped to multiple lines.

## Disable/enable the combat log

This macro disables a lot of combat log entries (hits, healing, kills, etc) which can result in a big performance increase during large fights. There is also an addon that disables the log by default named "DisableCombatLog" in this repository.

- Disable: `/script TextLogSetEnabled ("Combat", false)`
- Enable: `/script TextLogSetEnabled ("Combat", true)`

## Instant war report

This macro will instantly teleport you using the war report feature. The event you are teleported to is the primary event that would appear at the top of the tier 4 page.

- `/script CurrentEventsUpdate() EA_Window_CurrentEvents.SetCurrentTier(4) CurrentEventsJumpToEvent(WindowGetId("EA_Window_CurrentEventsHeadlineEvent"))`

## Scenario group changer

Sometimes the UI can bug out - especially with an addon conflict - and you are not able to bring up the window to change groups during scenarios (including city sieges). This macro will display the window:

- `/script WindowSetShowing ("ScenarioGroupWindow", true)`

## Scenario join window

Sometimes you need to bring up the scenario join/accept window if it bugged out and closed for whatever reason. This macro will display the window so you can then try to join a scenario. Not guaranteed to actually let you join the scenario as that still depends on whether the server will let you in.

- `/script BroadcastEvent (SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW)`

## Scenario scoreboard

Brings up the scenario scoreboard and stats window if you have forgotten to bind it or it's bugged out due to an addon conflict.

- `/script WindowSetShowing ("ScenarioSummaryWindow", true)`
