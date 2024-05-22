extends Node2D

@onready var ui: Control = $ui_root/ui;

var pause_menu: Node;

func _ready():
  pause_menu = SceneHelper.make_pause_menu();
  create_char_choices();
  ui.add_child(pause_menu);

func _input(event: InputEvent):
  var visible_ = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible_: return;

func on_char_selected(key: CombatUnitData.Type):
  var player_inventory_item_types = init_player_inventory_items();
  AppState.insert_data(Constants.player, {
    "combat_unit_data_type": key,
    "health": CombatUnitData.default_max_health,
    "inventory_item_types": player_inventory_item_types,
    "mod_types": [],
  });
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

func init_player_inventory_items():
  var player_inventory_item_types = [];
  for i in Constants.max_inventory_size - 1:
    if i < 6:
      if i % 3 == 0:
        player_inventory_item_types.append(BattleSceneHelper.ModItemType.PARALYZED);
      elif i % 2 == 0:
        player_inventory_item_types.append(BattleSceneHelper.ModItemType.POSION);
      else:
        player_inventory_item_types.append(BattleSceneHelper.ModItemType.STRENGTH);
  return player_inventory_item_types;

func _on_options_btn_button_up():
  SceneHelper.toggle_pause_menu_btn(pause_menu);
