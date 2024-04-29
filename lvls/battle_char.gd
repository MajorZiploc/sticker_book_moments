extends AnimatableBody2D

@onready var sprite = $sprite;
@onready var health_bar = $sprite/health_bar;

@export var MAX_HEALTH: float = 7;

@export var health: float = 7:
  set(value):
    health = value;
    _update_health_bar();
    
enum FrameType {
  IDLE,
  PREATK,
  POSTATK,
  READIED,
}

var tweens_key = "tweens";

var frame_data = {
  FrameType.IDLE: {
    tweens_key: [],
  },
  FrameType.PREATK: {
    tweens_key: [],
  },
  FrameType.POSTATK: {
    tweens_key: [],
  },
  FrameType.READIED: {
    tweens_key: [],
  },
};

func _ready():
  _init_idle_tweens();

func _init_idle_tweens():
  var scale_tween = create_tween();
  var og_scale = sprite.scale;
  scale_tween.tween_property(sprite, "scale", Vector2(1.05, 1.05), 1).set_trans(scale_tween.TRANS_EXPO);
  scale_tween.tween_property(sprite, "scale", og_scale, 1).set_trans(scale_tween.TRANS_EXPO);
  scale_tween.set_loops(-1);
  var rotation_tween = create_tween();
  var og_rotation = sprite.rotation_degrees;
  rotation_tween.tween_property(sprite, "rotation_degrees", -3.4, 1).set_trans(rotation_tween.TRANS_EXPO);
  rotation_tween.tween_property(sprite, "rotation_degrees", og_rotation, 1).set_trans(rotation_tween.TRANS_EXPO);
  rotation_tween.tween_property(sprite, "rotation_degrees", 3.4, 1).set_trans(rotation_tween.TRANS_EXPO);
  rotation_tween.set_loops(-1);
  scale_tween.stop();
  rotation_tween.stop();
  frame_data[FrameType.IDLE][tweens_key].append_array([scale_tween, rotation_tween]);

func play_frame_tweens(frame_type):
  for cur_frame_type in FrameType:
    var cur_frame_type_value = FrameType[cur_frame_type];
    var tweens = frame_data[cur_frame_type_value][tweens_key];
    if cur_frame_type_value == frame_type:
      for tween in tweens:
        tween.play();
    else:
      for tween in tweens:
        tween.stop();

func _update_health_bar():
  health_bar.value = (health / MAX_HEALTH) * 100;
  
func take_damage(value):
  health -= value;
  var tween = create_tween();
  var og_modulate = sprite.modulate;
  for n in 2:
    tween.tween_callback(sprite.set_modulate.bind(Color(30, 1, 1, 1))).set_delay(0.1);
    tween.tween_callback(sprite.set_modulate.bind(og_modulate)).set_delay(0.1);

func idle():
  sprite.frame = 0;
  play_frame_tweens(FrameType.IDLE);

func preatk():
  sprite.frame = 1;
  play_frame_tweens(FrameType.PREATK);

func postatk():
  sprite.frame = 2;
  play_frame_tweens(FrameType.POSTATK);

func readied():
  sprite.frame = 3;
  play_frame_tweens(FrameType.READIED);

func to_player():
  sprite.flip_h = true;

func to_npc():
  sprite.flip_h = false;

func update_sprite_texture(asset_path):
  var texture = load(asset_path);
  if texture and texture is Texture:
    sprite.texture = texture;
