extends Node2D

@onready var ui: Control = $ui_root/ui;

var pause_menu = null;

func _ready():
  create_char_choices();

func _input(event: InputEvent):
  pause_menu = SceneHelper.toggle_pause_menu(event, ui, pause_menu);
  if pause_menu: return;

func on_char_selected(key: CombatUnitData.Type):
  AppState.insert_data(Constants.player, {"combat_unit_data_type": key, "health": CombatUnitData.default_max_health});
  AppState.save_session();
  SceneSwitcher.change_scene("res://scenes/level_map.tscn", {})

func create_char_choices():
  var box = BoxContainer.new();
  box.position = Vector2(40, 300);
  for key in CombatUnitData.entries.keys():
    var entry = CombatUnitData.entries[key];
    var button = Button.new();
    button.focus_entered.connect(func(): on_char_selected(key));
    button.text = entry.name;
    box.add_child(button);
  ui.add_child(box);
