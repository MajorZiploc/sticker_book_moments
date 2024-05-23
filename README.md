# Sticker Book: Time Attack

## TODO:

### level_map

- create node system - 4-6 nodes per level_map - rand enemy per node

### battle_scene

- Make the QTE event more granular; if a user completes 50% of event and doesnt give an invalid input; then 50% of damage is redirected
- make inventory items stackable

- BUG: refactor health bar to be in 1 krita file - then rebalance the 4 quadrants - right now, it is off and gives the wrong impression in terms of damage - (maybe use flipping instead of using left to right instead will fix this)
- Add a number hit splat (percentage based) on damage taking - will remove the need to explain class differences and what items do
- make mod items that are applied visually display a tween on the combat_unit

- Needed if number of buffs or debuffs goes above 4: limit number of mods on a combat_unit to 4
- Consider: instead of modulate and disable prop adjustments - consider add_child and remove_child pattern on ui components - or do visible toggling

### general

- MVP: reduce time per stage(opponent) by 0.5 seconds for each step to a min time of 3.5 seconds
- MVP: add name or majorziploc on the title_scene
- MVP: default app_state based on platform in title_scene
- MVP: mainly need on screen buttons for button qte events for mobile - OSHelper.is_mobile() will help here - make sure it doesnt overlap the qte area
- Add color wheel selector for all colors on character

- diff ui flavors for controller vs keyboard and mouse vs mobile
- add music and sound effects
- update settings page with sliders for music and sound effects

- update settings page with control configuration for controller and keyboard
- update settings page with touch to button slider to determine likelyhood of 1 event versus the other

- move option component into the tscn files (under $ui_root/overlay) rather than instantiate call but keep the instantiate fn call as an example
- create save slots (3 slots)
- on launch of game: track if a run was occurring, then pick up where the player left off

- add controller support (and tab support) on ui

- flesh out my theme for ui
- figure out how to run the tweens in parallel rather than using the separate tweens and taking the max timeout to this wait for all of them to finish
