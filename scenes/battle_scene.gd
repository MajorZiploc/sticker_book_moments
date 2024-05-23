extends Node2D
class_name BattleScene

@onready var cam: Camera2D = $cam;

@onready var background = BattleSceneHelper.Background.new(
  [$bg_root/lg_cloud_2, $bg_root/lg_cloud],
  [$bg_root/md_cloud_2, $bg_root/md_cloud],
  [$bg_root/sm_cloud_2, $bg_root/sm_cloud],
);
@onready var player = BattleSceneHelper.CombatUnit.new(
  $path_left/path_follow/battle_char,
  $path_left/path_follow,
  $path_left,
  $ui_root/ui/player_info/hbox/combat_unit_info/vbox/healthbar,
  $ui_root/ui/player_info/hbox/combat_unit_info/vbox/panel/vbox/name,
  $ui_root/ui/player_info/hbox/bust,
  [],
  $ui_root/ui/player_mod_draw,
);
@onready var npc = BattleSceneHelper.CombatUnit.new(
  $path_right/path_follow/battle_char,
  $path_right/path_follow,
  $path_right,
  $ui_root/ui/npc_info/hbox/combat_unit_info/vbox/healthbar,
  $ui_root/ui/npc_info/hbox/combat_unit_info/vbox/panel/vbox/name,
  $ui_root/ui/npc_info/hbox/bust,
  [],
  $ui_root/ui/npc_mod_draw,
);
@onready var ui: Control = $ui_root/ui;
@onready var npc_turn_ui: PanelContainer = $ui_root/ui/npc_turn;
@onready var player_choices: BoxContainer = $ui_root/ui/player_choices;
@onready var player_options_btn: Button = $ui_root/ui/options_btn;
@onready var player_choices_action_btn: MenuButton = $ui_root/ui/player_choices/btn;
@onready var player_choices_close_btn: Button = $ui_root/ui/player_choices/close_inventory_btn;
@onready var player_inventory_grid: GridContainer = $ui_root/ui/player_inventory/panel/grid;
@onready var player_inventory_panel: PanelContainer = $ui_root/ui/player_inventory/panel;
@onready var player_inventory_ui_root: Control = $ui_root/ui/player_inventory;
@onready var action_counter_container: BoxContainer = $ui_root/ui/action_counter;
@onready var action_counter_progress_bar: ProgressBar = $ui_root/ui/action_counter/progress_bar;
@onready var qte_onscreen_btns: Control = $ui_root/ui/qte_onscreen_btns;
@onready var qte_onscreen_btn_up: Control = $ui_root/ui/qte_onscreen_btns/up;
@onready var qte_onscreen_btn_down: Control = $ui_root/ui/qte_onscreen_btns/down;
@onready var qte_onscreen_btn_left: Control = $ui_root/ui/qte_onscreen_btns/left;
@onready var qte_onscreen_btn_right: Control = $ui_root/ui/qte_onscreen_btns/right;

@export var is_player_turn = true;
@export var std_cam_zoom: Vector2 = Vector2(0.5, 0.5);

var pause_menu: Node;

var player_inventory_size = 9;
var player_inventory_item_types = [];
var round_happening = false;
var parried = false;
var failed_parry = false;
var player_init_position = Vector2(2, 0);
var npc_init_position = Vector2(1020, 0);
var attack_position_offset = Vector2(175, 0);
var rng = RandomNumberGenerator.new();
var qte_current_action_count = 0;
var qte_total_actions = 5;
var qte_min_x = 100;
var qte_max_x = 1000;
var qte_min_y = 160;
var std_qte_max_y = 540;
var qte_max_y = std_qte_max_y;
var std_tween_time = 1;
var qte_mode = BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON;
var qte_area_position = Vector2(qte_min_x, qte_min_y);
var qte_area = calc_qte_area();
var is_mobile_directional = false;
var current_opponent_idx = AppState.data.get(Constants.game_state, {}).get("current_opponent_idx", 0);

func calc_qte_area():
  var qte_area_size = Vector2(qte_max_x - qte_min_x, qte_max_y - qte_min_y);
  return Rect2(qte_area_position, qte_area_size);

var qte_items: Array[BattleSceneHelper.QTEItem] = [];

