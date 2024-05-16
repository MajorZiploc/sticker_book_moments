extends Node2D
class_name BattleScene

@onready var cam: PhantomCamera2D = $cam;

class CombatUnit:
  var battle_char: BattleChar;
  var path_follow: PathFollow2D;
  var path: Path2D;
  var unit_data: CombatUnitData.Data;
  var health_bar: TextureProgressBar;
  var name: Label;
  var bust: TextureRect;
  var is_player: bool;
  func _init(char_, path_follow_, path_, health_bar_, name_, bust_):
    self.battle_char = char_;
    self.path_follow = path_follow_;
    self.path = path_;
    self.health_bar = health_bar_;
    self.name = name_;
    self.bust = bust_;
    self.is_player = false;

class Background:
  var lg_clouds: Array[Sprite2D];
  var md_clouds: Array[Sprite2D];
  var sm_clouds: Array[Sprite2D];
  func _init(lg_clouds_: Array[Sprite2D], md_clouds_: Array[Sprite2D], sm_clouds_: Array[Sprite2D]):
    self.lg_clouds = lg_clouds_;
    self.md_clouds = md_clouds_;
    self.sm_clouds = sm_clouds_;

@onready var background = Background.new(
  [$bg_root/lg_cloud_2, $bg_root/lg_cloud],
  [$bg_root/md_cloud_2, $bg_root/md_cloud],
  [$bg_root/sm_cloud_2, $bg_root/sm_cloud],
);
@onready var player = CombatUnit.new(
  $path_left/path_follow/battle_char,
  $path_left/path_follow,
  $path_left,
  $ui_root/ui/player_info/hbox/combat_unit_info/vbox/healthbar,
  $ui_root/ui/player_info/hbox/combat_unit_info/vbox/panel/vbox/name,
  $ui_root/ui/player_info/hbox/bust,
);
@onready var npc = CombatUnit.new(
  $path_right/path_follow/battle_char,
  $path_right/path_follow,
  $path_right,
  $ui_root/ui/npc_info/hbox/combat_unit_info/vbox/healthbar,
  $ui_root/ui/npc_info/hbox/combat_unit_info/vbox/panel/vbox/name,
  $ui_root/ui/npc_info/hbox/bust,
);
@onready var ui: Control = $ui_root/ui;
@onready var npc_turn_ui: PanelContainer = $ui_root/ui/npc_turn;
@onready var player_choices: BoxContainer = $ui_root/ui/choice;
@onready var action_counter_container: BoxContainer = $ui_root/ui/action_counter;
@onready var action_counter_progress_bar: ProgressBar = $ui_root/ui/action_counter/progress_bar;

@export var is_player_turn = true;
@export var std_cam_zoom: Vector2 = Vector2(0.5, 0.5);

var parried = false;
var player_init_position = Vector2(2, 0);
var npc_init_position = Vector2(1020, 0);
var attack_position_offset = Vector2(175, 0);
var rng = RandomNumberGenerator.new();
var qte_current_action_count = 0;
var qte_total_actions = 5;
var qte_min_x = 100;
var qte_max_x = 850;
var qte_min_y = 160;
var qte_max_y = 540;
var std_tween_time = 1;

class QTEItem:
  var key: String;
  var box: BoxContainer;
  var button: TextureButton;
  func _init(key_, box_, button_):
    self.key = key_;
    self.box = box_;
    self.button = button_;

class QTEItemMetaData:
  var normal: Texture;
  func _init(normal_: Texture):
    self.normal = normal_;

var qte_items: Array[QTEItem] = [];

var qte_item_metadata: Dictionary = {
  "up": QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/up/normal.png"),
  ),
  "down": QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/down/normal.png"),
  ),
  "left": QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/left/normal.png"),
  ),
  "right": QTEItemMetaData.new(
    preload("res://art/my/ui/qte_btn/right/normal.png"),
  ),
};

@onready var player_info_controller = $ui_root/ui/player_info/hbox/combat_unit_info/vbox/panel/vbox/controller;

var qte_all_keys = qte_item_metadata.keys();

