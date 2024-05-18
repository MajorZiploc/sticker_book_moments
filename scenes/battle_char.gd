extends AnimatableBody2D
class_name BattleChar

@onready var sprite: Sprite2D = $sprite;

var health: float = CombatUnitData.MAX_HEALTH:
  set(value):
    health = value;
    
enum FrameType {
  IDLE,
  PREATK,
  POSTATK,
  READIED,
}

func play_animate_generic(frame_type: FrameType):
  var frame_data: FrameData.Data = frame_data_dict[frame_type];
  for tween in frame_data.animate.tweens:
    tween.play();

func stop_animate_generic(frame_type: FrameType):
  var frame_data: FrameData.Data = frame_data_dict[frame_type];
  for tween in frame_data.animate.tweens:
    tween.stop();

var frame_data_dict: Dictionary = {
  FrameType.IDLE: FrameData.Data.new(
    FrameData.AnimateData.new(
      [],
      (func(): play_animate_generic(FrameType.IDLE)),
      (func(): stop_animate_generic(FrameType.IDLE)),
    )
  ),
  FrameType.PREATK: FrameData.Data.new(),
  FrameType.POSTATK: FrameData.Data.new(),
  FrameType.READIED: FrameData.Data.new()
}

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
  var frame_data: FrameData.Data = frame_data_dict[FrameType.IDLE];
  frame_data.animate.tweens.append_array([scale_tween, rotation_tween]);

func play_frame_animation(frame_type_to_play: FrameType):
  for cur_frame_type in FrameType:
    var cur_frame_type_value = FrameType[cur_frame_type];
    if cur_frame_type_value != frame_type_to_play:
      var cur_frame_data: FrameData.Data = frame_data_dict[cur_frame_type_value];
      cur_frame_data.animate.stop.call();
  var frame_data: FrameData.Data = frame_data_dict[frame_type_to_play];
  frame_data.animate.play.call();

func take_damage(value: float):
  health -= value;
  var tween = create_tween();
  var og_modulate = sprite.modulate;
  for n in 2:
    tween.tween_callback(sprite.set_modulate.bind(Color(30, 1, 1, 1))).set_delay(0.1);
    tween.tween_callback(sprite.set_modulate.bind(og_modulate)).set_delay(0.1);

func idle():
  sprite.frame = 0;
  play_frame_animation(FrameType.IDLE);

func preatk():
  sprite.frame = 1;
  play_frame_animation(FrameType.PREATK);

func postatk():
  sprite.frame = 2;
  play_frame_animation(FrameType.POSTATK);

func readied():
  sprite.frame = 3;
  play_frame_animation(FrameType.READIED);

func to_player():
  sprite.flip_h = true;

func to_npc():
  sprite.flip_h = false;

func update_sprite_texture(asset_path: String):
  var texture = load(asset_path);
  if texture and texture is Texture:
    sprite.texture = texture;