var qte_item_metadata: Dictionary = {
  "up": BattleSceneHelper.QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/up/normal.png"),
    [BattleSceneHelper.QTEMode.BUTTON, BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON],
  ),
  "down": BattleSceneHelper.QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/down/normal.png"),
    [BattleSceneHelper.QTEMode.BUTTON, BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON],
  ),
  "left": BattleSceneHelper.QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/left/normal.png"),
    [BattleSceneHelper.QTEMode.BUTTON, BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON],
  ),
  "right": BattleSceneHelper.QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/right/normal.png"),
    [BattleSceneHelper.QTEMode.BUTTON, BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON],
  ),
  "tap": BattleSceneHelper.QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/finger/normal.png"),
    [BattleSceneHelper.QTEMode.TOUCH, BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON],
  ),
};

@onready var player_info_controller = $ui_root/ui/player_info/hbox/combat_unit_info/vbox/panel/vbox/controller;

var mod_item_metadata: Dictionary = {
  BattleSceneHelper.ModItemType.PARALYZED: BattleSceneHelper.ModItemMetaData.new(
    preload("res://art/my/items/paralyzed.png"),
    true,
  ),
  BattleSceneHelper.ModItemType.POSION: BattleSceneHelper.ModItemMetaData.new(
    preload("res://art/my/items/posion.png"),
    true,
  ),
  BattleSceneHelper.ModItemType.STRENGTH: BattleSceneHelper.ModItemMetaData.new(
    preload("res://art/my/items/strength.png"),
    false,
  ),
};

var default_mod_item_size = 150;

var valid_qte_keys = qte_item_metadata.keys();

func _ready():
  pause_menu = SceneHelper.make_pause_menu();
  qte_mode = AppState.data.get(Constants.options, {}).get("qte_mode", qte_mode);
  var player_choices_popup = player_choices_action_btn.get_popup();
  player_choices_popup.connect("id_pressed", on_player_choices_menu_item_pressed);
  player_inventory_ui_root.modulate.a = 0;
  qte_onscreen_btns.visible = false;
  qte_onscreen_btns.modulate.a = 0;
  show_player_choices_action_btn();
  var scene_tween_time = Constants.std_tween_time;
  SceneHelper.fade_in([self, ui], scene_tween_time);
  action_counter_container.modulate.a = 0;
  cam.zoom = std_cam_zoom;
  npc_turn_ui.modulate.a = 0;
  _init_bg();
  var player_data = AppState.data[Constants.player];
  player_inventory_item_types = player_data["inventory_item_types"];
  update_player_inventory();
  var player_combat_unit_data_type = player_data["combat_unit_data_type"];
  player.unit_data = CombatUnitData.entries[player_combat_unit_data_type];
  var npc_data = AppState.data[Constants.npc];
  var npc_combat_unit_data_type = npc_data["combat_unit_data_type"];
  npc.unit_data = CombatUnitData.entries[npc_combat_unit_data_type];
  player.battle_char.update_sprite_texture(player.unit_data.sprite_path);
  player.battle_char.health = player_data.get("health", CombatUnitData.default_max_health * player.unit_data.health_modifier);
  npc.battle_char.update_sprite_texture(npc.unit_data.sprite_path);
  npc.battle_char.health = npc_data.get("health", CombatUnitData.default_max_health * npc.unit_data.health_modifier);
  to_player(player);
  update_bust_texture(player);
  update_bust_texture(npc);
  if npc_combat_unit_data_type == player_combat_unit_data_type:
    npc.battle_char.modulate = Color(0.8, 0.8, 0.8);
    npc.bust.modulate = Color(0.8, 0.8, 0.8);
  player.battle_char.idle();
  npc.battle_char.idle();
  var player_path_points: Array[Vector2] = player.unit_data.get_path_points.call(player_init_position, npc_init_position - attack_position_offset)
  player.path.curve.clear_points();
  for i in range(player_path_points.size() - 1, -1, -1):
    var point = player_path_points[i];
    player.path.curve.add_point(point);
  var npc_path_points: Array[Vector2] = npc.unit_data.get_path_points.call(player_init_position + attack_position_offset, npc_init_position)
  npc.path.curve.clear_points();
  for point in npc_path_points:
    npc.path.curve.add_point(point);
  player.name.text = player.unit_data.name;
  npc.name.text = npc.unit_data.name;
  _update_unit_health_bar(player);
  _update_unit_health_bar(npc);
  init_combat_unit_mods(player);
  init_combat_unit_mods(npc);
  update_combat_unit_mods(player);
  update_combat_unit_mods(npc);
  ui.add_child(pause_menu);
  await get_tree().create_timer(scene_tween_time).timeout;

