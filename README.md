# Sticker Book: Time Attack

## TODO:

### battle_scene

- Make the QTE event more strict; if a user fails a step in the QTE event; then they fail the event
- BUG: refactor health bar to be in 1 krita file - then rebalance the 4 quadrants - right now, it is off and gives the wrong impression in terms of damage (flipping the hp bar does this)
- BUG: finger event not registered on finger icon sometimes: has a bug on second finger if you key buttons instead - might be resolved if with the more strict event work
- Make the QTE event more granular; if a user completes 50% of event and doesnt give an invalid input; then 50% of damage is redirected
- Add a number hit splat (percentage based) on damage taking - will remove the need to explain class differences and what items do
- make mod items that are applied visually display a tween on the combat_unit
- make inventory items stackable
- save inventory and mods to AppState.data
- limit number of mods on a combat_unit to 4
- instead of modulate and disable prop adjustments - consider add_child and remove_child pattern on ui components

### general

- update pause_menu to be combined with options_menu in tabs
- update pause_menu to be a ui component that is overlayed on any scene with opacity down - this reduces the number of assets i have to make and removes the problems with switching scenes
- update settings page with control configuration for controller and keyboard
- update settings page with touch to button slider to determine likelyhood of 1 event versus the other

- On launch of game: track if a run was occurring, then pick up where the player left off

- diff ui flavors for controller vs keyboard and mouse vs mobile - OSHelper.is_mobile() will help here
- Add controller support (and tab support) on ui
- make pause menu accessible for mobile
- add music and sound effects
- update settings page with sliders for music and sound effects

- flesh out my theme for ui
- figure out how to run the tweens in parallel rather than using the separate tweens and taking the max timeout to this wait for all of them to finish
