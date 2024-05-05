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

then design various systems.
- the turn base system with perfect parry, parry, and defense ability on enemy turn
- hp and stamina systems
- item drop system
- inventory system

that all is the core, if its fun, then add more systems for rogue lite progression systems


focus on the core combat:
  should make it purely parry based
  remove player attack ability - just parry
    make combat a quick time event:
      make the enemy attack a combo of those tablet click games and resident evil quick time events where you have to click a certain button
        basically a chain of click here and click this button within a timeframe
        NOTE: ddr is also similar
      pool of turn damage distibution:
        Example: 100hp in damage pool for a round:
          if player fails quick time event and gets a 0%:
            no damage is redirected to npc. aka: player takes all the damage for the turn
          if player gets 50% 'good' in a quick time event:
            50% of damage is redirected to npc
          if player gets 100% 'good' in a quick time event:
            100% of damage is redirected to npc

focus on mobile or mac/pc w/ mouse/drawing_tablet and keyboard

this means we can get rid of the turn concept and basically just have the battle_scene as a backdrop to the game
the damage can occur after each action
  think of what the characters should do during all of this
  maybe they both go to the center of the screen and hit each other based on actions
    maybe it doesnt have to exactly match the actions, but just be a fight scene that leans one way or the other based on how the player is doing

different characters as npc would effect things like damage amount and time to act on each action
  Hilda - more damage and more time to react
  Marcella - 2 nodes at a time - each node is half standard damage with standard time to react to each
  spearwomen - standard damage and standard time to react (consider if less time makes this more balanced)

what do different characters as player choice do?
  Hilda - more HP, but comes at a slight reduction in time to react
  Marcella - less HP, but comes at a slight increase in time to react
  spearwomen - standard HP, with standard time to react

NOTE: consider configuring it to allow the player to adjust how much they get buttons/keys vs clicks
  could have a keyboard only present that also extends the keys used
  have a set of easy to choice presents for mobile, pc keyboard only, pc keyboard and mouse/drawing_tablet, pc no keyboard and mouse/drawing_tablet