func init_combat_unit_mods(combat_unit: BattleSceneHelper.CombatUnit):
  # TODO: move mods out into AppState.data
  return;
  # rest is stub for testing
  for i in 5:
    if i % 3 == 0:
      combat_unit.mod_types.append(BattleSceneHelper.ModItemType.PARALYZED);
    elif i % 2 == 0:
      combat_unit.mod_types.append(BattleSceneHelper.ModItemType.POSION);
    else:
      combat_unit.mod_types.append(BattleSceneHelper.ModItemType.STRENGTH);

func update_combat_unit_mods(combat_unit: BattleSceneHelper.CombatUnit):
  for n in combat_unit.mod_draw.get_children():
    combat_unit.mod_draw.remove_child(n);
  for i in combat_unit.mod_types.size():
    var box = BoxContainer.new();
    box.custom_minimum_size = Vector2(default_mod_item_size, default_mod_item_size);
    var mod = Sprite2D.new();
    mod.texture = mod_item_metadata[combat_unit.mod_types[i]].texture;
    box.add_child(mod);
    combat_unit.mod_draw.add_child(box);

func update_player_inventory(disabled: bool = true):
  for n in player_inventory_grid.get_children():
    player_inventory_grid.remove_child(n);
  for i in Constants.max_inventory_size - 1:
    var panel = PanelContainer.new();
    if i < 6 and player_inventory_item_types.size() > i:
      var button = TextureButton.new();
      button.disabled = disabled;
      button.button_up.connect(func(): _on_inventory_item_selected(i));
      button.texture_normal = mod_item_metadata[player_inventory_item_types[i]].texture;
      panel.add_child(button);
    else:
      panel.custom_minimum_size = Vector2(default_mod_item_size, default_mod_item_size);
    player_inventory_grid.add_child(panel);

func _on_inventory_item_selected(idx):
  var item_type = player_inventory_item_types[idx];
  var combat_unit = npc if mod_item_metadata[item_type].is_debuff else player;
  if combat_unit.mod_types.any(func(t): return t == item_type):
    var box = BoxContainer.new();
    var panel = PanelContainer.new();
    panel.theme_type_variation = &"PanelSmallSticker";
    box.position = Vector2(400, 587);
    var label = Label.new();
    label.theme_type_variation = &"HeaderSmall";
    label.text = "Item already being applied!";
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
    panel.add_child(label);
    box.add_child(panel);
    ui.add_child(box);
    var invalid_item: TextureButton = player_inventory_grid.get_child(idx).get_child(0);
    var ui_tween = create_tween();
    var og_box_modulate = box.modulate;
    for n in 2:
      ui_tween.tween_property(invalid_item, "modulate", Color(15, 1, 1, 1), 0.3).set_trans(Tween.TRANS_EXPO);
      ui_tween.tween_property(invalid_item, "modulate", og_box_modulate, 0.2).set_trans(Tween.TRANS_EXPO);
    var tween = create_tween();
    # HACK: to have box stay on screen for 3 seconds
    box.modulate.a = 1;
    tween.tween_property(box, "modulate:a", 1, 3).set_trans(Tween.TRANS_EXPO);
    tween.tween_property(box, "modulate:a", 0, std_tween_time).set_trans(Tween.TRANS_EXPO);
    tween.tween_callback(func(): ui.remove_child(box)).set_delay(0.1);
  else:
    show_player_choices_action_btn();
    player_inventory_item_types.pop_at(idx);
    combat_unit.mod_types.append(item_type);
    update_combat_unit_mods(combat_unit);
    update_player_inventory();
    perform_full_round_state();
    var used_items = AppState.data.get(Constants.metrics, {}).get("used_items", {});
    used_items[item_type] = used_items.get(item_type, 0) + 1;
    AppState.insert_data(Constants.metrics, {
      "used_items": used_items,
    });
    full_round(player, npc, true);

func to_player(player_: BattleSceneHelper.CombatUnit):
  player_info_controller.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
  player_info_controller.text = Constants.player;
  player_.battle_char.to_player();
  player_.bust.flip_h = true;
  player_.name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;
  player_.health_bar.fill_mode = TextureProgressBar.FillMode.FILL_LEFT_TO_RIGHT;
  player_.is_player = true;

func _input(event: InputEvent):
  if round_happening:
    qte_attempt(event);
    return;
  var visible_ = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible_: return;

