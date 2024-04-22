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
- keyframes for each char: [idle, pre_attack, post_attack, taking_damage, defended, dodged, parry, hurt]
- to make more interactive and have decisions - add parry and defend on oppenent turn for the player. proly not for NPCs

## TODOs

need a bare bones full character sheet with all 6 keyframes. -- proly just a stick figure placeholder art.

then design various systems.
- the turn base system with perfect parry, parry, and defense ability on enemy turn
- hp and stamina systems
- item drop system
- inventory system

that all is the core, if its fun, then add more systems for rogue lite progression systems
