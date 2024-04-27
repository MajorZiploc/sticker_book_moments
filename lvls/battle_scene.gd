extends Node2D

@onready var player = {
  "char": $path_left/path_follow/battle_char,
  "path_follow": $path_left/path_follow,
}

@onready var npc = {
  "char": $path_right/path_follow/battle_char,
  "path_follow": $path_right/path_follow,
}

@export var is_player_turn = true;

var attack_shift = Vector2(175, 0);

# Called when the node enters the scene tree for the first time.
func _ready():
  var texture = preload("res://art/my/chars/dual_hybrid.png");
  if texture and texture is Texture:
    player["char"].sprite.texture = texture;
  player["char"].sprite.flip_h = true;
  player["init_position"] = player["char"].position;
  npc["init_position"] = npc["char"].position;

func start_char_turn(attacker, defender):
  attacker["char"].sprite.frame = 1;
  defender["char"].sprite.frame = 3;
  var tween = get_tree().create_tween();
  tween.tween_property(attacker["path_follow"], "progress_ratio", 1, 1).set_trans(Tween.TRANS_EXPO);
  tween.connect("finished", func(): on_end_char_action(attacker, defender))

func on_end_char_action(attacker, defender):
  attacker["char"].sprite.frame = 2;
  defender["char"].take_damage(1);
  # HACK: to let the postatk frame show for a second
  var tween = get_tree().create_tween();
  tween.tween_property(attacker["path_follow"], "progress_ratio", 1, 1);
  tween.connect("finished", func(): on_end_char_turn(attacker, defender))

func on_end_char_turn(attacker, defender):
  attacker["char"].sprite.frame = 0;
  defender["char"].sprite.frame = 0;
  var tween = get_tree().create_tween();
  tween.tween_property(attacker["path_follow"], "progress_ratio", 0, 1).set_trans(Tween.TRANS_CUBIC);
  tween.connect("finished", func(): on_finished_char_move_reset(attacker, defender))

func on_finished_char_move_reset(attacker, defender):
  if !is_player_turn:
    is_player_turn = !is_player_turn;
    start_char_turn(npc, player);

func _on_attack_pressed():
  if is_player_turn:
    is_player_turn = !is_player_turn;
    start_char_turn(player, npc);