func qte_attempt(event: InputEvent):
  if failed_parry: return;
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  var was_qte_item_key_pressed = valid_qte_keys.any(func(key): return event.is_action_pressed(key));
  var valid_directional_qte_keys = valid_qte_keys.filter(func(key): return key != "tap");
  if not was_qte_item_key_pressed: return;
  if not qte_onscreen_btns.visible and qte_item.is_button_event:
    if event.is_action_pressed(qte_item.key):
      qte_event_update();
    else:
      failed_parry = true;
  if qte_item.is_touch_event:
    if valid_directional_qte_keys.any(func(key): return event.is_action_pressed(key)):
        failed_parry = true;
    elif event.is_action_pressed(qte_item.key):
      var rect_size = qte_item.sprite.get_texture().get_size() * qte_item.sprite.scale;
      # NOTE: assumes global_position is the center of the sprite rectangle. so we calculate the top left corner here
      var sprite_position = qte_item.sprite.global_position - (rect_size / 2.0);
      var sprite_rect = Rect2(sprite_position, rect_size);
      # NOTE: event.position sometimes has to be one of these: [make_input_local(event).position, to_local(event.position)]
      if sprite_rect.has_point(event.position):
        qte_event_update();
      elif qte_area.has_point(event.position):
          failed_parry = true;
  if failed_parry:
    on_failed_parry(qte_item);

func on_failed_parry(qte_item: BattleSceneHelper.QTEItem):
  var tween = create_tween();
  var og_modulate = qte_item.sprite.modulate;
  for n in 2:
    tween.tween_property(qte_item.sprite, "modulate", Color(15, 1, 1), 0.3).set_trans(Tween.TRANS_EXPO);
    tween.tween_property(qte_item.sprite, "modulate", og_modulate, 0.2).set_trans(Tween.TRANS_EXPO);
  hide_qte_item(1.1);
  var parries = AppState.data.get(Constants.metrics, {}).get("parries", {});
  parries["fail"] = parries.get("fail", 0) + 1;
  AppState.insert_data(Constants.metrics, {
    "parries": parries,
  });

func update_bust_texture(combat_unit: BattleSceneHelper.CombatUnit):
  var texture = load(combat_unit.unit_data.bust_path);
  if texture and texture is Texture:
    combat_unit.bust.texture = texture;

func _update_unit_health_bar(combat_unit: BattleSceneHelper.CombatUnit):
  AppState.insert_data(Constants.player if combat_unit.is_player else Constants.npc, { "health": combat_unit.battle_char.health, "inventory_item_types": player_inventory_item_types if combat_unit.is_player else [], "mod_types": combat_unit.mod_types });
  combat_unit.health_bar.value = (combat_unit.battle_char.health / CombatUnitData.default_max_health) * 100;

func paralyzed_check(combat_unit: BattleSceneHelper.CombatUnit):
  var should_hit = true;
  var idx = Lang.find_index(func(t): return t == BattleSceneHelper.ModItemType.PARALYZED, combat_unit.mod_types);
  var is_paralyzed = idx >= 0;
  if is_paralyzed:
    # 70% chance of hitting
    should_hit = (rng.randf_range(0, 1) * 100) > 30;
  if not should_hit:
    var mod: Sprite2D = combat_unit.mod_draw.get_child(idx).get_child(0);
    tween_used_mod_draw_item(mod);
    # TODO: indicate that combat_unit is paralyzed with some tweening
  return should_hit;

func posion_check(combat_unit: BattleSceneHelper.CombatUnit):
  var idx = Lang.find_index(func(t): return t == BattleSceneHelper.ModItemType.POSION, combat_unit.mod_types);
  var is_posioned = idx >= 0;
  if is_posioned:
    # deal 10% of combat_unit health in damage
    deal_damage(combat_unit.unit_data.health_modifier * CombatUnitData.default_max_health * 0.10, combat_unit);
    var mod: Sprite2D = combat_unit.mod_draw.get_child(idx).get_child(0);
    tween_used_mod_draw_item(mod);
    # TODO: make combat_unit flash green instead of red

func strength_check(combat_unit: BattleSceneHelper.CombatUnit):
  # NOTE: this applies for attacks and parries
  var damage_mod = 1.0;
  var idx = Lang.find_index(func(t): return t == BattleSceneHelper.ModItemType.STRENGTH, combat_unit.mod_types);
  var has_strength = idx >= 0;
  if has_strength:
    # deal 10% bonus attack if attack successful
    damage_mod = 1.1;
    var mod: Sprite2D = combat_unit.mod_draw.get_child(idx).get_child(0);
    tween_used_mod_draw_item(mod);
    # TODO: make combat_unit tween in some way
  return damage_mod;

