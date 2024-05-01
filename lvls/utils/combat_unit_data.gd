extends Node

enum Type {
  DUAL_HYBRID,
  TWO_HANDED_AXER,
}

class Data:
  var sprite_path: String;
  var name: String;
  var get_path_points;
  func _init(sprite_path, name, get_path_points):
    self.sprite_path = sprite_path;
    self.name = name;
    self.get_path_points = get_path_points;

var entries: Dictionary = {
  Type.DUAL_HYBRID: Data.new(
    "res://art/my/chars/dual_hybrid.png",
    "Dual Hybrid",
    get_basic_path_points,
  ),
  Type.TWO_HANDED_AXER: Data.new(
    "res://art/my/chars/two_handed_axer.png",
    "Barbarian",
    get_basic_path_points,
  ),
}

func get_basic_path_points(player_init_position, npc_init_position, attack_position_offset, is_player) -> Array[Vector2]:
  if is_player:
    return [
      player_init_position,
      Vector2(435, -100),
      Vector2(667, -118),
      npc_init_position - attack_position_offset,
    ];
  return [
    npc_init_position,
    Vector2(667, -118),
    Vector2(435, -100),
    player_init_position + attack_position_offset,
  ];

