extends Node2D
class_name ChooseChar

@onready var ui: Control = $ui_root/ui;

var pause_menu: Node;

func _ready():
  var scene_tween_time = Constants.std_tween_time;
  SceneHelper.fade_in([self, ui], scene_tween_time);
  create_char_choices();
  await get_tree().create_timer(scene_tween_time).timeout;

func on_char_selected(key: CombatUnitData.Type):
  var player_inventory_item_types = init_player_inventory_items();
  AppState.insert_data(Constants.player, {
    "combat_unit_data_type": key,
    "health": CombatUnitData.default_max_health,
    "inventory_item_types": player_inventory_item_types,
    "mod_types": [],
  });
  var current_opponent_choice_keys = CombatUnitData.entries.keys();
  current_opponent_choice_keys.reverse();
  AppState.insert_data(Constants.game_state, {
    "current_opponent_idx": 0,
    "current_opponent_choice_keys": current_opponent_choice_keys,
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
  var player_game_completion_count = Lang.dict_get(AppState.data, [Constants.metrics, "game_completion", "count"], 0);
  for key in CombatUnitData.entries.keys():
    var entry = CombatUnitData.entries[key];
    var disabled = player_game_completion_count < entry.game_completion_count_required;
    var entry_box = VBoxContainer.new();
    var button = TextureButton.new();
    var label_box = VBoxContainer.new();
    var panel = PanelContainer.new();
    var label = Label.new();
    panel.theme_type_variation = &"PanelSmallSticker";
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
    entry_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
    label_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
    button.texture_normal = load(entry.bust_path);
    var info_label = null;
    if disabled:
      info_label = Label.new();
      info_label.text = str(entry.game_completion_count_required) + " game completions" ;
      info_label.theme_type_variation = &"HeaderMedium";
      info_label.set("theme_override_colors/font_color", Color(1.0, 0.4, 0.4, 1.0));
      info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
      button.modulate = Color(0.2, 0.2, 0.2);
    else:
      button.focus_entered.connect(func(): on_char_selected(key));
    label.text = entry.name;
    label.theme_type_variation = &"HeaderMedium";
    label_box.add_child(label);
    if info_label: label_box.add_child(info_label);
    panel.add_child(label_box);
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
  if not pause_menu:
    pause_menu = SceneHelper.make_pause_menu();
    ui.add_child(pause_menu);
  else:
    ui.remove_child(pause_menu);
    pause_menu = null;