func tween_used_mod_draw_item(mod: Sprite2D):
  var scale_tween = create_tween();
  var og_scale = mod.scale;
  scale_tween.tween_property(mod, "scale", Vector2(1.35, 1.35), 0.3).set_trans(Tween.TRANS_EXPO);
  scale_tween.tween_property(mod, "scale", og_scale, 0.1).set_trans(Tween.TRANS_EXPO);
  scale_tween.set_loops(2);
  var rotation_tween = create_tween();
  rotation_tween.tween_property(mod, "rotation_degrees", -5.4, 0.2).set_trans(Tween.TRANS_SPRING);
  rotation_tween.tween_property(mod, "rotation_degrees", 5.4, 0.2).set_trans(Tween.TRANS_SPRING);
  rotation_tween.set_loops(2);

func full_round(attacker: BattleSceneHelper.CombatUnit, defender: BattleSceneHelper.CombatUnit, player_used_item: bool = false):
  qte_mode = AppState.data.get(Constants.options, {}).get("qte_mode", qte_mode);
  var is_mobile = AppState.data.get(Constants.options, {}).get("is_mobile", false);
  is_mobile_directional = is_mobile && [BattleSceneHelper.QTEMode.BUTTON, BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON].any(func(qm): return qm == qte_mode);
  var should_hit = not player_used_item and paralyzed_check(attacker);
  if should_hit: await attack_sequence(attacker, defender, 1, false);
  is_player_turn = !is_player_turn;
  await get_tree().create_timer(0.5).timeout;
  var did_battle_end = defender.battle_char.health <= 0;
  var winner = attacker if did_battle_end else defender;
  if not did_battle_end:
    var cam_tween_time = std_tween_time;
    var cam_tween = create_tween();
    cam_tween.tween_property(cam, "zoom", Vector2(0.65, 0.65), cam_tween_time).set_trans(Tween.TRANS_EXPO);
    var npc_turn_ui_tween = create_tween();
    npc_turn_ui_tween.tween_property(npc_turn_ui, "modulate:a", 1, std_tween_time).set_trans(Tween.TRANS_EXPO);
    await npc_turn_ui_tween.finished;
    await get_tree().create_timer(0.5).timeout;
    var npc_turn_ui_tween_out_time = std_tween_time;
    var npc_turn_ui_tween_out = create_tween();
    npc_turn_ui_tween_out.tween_property(npc_turn_ui, "modulate:a", 0, npc_turn_ui_tween_out_time).set_trans(Tween.TRANS_EXPO);
    var mobile_dir_tween_time = 0;
    if is_mobile_directional:
      qte_max_y = 500;
      qte_area = calc_qte_area();
      qte_onscreen_btns.visible = true;
      mobile_dir_tween_time = std_tween_time;
      var mobile_dir_tween = create_tween();
      mobile_dir_tween.tween_property(qte_onscreen_btns, "modulate:a", 1, mobile_dir_tween_time).set_trans(Tween.TRANS_EXPO);
    else:
      qte_max_y = std_qte_max_y;
    var progress_bar_tween_time = std_tween_time;
    var progress_bar_tween = create_tween();
    progress_bar_tween.tween_property(action_counter_container, "modulate:a", 1, progress_bar_tween_time).set_trans(Tween.TRANS_EXPO);
    await get_tree().create_timer(max(npc_turn_ui_tween_out_time, cam_tween_time, progress_bar_tween_time, mobile_dir_tween_time)).timeout;
    await get_tree().create_timer(0.5).timeout;
    should_hit = paralyzed_check(defender);
    if should_hit: await attack_sequence(defender, attacker, 5.0 - (0.5 * (current_opponent_idx - 1)), true, Tween.TRANS_LINEAR);
    var player_choices_tween_time = std_tween_time;
    var player_choices_tween = create_tween();
    player_choices_tween.tween_property(player_choices, "modulate:a", 1, player_choices_tween_time).set_trans(Tween.TRANS_EXPO);
    player_options_btn.disabled = false;
    var player_options_tween_out_time = std_tween_time;
    var player_options_tween_out = create_tween();
    player_options_tween_out.tween_property(player_options_btn, "modulate:a", 1, player_options_tween_out_time).set_trans(Tween.TRANS_EXPO);
    toggle_disabled_player_choices(false);
    cam_tween = create_tween();
    cam_tween.tween_property(cam, "zoom", std_cam_zoom, cam_tween_time).set_trans(Tween.TRANS_EXPO);
    if is_mobile_directional:
      qte_onscreen_btns.visible = true;
      mobile_dir_tween_time = std_tween_time;
      var mobile_dir_tween = create_tween();
      mobile_dir_tween.tween_property(qte_onscreen_btns, "modulate:a", 0, mobile_dir_tween_time).set_trans(Tween.TRANS_EXPO);
      mobile_dir_tween.tween_callback(func(): qte_onscreen_btns.visible = false).set_delay(0.1);
    progress_bar_tween = create_tween();
    progress_bar_tween.tween_property(action_counter_container, "modulate:a", 0, progress_bar_tween_time).set_trans(Tween.TRANS_EXPO);
    await get_tree().create_timer(max(npc_turn_ui_tween_out_time, cam_tween_time, progress_bar_tween_time, player_choices_tween_time, player_options_tween_out_time, mobile_dir_tween_time)).timeout;
    action_counter_progress_bar.value = 0;
    did_battle_end = defender.battle_char.health <= 0 || attacker.battle_char.health <= 0;
    if defender.battle_char.health <= 0:
      winner = attacker;
    if attacker.battle_char.health <= 0:
      winner = defender;
  if did_battle_end:
    end_battle_scene(winner);
  AppState.save_session();
  posion_check(attacker);
  posion_check(defender);
  round_happening = false;

