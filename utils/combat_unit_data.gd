extends Node

var default_max_health: float = 100;

var default_damage: float = 15;

enum Type {
  DUAL_HYBRID,
  TWO_HANDED_AXER,
  SPEARWOMAN,
}

class Data:
  var sprite_path: String;
  var bust_path: String;
  var name: String;
  var get_path_points;
  var health_modifier: float;
  var damage_modifier: float;
  var game_completion_count_required: int;
  func _init(sprite_path_, bust_path_, name_, get_path_points_, health_modifier_, damage_modifier_, game_completion_count_required_):
    self.sprite_path = sprite_path_;
    self.bust_path = bust_path_;
    self.name = name_;
    self.get_path_points = get_path_points_;
    self.health_modifier = health_modifier_;
    self.damage_modifier = damage_modifier_;
    self.game_completion_count_required = game_completion_count_required_;

var entries: Dictionary = {
  Type.DUAL_HYBRID: Data.new(
    "res://art/my/char/dual_hybrid.png",
    "res://art/my/char/dual_hybrid_bust.png",
    "Raven Silverheart",
    get_basic_path_points,
    1.1,
    0.9,
    0,
  ),
  Type.TWO_HANDED_AXER: Data.new(
    "res://art/my/char/two_handed_axer.png",
    "res://art/my/char/two_handed_axer_bust.png",
    "Hilda Grimjaw",
    get_basic_path_points,
    1.2,
    0.8,
    1,
  ),
  Type.SPEARWOMAN: Data.new(
    "res://art/my/char/spearwoman.png",
    "res://art/my/char/spearwoman_bust.png",
    "Nova Windstriker",
    get_basic_path_points,
    1,
    1,
    2,
  ),
}

func get_basic_path_points(player_position, npc_position) -> Array[Vector2]:
  # TODO: make middle points consider both the player_position and npc_position instead of hard coded pixel values
  return [
    npc_position,
    Vector2(667, -118),
    Vector2(435, -100),
    player_position,
  ];

func init_idle_tweens(sprite: Sprite2D, sprite_scalar: float = 1.0) -> Array[Tween]:
  var scale_tween = create_tween();
  var og_scale = sprite.scale;
  scale_tween.tween_property(sprite, "scale", Vector2(1.05 * sprite_scalar, 1.05 * sprite_scalar), 1).set_trans(Tween.TRANS_EXPO);
  scale_tween.tween_property(sprite, "scale", og_scale, 1).set_trans(Tween.TRANS_EXPO);
  scale_tween.set_loops(-1);
  var rotation_tween = create_tween();
  var og_rotation = sprite.rotation_degrees;
  rotation_tween.tween_property(sprite, "rotation_degrees", -3.4, 1).set_trans(rotation_tween.TRANS_EXPO);
  rotation_tween.tween_property(sprite, "rotation_degrees", og_rotation, 1).set_trans(rotation_tween.TRANS_EXPO);
  rotation_tween.tween_property(sprite, "rotation_degrees", 3.4, 1).set_trans(rotation_tween.TRANS_EXPO);
  rotation_tween.tween_property(sprite, "rotation_degrees", og_rotation, 1).set_trans(rotation_tween.TRANS_EXPO);
  rotation_tween.set_loops(-1);
  return [scale_tween, rotation_tween];
