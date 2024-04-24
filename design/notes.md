## Overview

stickers on a sticker book with turn based in rogue lite level scheme

2 main scenes:
  - battle_scene (sticker book background with sticker props)
  - maze_scene (auto generated levels) - basic maze with nodes that trigger encounters into battle_scene
  - end a maze_scene with a boss

1 vs 1 battles

items and buffs gotten from drops on beating enemies

## battle_scene details

- when char dies, peel the sticker off the sticker book and discard off screen
- no complex animations, just moving the sticker and using keyframes
- keyframes for each char - no deep animations
- to make more interactive and have decisions - add parry and defend on oppenent turn for the player. proly not for NPCs

### keyframes for each char

#### MVP

  - idle
  - pre_attack
  - post_attack
  - defensive/readied/prep for (counter|parry)

#### NOT MVP

  - taking_damage
  - dodged
  - parry
  - hurt

#### NOT MVP keyframe workarounds

  - taking_damage - pointy spark thing - prob red
  - dodged - shift sticker
  - parry - white spark
  - hurt - flash red

alternatively instead of shaders for all of the above, could use a small item like sticker that is a child sprite of the battle sprite to indicate hurt and stuff
  I like this idea ALOT, try this instead of shaders first

## TODOs

need a bare bones full character sheet with all 6 keyframes. -- proly just a stick figure placeholder art.

then design various systems.
- the turn base system with perfect parry, parry, and defense ability on enemy turn
- hp and stamina systems
- item drop system
- inventory system

that all is the core, if its fun, then add more systems for rogue lite progression systems