func deal_damage(amount: float, damage_taker: BattleSceneHelper.CombatUnit):
  damage_taker.battle_char.take_damage(amount);
  _update_unit_health_bar(damage_taker);

func attack_sequence(attacker: BattleSceneHelper.CombatUnit, defender: BattleSceneHelper.CombatUnit, total_atk_time: float, is_npc_turn: bool, atk_trans: Tween.TransitionType = Tween.TRANS_EXPO):
  create_qte_items(is_npc_turn);
  attacker.battle_char.preatk();
  defender.battle_char.readied();
  var atk_path_follow_tween = create_tween();
  atk_path_follow_tween.tween_property(attacker.path_follow, "progress_ratio", 1, total_atk_time).set_trans(atk_trans);
  await atk_path_follow_tween.finished;
  attacker.battle_char.postatk();
  var damage_taker = defender;
  var damage_dealer = attacker;
  if is_npc_turn and parried and not failed_parry:
    var parries = AppState.data.get(Constants.metrics, {}).get("parries", {});
    parries["perfect"] = parries.get("perfect", 0) + 1;
    AppState.insert_data(Constants.metrics, {
      "parries": parries,
    });
    damage_taker = attacker;
    damage_dealer = defender;
    defender.battle_char.postatk();
  var strength_modifier = strength_check(damage_dealer);
  deal_damage(strength_modifier * CombatUnitData.default_damage * damage_dealer.unit_data.damage_modifier, damage_taker);
  destory_qte_btns(is_npc_turn);
  # HACK: to let the postatk frame show for a second
  await get_tree().create_timer(1).timeout;
  attacker.battle_char.idle();
  defender.battle_char.idle();
  var atk_path_follow_tween_out = create_tween();
  atk_path_follow_tween_out.tween_property(attacker.path_follow, "progress_ratio", 0, std_tween_time).set_trans(Tween.TRANS_CUBIC);
  return await atk_path_follow_tween_out.finished;

func _init_bg_cloud_movements(clouds: Array[Sprite2D], start_x: float, end_x: float, total_move_secs: float, spacer: float):
  for cloud in clouds:
    cloud.position.x = start_x;
    cloud.visible = true;
    var timer_wait = total_move_secs * spacer;
    var cloud_tween = create_tween();
    cloud_tween.tween_property(cloud, "position:x", end_x, total_move_secs).set_trans(Tween.TRANS_LINEAR);
    cloud_tween.tween_callback(func(): cloud.position.x = start_x).set_delay(0.1);
    cloud_tween.set_loops(-1);
    await get_tree().create_timer(timer_wait).timeout;

func _hide_bg_eles(sprites: Array[Sprite2D]):
  for sprite in sprites:
    sprite.visible = false;

