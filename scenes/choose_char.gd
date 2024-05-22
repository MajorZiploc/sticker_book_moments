extends Node2D
class_name ChooseChar

@onready var ui: Control = $ui_root/ui;

var pause_menu: Node;

func _ready():
  var scene_tween_time = Constants.std_tween_time;
  SceneHelper.fade_in([self, ui], scene_tween_time);
  pause_menu = SceneHelper.make_pause_menu();
  create_char_choices();
  ui.add_child(pause_menu);
  await get_tree().create_timer(scene_tween_time).timeout;

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
  AppState.insert_data(Constants.game_state, {
    "current_opponent_idx": 0,
    "current_opponent_choice_keys": CombatUnitData.entries.keys(),
  });
  AppState.save_session();
  SceneSwitcher.change_scene("res://scenes/level_map.tscn", {})

func create_char_choices():
  var box = HBoxContainer.new();
  var scale_scalar = 0.5
  box.scale = Vector2(scale_scalar, scale_scalar);
  box.position = Vector2(40, 300);
  box.custom_minimum_size = Vector2(5000 * scale_scalar, 0);
  box.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
  for key in CombatUnitData.entries.keys():
    var entry = CombatUnitData.entries[key];
    var entry_box = VBoxContainer.new();
    var button = TextureButton.new();
    var panel = PanelContainer.new();
    var label = Label.new();
    entry_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
    button.texture_normal = load(entry.bust_path);
    button.focus_entered.connect(func(): on_char_selected(key));
    label.text = entry.name;
    label.theme_type_variation = &"HeaderMedium";
    panel.add_child(label);
    entry_box.add_child(button);
    entry_box.add_child(panel);
    box.add_child(entry_box);
    var spacer = Control.new();
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
    box.add_child(spacer);
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
  SceneHelper.toggle_node(pause_menu);
