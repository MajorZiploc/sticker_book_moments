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
  AppState.insert_data(Constants.npc, {
    "combat_unit_data_type": key,
    "health": CombatUnitData.default_max_health,
    "inventory_item_types": [],
    "mod_types": [],
  });
  AppState.save_session();
  SceneSwitcher.change_scene("res://scenes/battle_scene.tscn", {});

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

func _on_options_btn_button_up():
  SceneHelper.toggle_pause_menu_btn(pause_menu);
