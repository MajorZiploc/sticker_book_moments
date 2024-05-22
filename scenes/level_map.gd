extends Node2D

@onready var ui: Control = $ui_root/ui;

var pause_menu: Node;

func _ready():
  pause_menu = SceneHelper.make_pause_menu();
  create_char_choices();
  ui.add_child(pause_menu);

func _input(event: InputEvent):
  var visible = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible: return;

func on_char_selected(key: CombatUnitData.Type):
  AppState.insert_data(Constants.npc, {"combat_unit_data_type": key, "health": CombatUnitData.default_max_health});
  AppState.save_session();
  SceneSwitcher.change_scene("res://scenes/battle_scene.tscn", {});

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
