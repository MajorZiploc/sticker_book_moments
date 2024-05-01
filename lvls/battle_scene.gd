extends Node2D

class CombatUnit:
  var char: BattleChar;
  var path_follow: PathFollow2D;
  func _init(char, path_follow):
    self.char = char;
    self.path_follow = path_follow;

@onready var player = CombatUnit.new($path_left/path_follow/battle_char, $path_left/path_follow);
@onready var npc = CombatUnit.new($path_right/path_follow/battle_char, $path_right/path_follow);

@export var is_player_turn = true;

var attack_shift = Vector2(175, 0);
var parry_attempted = false;
var parry_attempted_ratio = 0.0;
var min_parry_ratio = 0.5;
var max_parry_ratio = 1.0;

# Called when the node enters the scene tree for the first time.
func _ready():
  player.char.update_sprite_texture("res://art/my/chars/dual_hybrid.png");
  npc.char.update_sprite_texture("res://art/my/chars/two_handed_axer.png");
  player.char.to_player();
  player.char.idle();
  npc.char.idle();

func full_round(attacker: CombatUnit, defender: CombatUnit):
  await attack_sequence(attacker, defender);
  is_player_turn = !is_player_turn;
  await attack_sequence(defender, attacker);

func attack_sequence(attacker: CombatUnit, defender: CombatUnit):
  attacker.char.preatk();
  defender.char.readied();
  var tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1).set_trans(Tween.TRANS_EXPO);
  await tween.finished;
  attacker.char.postatk();
  var damage_taker = defender;
  # NOTE: this is actually the enemy turn if this is true at this point
  if is_player_turn:
    if parry_attempted and parry_attempted_ratio >= min_parry_ratio and parry_attempted_ratio <= max_parry_ratio:
      damage_taker = attacker;
      defender.char.postatk();
  damage_taker.char.take_damage(1);
  # HACK: to let the postatk frame show for a second
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1);
  await tween.finished;
  attacker.char.idle();
  defender.char.idle();
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 0, 1).set_trans(Tween.TRANS_CUBIC);
  return await tween.finished;

func _on_attack_pressed():
  if is_player_turn and player.path_follow.progress_ratio == 0 and npc.path_follow.progress_ratio == 0:
    is_player_turn = !is_player_turn;
    parry_attempted = false;
    parry_attempted_ratio = 0.0;
    full_round(player, npc);
  elif !parry_attempted:
    print('npc.path_follow.progress_ratio');
    print(npc.path_follow.progress_ratio);
    parry_attempted = true;
    parry_attempted_ratio = npc.path_follow.progress_ratio;
