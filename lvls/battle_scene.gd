extends Node2D

@onready var battle_char_left = $battle_char_left;
@onready var battle_char_right = $battle_char_right;
@onready var pause_after_player_atk = $PauseAfterPlayerAtk;
@onready var pause_before_npc_atk = $PauseBeforeNPCAtk;
@onready var pause_after_npc_atk = $PauseAfterNPCAtk;

@export var is_player_turn = true;

var attack_shift = Vector2(175, 0);

var battle_char_left_og_position;
var battle_char_right_og_position;

# Called when the node enters the scene tree for the first time.
func _ready():
  var texture = preload("res://art/my/chars/dual_hybrid.png");
  if texture and texture is Texture:
    battle_char_left.sprite.texture = texture;
  battle_char_left.sprite.flip_h = true;
  battle_char_left_og_position = battle_char_left.position;
  battle_char_right_og_position = battle_char_right.position;

func _on_attack_pressed():
  if is_player_turn:
    is_player_turn = !is_player_turn;
    battle_char_left.sprite.frame = 2;
    battle_char_left.position = battle_char_left.position + attack_shift;
    battle_char_right.take_damage(1);
    pause_after_player_atk.start();

func _on_pause_after_player_atk_timeout():
  pause_after_player_atk.stop();
  battle_char_left.sprite.frame = 0;
  battle_char_left.position = battle_char_left_og_position;
  pause_before_npc_atk.start();

func _on_pause_before_npc_atk_timeout():
  pause_before_npc_atk.stop();
  if !is_player_turn:
    # TODO: abstrat this out into an AI decision system
    battle_char_right.sprite.frame = 2;
    battle_char_right.position = battle_char_right.position - attack_shift;
    battle_char_left.take_damage(1);
    pause_after_npc_atk.start();

func _on_pause_after_npc_atk_timeout():
  pause_after_npc_atk.stop();
  battle_char_right.sprite.frame = 0;
  battle_char_right.position = battle_char_right_og_position;
  is_player_turn = !is_player_turn;
