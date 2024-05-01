extends Node

enum Type {
  DUAL_HYBRID,
  TWO_HANDED_AXER,
}

class Data:
  var sprite_path: String;
  var name: String;
  func _init(sprite_path, name):
    self.sprite_path = sprite_path;
    self.name = name;

var entries: Dictionary = {
  Type.DUAL_HYBRID: Data.new(
    "res://art/my/chars/dual_hybrid.png",
    "Dual Hybrid",
  ),
  Type.TWO_HANDED_AXER: Data.new(
    "res://art/my/chars/two_handed_axer.png",
    "Barbarian",
  ),
}

