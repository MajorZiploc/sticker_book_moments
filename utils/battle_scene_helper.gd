extends Node

class CombatUnit:
  var battle_char: BattleChar;
  var path_follow: PathFollow2D;
  var path: Path2D;
  var unit_data: CombatUnitData.Data;
  var health_bar: TextureProgressBar;
  var name: Label;
  var bust: TextureRect;
  var is_player: bool;
  var mod_types: Array;
  var mod_draw: VBoxContainer;
  func _init(char_, path_follow_, path_, health_bar_, name_, bust_, mod_types_, mod_draw_):
    self.battle_char = char_;
    self.path_follow = path_follow_;
    self.path = path_;
    self.health_bar = health_bar_;
    self.name = name_;
    self.bust = bust_;
    self.is_player = false;
    self.mod_types = mod_types_;
    self.mod_draw = mod_draw_;

enum QTEMode {
  TOUCH,
  BUTTON,
  TOUCH_AND_BUTTON,
}

enum PlayerChoicesMenuPopupItem {
  ATTACK,
  INVENTORY,
}

class Background:
  var lg_clouds: Array[Sprite2D];
  var md_clouds: Array[Sprite2D];
  var sm_clouds: Array[Sprite2D];
  func _init(lg_clouds_: Array[Sprite2D], md_clouds_: Array[Sprite2D], sm_clouds_: Array[Sprite2D]):
    self.lg_clouds = lg_clouds_;
    self.md_clouds = md_clouds_;
    self.sm_clouds = sm_clouds_;

class QTEItem:
  var key: String;
  var sprite: Sprite2D;
  var is_button_event: bool;
  var is_touch_event: bool;
  func _init(key_, sprite_, is_button_event_, is_touch_event_):
    self.key = key_;
    self.sprite = sprite_;
    self.is_button_event = is_button_event_;
    self.is_touch_event = is_touch_event_;

class QTEItemMetaData:
  var normal: Texture;
  var qte_modes: Array;
  func _init(normal_: Texture, qte_modes_):
    self.normal = normal_;
    self.qte_modes = qte_modes_;

enum ModItemType {
  PARALYZED,
  POSION,
  STRENGTH,
}

class ModItemMetaData:
  var texture: Texture;
  var is_debuff: bool;
  func _init(texture_: Texture, is_debuff_: bool):
    self.texture = texture_;
    self.is_debuff = is_debuff_;