func _init_bg():
  _hide_bg_eles(background.lg_clouds);
  _hide_bg_eles(background.md_clouds);
  _hide_bg_eles(background.sm_clouds);
  _init_bg_cloud_movements(background.lg_clouds, -1200, 3300, 60, 0.6);
  _init_bg_cloud_movements(background.md_clouds, 2800, -1000, 65, 0.5);
  _init_bg_cloud_movements(background.sm_clouds, -800, 2500, 90, 0.1);

func qte_event_update():
  if qte_current_action_count < qte_total_actions:
    hide_qte_item();
    qte_current_action_count = qte_current_action_count + 1;
    action_counter_progress_bar.value = (qte_current_action_count * 100) / float(qte_total_actions);
    parried = qte_current_action_count == qte_total_actions;
    show_qte_item();

func hide_qte_item(tween_time: float = 0.5):
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  var qte_tween = create_tween().set_parallel(true);
  qte_tween.tween_property(qte_item.sprite, "modulate", Color(0.8, 0.8, 0.8), 0.2).set_trans(Tween.TRANS_LINEAR);
  qte_tween.tween_property(qte_item.sprite, "modulate:a", 0, tween_time).set_trans(Tween.TRANS_EXPO);

func show_qte_item():
  if failed_parry: return;
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  var qte_box_tween = create_tween();
  qte_box_tween.tween_property(qte_item.sprite, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_EXPO);

func get_qte_item(index):
  if index >= qte_items.size(): return;
  return qte_items[index];

func create_qte_items(is_npc_turn):
  if not is_npc_turn: return;
  valid_qte_keys = qte_item_metadata.keys().filter(func(key): return qte_item_metadata[key].qte_modes.any(func(qm): return qm == qte_mode));
  for i in qte_total_actions:
    qte_items.append(create_qte_item());
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  var qte_box_tween = create_tween();
  qte_box_tween.tween_property(qte_item.sprite, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_EXPO);

func _on_end_battle_scene(combat_unit: BattleSceneHelper.CombatUnit):
  var current_opponent_choice_keys = AppState.data.get(Constants.game_state, {}).get("current_opponent_choice_keys", CombatUnitData.entries.keys());
  var next_scene = "res://scenes/thanks_for_playing.tscn" if combat_unit.is_player else "res://scenes/title_scene.tscn";
  if combat_unit.is_player and current_opponent_idx < current_opponent_choice_keys.size() - 1:
    AppState.insert_data(Constants.game_state, {
      "current_opponent_idx": current_opponent_idx + 1,
    });
    next_scene = "res://scenes/level_map.tscn";
  SceneSwitcher.change_scene(next_scene, {})

func end_battle_scene(combat_unit: BattleSceneHelper.CombatUnit):
  var box = VBoxContainer.new();
  box.anchor_right = 0.5;
  box.anchor_left = 0.5;
  box.anchor_bottom = 0.5;
  box.anchor_top = 0.5;
  box.grow_horizontal = 2;
  box.grow_vertical = 2;
  # box.layout_mode;
  # box.anchors_preset;
  var label_panel = PanelContainer.new();
  label_panel.theme_type_variation = &"PanelSmallSticker";
  var label = Label.new();
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
  label.theme_type_variation = &"HeaderLarge";
  var button = Button.new();
  var result = "Loses" if not combat_unit.is_player else "Wins";
  var battle_results = AppState.data.get(Constants.metrics, {}).get("battle_results", {});
  var battle_results_key = "wins" if combat_unit.is_player else "loses";
  battle_results[battle_results_key] = battle_results.get(battle_results_key, 0) + 1;
  AppState.insert_data(Constants.metrics, {
    "battle_results": battle_results,
  });
  label.text = "Player " + result + "!";
  button.text = "Back to Title" if not combat_unit.is_player else "Continue";
  # button.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
  button.focus_entered.connect(func(): _on_end_battle_scene(combat_unit));
  button.theme_type_variation = &"ButtonLarge";
  label_panel.add_child(label);
  box.add_child(label_panel);
  box.add_child(button);
  ui.add_child(box);
  AppState.save_session();

