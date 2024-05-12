extends Node

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
  func _init(sprite_path, bust_path, name, get_path_points):
    self.sprite_path = sprite_path;
    self.bust_path = bust_path;
    self.name = name;
    self.get_path_points = get_path_points;

var entries: Dictionary = {
  Type.DUAL_HYBRID: Data.new(
    "res://art/my/char/dual_hybrid.png",
    "res://art/my/char/dual_hybrid_bust.png",
    "Raven Silverheart",
    get_basic_path_points,
  ),
  Type.TWO_HANDED_AXER: Data.new(
    "res://art/my/char/two_handed_axer.png",
    "res://art/my/char/two_handed_axer_bust.png",
    "Hilda Grimjaw",
    get_basic_path_points,
  ),
  Type.SPEARWOMAN: Data.new(
    "res://art/my/char/spearwoman.png",
    "res://art/my/char/spearwoman_bust.png",
    "Nova Windstriker",
    get_basic_path_points,
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

