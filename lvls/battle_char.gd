extends CharacterBody2D

@onready var sprite = $Sprite2D;
@onready var progress_bar = $Sprite2D/ProgressBar;
@onready var animation_player = $AnimationPlayer;

@export var MAX_HEALTH: float = 7;

@export var health: float = 7:
  set(value):
    health = value;
    _update_progress_bar();
    _play_animation_hurt();
    
func _update_progress_bar():
  progress_bar.value = (health / MAX_HEALTH) * 100;
  
func _play_animation_hurt():
  animation_player.play("hurt");
  
func take_damage(value):
  health -= value;