func _ready():
  self.modulate.a = 0;
  ui.modulate.a = 0;
  action_counter_container.modulate.a = 0;
  cam.zoom = std_cam_zoom;
  var scene_tween_time = std_tween_time;
  var scene_tween = create_tween();
  scene_tween.tween_property(self, "modulate:a", 1, scene_tween_time).set_trans(Tween.TRANS_EXPO);
  var ui_tween_time = std_tween_time;
  var ui_tween = create_tween();
  ui_tween.tween_property(ui, "modulate:a", 1, ui_tween_time).set_trans(Tween.TRANS_EXPO);
  npc_turn_ui.modulate.a = 0;
  _init_bg();
  var player_combat_unit_data_type = AppState.data["player"]["combat_unit_data_type"];
  player.unit_data = CombatUnitData.entries[player_combat_unit_data_type];
  var npc_combat_unit_data_type = AppState.data["npc"]["combat_unit_data_type"];
  npc.unit_data = CombatUnitData.entries[npc_combat_unit_data_type];
  player.battle_char.update_sprite_texture(player.unit_data.sprite_path);
  npc.battle_char.update_sprite_texture(npc.unit_data.sprite_path);
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
  player.name.text = " " + player.unit_data.name + " ";
  npc.name.text = " " + npc.unit_data.name + " ";
  _update_unit_health_bar(player);
  _update_unit_health_bar(npc);
  await get_tree().create_timer(max(scene_tween_time, ui_tween_time)).timeout;

func to_player(player_: CombatUnit):
  player_info_controller.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
  player_info_controller.text = " player ";
  player_.battle_char.to_player();
  player_.bust.flip_h = true;
  player_.name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;
  player_.health_bar.fill_mode = TextureProgressBar.FillMode.FILL_LEFT_TO_RIGHT;
  player_.is_player = true;

func _input(event: InputEvent):
  qte_attempt(event);

func qte_attempt(event: InputEvent):
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  if qte_item and event.is_action_pressed(qte_item.key):
    qte_event_update();

func update_bust_texture(combat_unit: CombatUnit):
  var texture = load(combat_unit.unit_data.bust_path);
  if texture and texture is Texture:
    combat_unit.bust.texture = texture;

func _update_unit_health_bar(combat_unit: CombatUnit):
  combat_unit.health_bar.value = (combat_unit.battle_char.health / combat_unit.battle_char.MAX_HEALTH) * 100;

func full_round(attacker: CombatUnit, defender: CombatUnit):
  await attack_sequence(attacker, defender, 1, false);
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
    var progress_bar_tween_time = std_tween_time;
    var progress_bar_tween = create_tween();
    progress_bar_tween.tween_property(action_counter_container, "modulate:a", 1, progress_bar_tween_time).set_trans(Tween.TRANS_EXPO);
    await get_tree().create_timer(max(npc_turn_ui_tween_out_time, cam_tween_time, progress_bar_tween_time)).timeout;
    await get_tree().create_timer(0.5).timeout;
    await attack_sequence(defender, attacker, 5, true, Tween.TRANS_LINEAR);
    var player_choices_tween_time = std_tween_time;
    var player_choices_tween = create_tween();
    player_choices_tween.tween_property(player_choices, "modulate:a", 1, player_choices_tween_time).set_trans(Tween.TRANS_EXPO);
    cam_tween = create_tween();
    cam_tween.tween_property(cam, "zoom", std_cam_zoom, cam_tween_time).set_trans(Tween.TRANS_EXPO);
    progress_bar_tween = create_tween();
    progress_bar_tween.tween_property(action_counter_container, "modulate:a", 0, progress_bar_tween_time).set_trans(Tween.TRANS_EXPO);
    await get_tree().create_timer(max(npc_turn_ui_tween_out_time, cam_tween_time, progress_bar_tween_time)).timeout;
    action_counter_progress_bar.value = 0;
    did_battle_end = defender.battle_char.health <= 0;
    if did_battle_end:
      winner = attacker;
    did_battle_end = attacker.battle_char.health <= 0;
    if did_battle_end:
      winner = defender;
  if did_battle_end:
    end_battle_scene(winner);
  AppState.save_session();

func deal_damage_to(combat_unit: CombatUnit):
  combat_unit.battle_char.take_damage(1);
  _update_unit_health_bar(combat_unit);

