extends Node2D

@onready var battle_char_left = $battle_char_left;
@onready var battle_char_right = $battle_char_right;
@onready var pause_after_player_atk = $PauseAfterPlayerAtk;

@export var is_player_turn = true;

# Called when the node enters the scene tree for the first time.
func _ready():
  # var texture = preload("res://art/my/chars/berserk_axer.png");
  # if texture and texture is Texture:
    # battle_char_right.sprite.texture = texture;
  battle_char_left.sprite.flip_h = true;

func _on_attack_pressed():
  if is_player_turn:
    battle_char_right.take_damage(1);
    is_player_turn = !is_player_turn;
    pause_after_player_atk.start();

func _on_pause_after_player_atk_timeout():
  if !is_player_turn:
    # TODO: abstrat this out into an AI decision system
    battle_char_left.take_damage(1);
    is_player_turn = !is_player_turn;