func create_qte_item():
  var sprite: Sprite2D = Sprite2D.new();
  sprite.scale = Vector2(0.7, 0.7);
  var event_type = qte_mode;
  if qte_mode == BattleSceneHelper.QTEMode.TOUCH_AND_BUTTON:
    event_type = BattleSceneHelper.QTEMode.BUTTON;
    var use_touch_event = (rng.randf_range(0, 1) * 100) > 50; # TODO add this to settings page
    if use_touch_event:
      event_type = BattleSceneHelper.QTEMode.TOUCH;
  var event_qte_keys = valid_qte_keys.filter(func(key_): return qte_item_metadata[key_].qte_modes.any(func(qm): return qm == event_type));
  var key = event_qte_keys[int(rng.randf_range(0, event_qte_keys.size() - 1))];
  var is_button_event = is_qte_event_of_mode(BattleSceneHelper.QTEMode.BUTTON, key);
  var is_touch_event = is_qte_event_of_mode(BattleSceneHelper.QTEMode.TOUCH, key);
  sprite.position = Vector2(
    rng.randf_range(qte_min_x, qte_max_x),
    rng.randf_range(qte_min_y, qte_max_y)
  );
  sprite.texture = qte_item_metadata[key].normal;
  sprite.modulate.a = 0;
  ui.add_child(sprite);
  return BattleSceneHelper.QTEItem.new(key, sprite, is_button_event, is_touch_event);

func is_qte_event_of_mode(qte_mode_, key):
  return qte_item_metadata[key].qte_modes.any(func(qm): return qm == qte_mode_);

func destory_qte_btns(is_npc_turn):
  if not is_npc_turn: return;
  for qte_item in qte_items:
    ui.remove_child(qte_item.sprite);
  qte_items = [];

func perform_full_round_state():
  var tween = create_tween();
  tween.tween_property(player_inventory_ui_root, "modulate:a", 0, std_tween_time).set_trans(Tween.TRANS_EXPO);
  toggle_disabled_player_choices(true);
  round_happening = true;
  var player_choices_tween_out = create_tween();
  player_choices_tween_out.tween_property(player_choices, "modulate:a", 0, std_tween_time).set_trans(Tween.TRANS_EXPO);
  player_options_btn.disabled = true;
  var player_options_tween_out = create_tween();
  player_options_tween_out.tween_property(player_options_btn, "modulate:a", 0, std_tween_time).set_trans(Tween.TRANS_EXPO);
  is_player_turn = !is_player_turn;
  parried = false;
  failed_parry = false;
  qte_current_action_count = 0;

func on_player_choices_menu_item_pressed(id):
  match id:
    BattleSceneHelper.PlayerChoicesMenuPopupItem.ATTACK:
      if not round_happening and is_player_turn and player.path_follow.progress_ratio == 0 and npc.path_follow.progress_ratio == 0:
        perform_full_round_state();
        full_round(player, npc);
    BattleSceneHelper.PlayerChoicesMenuPopupItem.INVENTORY:
        show_player_choices_inventory_close_btn();
        player_inventory_ui_root.modulate.a = 1;
        update_player_inventory(false);

func _on_close_inventory_btn_button_up():
  player_inventory_ui_root.modulate.a = 0;
  update_player_inventory();
  show_player_choices_action_btn();

func show_player_choices_inventory_close_btn():
  player_choices_action_btn.visible = false;
  player_choices_close_btn.visible = true;

func show_player_choices_action_btn():
  player_choices_action_btn.visible = true;
  player_choices_close_btn.visible = false;

func toggle_disabled_player_choices(b: bool):
  player_choices_action_btn.disabled = b;
  player_choices_close_btn.disabled = b;

func _on_options_btn_button_up():
  SceneHelper.toggle_node(pause_menu);

func on_qte_dir_button_up(button: TextureButton, key: String):
  var tween = create_tween();
  var og_modulate = button.modulate;
  tween.tween_property(button, "modulate", Color(0.7, 0.7, 0.7), 0.05).set_trans(Tween.TRANS_LINEAR);
  tween.tween_property(button, "modulate", og_modulate, 0.05).set_trans(Tween.TRANS_LINEAR);
  if failed_parry: return;
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  if qte_item.key == key:
    qte_event_update();
  else:
    failed_parry = true;
    on_failed_parry(qte_item);

func _on_qte_dir_right_button_up():
  on_qte_dir_button_up(qte_onscreen_btn_right, "right");

func _on_qte_dir_left_button_up():
  on_qte_dir_button_up(qte_onscreen_btn_left, "left");

func _on_qte_dir_up_button_up():
  on_qte_dir_button_up(qte_onscreen_btn_up, "up");

func _on_qte_dir_down_button_up():
  on_qte_dir_button_up(qte_onscreen_btn_down, "down");
