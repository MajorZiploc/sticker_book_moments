extends AnimatableBody2D

@onready var sprite = $sprite;
@onready var health_bar = $sprite/health_bar;

@export var MAX_HEALTH: float = 7;

@export var health: float = 7:
  set(value):
    health = value;
    _update_health_bar();
    
func _update_health_bar():
  health_bar.value = (health / MAX_HEALTH) * 100;
  
func take_damage(value):
  health -= value;
  var tween = get_tree().create_tween();
  var og_modulate = sprite.modulate;
  for n in 2:
    tween.tween_callback(sprite.set_modulate.bind(Color(30, 1, 1, 1))).set_delay(0.1);
    tween.tween_callback(sprite.set_modulate.bind(og_modulate)).set_delay(0.1);

func idle():
  sprite.frame = 0;

func preatk():
  sprite.frame = 1;

func postatk():
  sprite.frame = 2;

func readied():
  sprite.frame = 3;

func to_player():
  sprite.flip_h = true;

func to_npc():
  sprite.flip_h = false;

func update_sprite_texture(asset_path):
  var texture = load(asset_path);
  if texture and texture is Texture:
    sprite.texture = texture;
