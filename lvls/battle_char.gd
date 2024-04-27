extends AnimatableBody2D

@onready var sprite = $Sprite2D;
@onready var progress_bar = $Sprite2D/ProgressBar;

@export var MAX_HEALTH: float = 7;

@export var health: float = 7:
  set(value):
    health = value;
    _update_progress_bar();
    
func _update_progress_bar():
  progress_bar.value = (health / MAX_HEALTH) * 100;
  
func take_damage(value):
  health -= value;
  var tween = get_tree().create_tween();
  var og_modulate = sprite.modulate;
  for n in 2:
    tween.tween_callback(sprite.set_modulate.bind(Color(30, 1, 1, 1))).set_delay(0.1);
    tween.tween_callback(sprite.set_modulate.bind(og_modulate)).set_delay(0.1);
