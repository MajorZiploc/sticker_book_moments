# Sticker Book: Time Attack

## TODO:

### battle_scene

- Make the QTE event more strict; if a user fails a step in the QTE event; then they fail the event
- BUG: finger event has a bug on second finger if you key buttons instead - might be resolved if with the more strict event work
- Make the QTE event more granular; if a user completes 50% of event and doesnt give an invalid input; then 50% of damage is redirected
- Add a number hit splat on damage taking - will remove the need to explain class differences and what items do

### general

- finish inventory flow - also need to add side tabes like on feature/buff-and-debuff-draw for buffs and debuffs
- make inventory items stackable
- limit number of effects on a combat_unit to 5
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
