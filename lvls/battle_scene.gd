extends Node2D

@onready var cam: PhantomCamera2D = $cam;

# TODO: change qte button to textured buttons instead of generic fonts
# TODO: figure out how to run the tweens in parallel rather than using the separate tweens and taking the max timeout to this wait for all of them to finish

class CombatUnit:
  var char: BattleChar;
  var path_follow: PathFollow2D;
  var path: Path2D;
  var unit_data: CombatUnitData.Data;
  var health_bar: TextureProgressBar;
  var name: Label;
  var bust: TextureRect;
  func _init(char, path_follow, path, health_bar, name, bust):
    self.char = char;
    self.path_follow = path_follow;
    self.path = path;
    self.health_bar = health_bar;
    self.name = name;
    self.bust = bust;

class Background:
  var lg_clouds: Array[Sprite2D];
  var md_clouds: Array[Sprite2D];
  var sm_clouds: Array[Sprite2D];
  func _init(lg_clouds: Array[Sprite2D], md_clouds: Array[Sprite2D], sm_clouds: Array[Sprite2D]):
    self.lg_clouds = lg_clouds;
    self.md_clouds = md_clouds;
    self.sm_clouds = sm_clouds;

@onready var background = Background.new(
  [$bg_root/lg_cloud_2, $bg_root/lg_cloud],
  [$bg_root/md_cloud_2, $bg_root/md_cloud],
  [$bg_root/sm_cloud_2, $bg_root/sm_cloud],
);
@onready var player = CombatUnit.new(
  $path_left/path_follow/battle_char,
  $path_left/path_follow,
  $path_left,
  $ui_root/ui/player_info/hbox/margin/vbox/healthbar,
  $ui_root/ui/player_info/hbox/margin/vbox/panel/vbox/name,
  $ui_root/ui/player_info/hbox/bust,
);
@onready var npc = CombatUnit.new(
  $path_right/path_follow/battle_char,
  $path_right/path_follow,
  $path_right,
  $ui_root/ui/npc_info/hbox/margin/vbox/healthbar,
  $ui_root/ui/npc_info/hbox/margin/vbox/panel/vbox/name,
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
var qte_total_actions = 4;
var qte_min_x = 100;
var qte_max_x = 850;
var qte_min_y = 160;
var qte_max_y = 540;
var std_tween_time = 1;

class QTEItem:
  var box: BoxContainer;
  var button: Button;
  func _init(box, button):
    self.box = box;
    self.button = button;

var qte_items: Array[QTEItem] = [];

var qte_all_keys = ["up", "down", "left", "right"];

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
  player.unit_data = CombatUnitData.entries[CombatUnitData.Type.DUAL_HYBRID];
  npc.unit_data = CombatUnitData.entries[CombatUnitData.Type.TWO_HANDED_AXER];
  player.char.update_sprite_texture(player.unit_data.sprite_path);
  npc.char.update_sprite_texture(npc.unit_data.sprite_path);
  player.char.to_player();
  update_bust_texture(player);
  player.bust.flip_h = true;
  update_bust_texture(npc);
  player.char.idle();
  npc.char.idle();
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
  await get_tree().create_timer(max(scene_tween_time, ui_tween_time)).timeout;

func _input(event: InputEvent):
  qte_attempt(event);

func qte_attempt(event: InputEvent):
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  if qte_item and event.is_action_pressed(qte_item.button.text):
    qte_event_update();

func update_bust_texture(combat_unit: CombatUnit):
  var texture = load(combat_unit.unit_data.bust_path);
  if texture and texture is Texture:
    combat_unit.bust.texture = texture;

func _update_unit_health_bar(combat_unit: CombatUnit):
  combat_unit.health_bar.value = (combat_unit.char.health / combat_unit.char.MAX_HEALTH) * 100;

func full_round(attacker: CombatUnit, defender: CombatUnit):
  await attack_sequence(attacker, defender, 1, false);
  is_player_turn = !is_player_turn;
  await get_tree().create_timer(0.5).timeout;
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

func deal_damage_to(combat_unit: CombatUnit):
  combat_unit.char.take_damage(1);
  _update_unit_health_bar(combat_unit);

func attack_sequence(attacker: CombatUnit, defender: CombatUnit, total_atk_time: float, is_npc_turn: bool, atk_trans: Tween.TransitionType = Tween.TRANS_EXPO):
  create_qte_items(is_npc_turn);
  attacker.char.preatk();
  defender.char.readied();
  var atk_path_follow_tween = create_tween();
  atk_path_follow_tween.tween_property(attacker.path_follow, "progress_ratio", 1, total_atk_time).set_trans(atk_trans);
  await atk_path_follow_tween.finished;
  attacker.char.postatk();
  var damage_taker = defender;
  if is_npc_turn and parried:
    damage_taker = attacker;
    defender.char.postatk();
  deal_damage_to(damage_taker);
  destory_qte_btns(is_npc_turn);
  # HACK: to let the postatk frame show for a second
  await get_tree().create_timer(1).timeout;
  attacker.char.idle();
  defender.char.idle();
  var atk_path_follow_tween_out = create_tween();
  atk_path_follow_tween_out.tween_property(attacker.path_follow, "progress_ratio", 0, std_tween_time).set_trans(Tween.TRANS_CUBIC);
  return await atk_path_follow_tween_out.finished;

func _on_attack_pressed():
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
    action_counter_progress_bar.value = (qte_current_action_count * 100) / qte_total_actions;
    parried = qte_current_action_count == qte_total_actions;
    show_qte_item();

func hide_qte_item():
  var qte_item = get_qte_item(qte_current_action_count);
  if not qte_item: return;
  qte_item.button.disabled = true;
  var qte_box_tween = create_tween();
  qte_box_tween.tween_property(qte_item.box, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_EXPO);

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

func create_qte_item():
  var box = BoxContainer.new();
  var button = Button.new()
  button.pressed.connect(_on_qte_btn_pressed)
  box.position = Vector2(
    rng.randf_range(qte_min_x, qte_max_x),
    rng.randf_range(qte_min_y, qte_max_y)
  );
  button.text = qte_all_keys[rng.randf_range(0, qte_all_keys.size() - 1)];
  button.disabled = true;
  box.modulate.a = 0;
  box.add_child(button);
  ui.add_child(box);
  return QTEItem.new(box, button);

func destory_qte_btns(is_npc_turn):
  if not is_npc_turn: return;
  for qte_item in qte_items:
    ui.remove_child(qte_item.box);
  qte_items = [];