func attack_sequence(attacker: CombatUnit, defender: CombatUnit, total_atk_time: float, is_npc_turn: bool, atk_trans: Tween.TransitionType = Tween.TRANS_EXPO):
  create_qte_items(is_npc_turn);
  attacker.battle_char.preatk();
  defender.battle_char.readied();
  var atk_path_follow_tween = create_tween();
  atk_path_follow_tween.tween_property(attacker.path_follow, "progress_ratio", 1, total_atk_time).set_trans(atk_trans);
  await atk_path_follow_tween.finished;
  attacker.battle_char.postatk();
  var damage_taker = defender;
  if is_npc_turn and parried:
    damage_taker = attacker;
    defender.battle_char.postatk();
  deal_damage_to(damage_taker);
  destory_qte_btns(is_npc_turn);
  # HACK: to let the postatk frame show for a second
  await get_tree().create_timer(1).timeout;
  attacker.battle_char.idle();
  defender.battle_char.idle();
  var atk_path_follow_tween_out = create_tween();
  atk_path_follow_tween_out.tween_property(attacker.path_follow, "progress_ratio", 0, std_tween_time).set_trans(Tween.TRANS_CUBIC);
  return await atk_path_follow_tween_out.finished;

func _on_attack_button_up():
  if is_player_turn and player.path_follow.progress_ratio == 0 and npc.path_follow.progress_ratio == 0:
    var player_choices_tween_out = create_tween();
    player_choices_tween_out.tween_property(player_choices, "modulate:a", 0, std_tween_time).set_trans(Tween.TRANS_EXPO);
    is_player_turn = !is_player_turn;
    parried = false;
    qte_current_action_count = 0;
    full_round(player, npc);

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

func hide_qte_item():
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  qte_item.button.disabled = true;
  var qte_tween = create_tween().set_parallel(true);
  qte_tween.tween_property(qte_item.button, "modulate", Color(0.8, 0.8, 0.8), 0.2).set_trans(Tween.TRANS_LINEAR);
  qte_tween.tween_property(qte_item.box, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_EXPO);

func show_qte_item():
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  qte_item.button.disabled = false;
  var qte_box_tween = create_tween();
  qte_box_tween.tween_property(qte_item.box, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_EXPO);

func get_qte_item(index):
  if index >= qte_items.size(): return;
  return qte_items[index];

func _on_qte_btn_pressed():
  qte_event_update();

func create_qte_items(is_npc_turn):
  if not is_npc_turn: return;
  for i in qte_total_actions:
    qte_items.append(create_qte_item());
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  qte_item.box.visible = true;
  var qte_box_tween = create_tween();
  qte_box_tween.tween_property(qte_item.box, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_EXPO);
  qte_item.button.disabled = false;

func _on_end_battle_scene():
  SceneSwitcher.change_scene("res://scenes/title_scene.tscn", {})

func end_battle_scene(combat_unit: CombatUnit):
  var box = BoxContainer.new();
  box.anchor_right = 0.5;
  box.anchor_left = 0.5;
  box.anchor_bottom = 0.5;
  box.anchor_top = 0.5;
  box.grow_horizontal = 2
  box.grow_vertical = 2
  # box.layout_mode;
  # box.anchors_preset;
  var button = Button.new();
  var result = "Loses" if not combat_unit.is_player else "Wins"
  button.text = "Player " + result + "!";
  # button.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
  button.focus_entered.connect(_on_end_battle_scene);
  button.theme_type_variation = &"ButtonLarge";
  box.add_child(button);
  ui.add_child(box);

func create_qte_item():
  var box = BoxContainer.new();
  var button = TextureButton.new();
  box.scale = Vector2(0.7, 0.7);
  button.focus_entered.connect(_on_qte_btn_pressed);
  box.position = Vector2(
    rng.randf_range(qte_min_x, qte_max_x),
    rng.randf_range(qte_min_y, qte_max_y)
  );
  var key = qte_all_keys[rng.randf_range(0, qte_all_keys.size() - 1)];
  button.texture_normal = qte_item_metadata[key].normal;
  button.disabled = true;
  box.modulate.a = 0;
  box.add_child(button);
  ui.add_child(box);
  return QTEItem.new(key, box, button);

func destory_qte_btns(is_npc_turn):
  if not is_npc_turn: return;
  for qte_item in qte_items:
    ui.remove_child(qte_item.box);
  qte_items = [];
