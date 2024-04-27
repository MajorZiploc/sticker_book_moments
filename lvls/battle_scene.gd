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

func init_char_move(char_data, enemy_data):
  char_data["char"].sprite.frame = 1;
  enemy_data["char"].sprite.frame = 3;
  var tween = get_tree().create_tween();
  tween.tween_property(char_data["path_follow"], "progress_ratio", 1, 1).set_trans(Tween.TRANS_CUBIC);
  tween.connect("finished", func(): on_finished_char_move(char_data, enemy_data))

func on_finished_char_move(char_data, enemy_data):
  char_data["char"].sprite.frame = 2;
  enemy_data["char"].take_damage(1);
  # HACK: to let the postatk frame show for a second
  var tween = get_tree().create_tween();
  tween.tween_property(char_data["path_follow"], "progress_ratio", 1, 1);
  tween.connect("finished", func(): char_move_reset(char_data, enemy_data))

func char_move_reset(char_data, enemy_data):
  char_data["char"].sprite.frame = 0;
  enemy_data["char"].sprite.frame = 0;
  var tween = get_tree().create_tween();
  tween.tween_property(char_data["path_follow"], "progress_ratio", 0, 1).set_trans(Tween.TRANS_CUBIC);
  tween.connect("finished", func(): on_finished_char_move_reset(char_data, enemy_data))

func on_finished_char_move_reset(char_data, enemy_data):
  if !is_player_turn:
    is_player_turn = !is_player_turn;
    init_char_move(npc, player);

func _on_attack_pressed():
  if is_player_turn:
    is_player_turn = !is_player_turn;
    init_char_move(player, npc);
