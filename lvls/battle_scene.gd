extends Node2D

class CombatUnit:
  var char: BattleChar;
  var path_follow: PathFollow2D;
  var path: Path2D;
  func _init(char, path_follow, path):
    self.char = char;
    self.path_follow = path_follow;
    self.path = path;

@onready var player = CombatUnit.new($path_left/path_follow/battle_char, $path_left/path_follow, $path_left);
@onready var npc = CombatUnit.new($path_right/path_follow/battle_char, $path_right/path_follow, $path_right);
@onready var path_parry_marker: Path2D = $path_parry_marker;
@onready var path_parry_marker_path_follow: PathFollow2D = $path_parry_marker/path_follow;

@export var is_player_turn = true;

var parry_attempted = false;
var parry_attempted_ratio = 0.0;
var min_parry_ratio = 0.65;
var max_parry_ratio = 1;
var player_init_position = Vector2(2, 0);
var npc_init_position = Vector2(1036, 5);
var attack_position_offset = Vector2(175, 0);
var basic_player_path_points = [
  player_init_position,
  Vector2(435, -100),
  Vector2(667, -118),
  npc_init_position - attack_position_offset,
];
var basic_npc_path_points = [
  npc_init_position,
  Vector2(667, -118),
  Vector2(435, -100),
  player_init_position + attack_position_offset,
];

# Called when the node enters the scene tree for the first time.
func _ready():
  player.char.update_sprite_texture(CombatUnitData.entries[CombatUnitData.Type.DUAL_HYBRID].sprite_path);
  npc.char.update_sprite_texture(CombatUnitData.entries[CombatUnitData.Type.TWO_HANDED_AXER].sprite_path);
  player.char.to_player();
  player.char.idle();
  npc.char.idle();
  player.path.curve.clear_points();
  for point in basic_player_path_points:
    player.path.curve.add_point(point);
  npc.path.curve.clear_points();
  for point in basic_npc_path_points:
    npc.path.curve.add_point(point);
    path_parry_marker.curve.add_point(point);
  path_parry_marker_path_follow.progress_ratio = (min_parry_ratio + max_parry_ratio) / 2;
  path_parry_marker.visible = false;

func full_round(attacker: CombatUnit, defender: CombatUnit):
  await attack_sequence(attacker, defender);
  is_player_turn = !is_player_turn;
  await attack_sequence(defender, attacker);

  # NOTE: in this func: is_player_turn actually means its enemy turn
func attack_sequence(attacker: CombatUnit, defender: CombatUnit):
  path_parry_marker.visible = is_player_turn;
  attacker.char.preatk();
  defender.char.readied();
  var tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1).set_trans(Tween.TRANS_EXPO);
  await tween.finished;
  attacker.char.postatk();
  var damage_taker = defender;
  if is_player_turn:
    if parry_attempted and parry_attempted_ratio >= min_parry_ratio and parry_attempted_ratio <= max_parry_ratio:
      damage_taker = attacker;
      defender.char.postatk();
  damage_taker.char.take_damage(1);
  path_parry_marker.visible = false;
  # HACK: to let the postatk frame show for a second
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1);
  await tween.finished;
  attacker.char.idle();
  defender.char.idle();
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 0, 1).set_trans(Tween.TRANS_CUBIC);
  return await tween.finished;

func _on_attack_pressed():
  if is_player_turn and player.path_follow.progress_ratio == 0 and npc.path_follow.progress_ratio == 0:
    is_player_turn = !is_player_turn;
    parry_attempted = false;
    parry_attempted_ratio = 0.0;
    full_round(player, npc);
  elif !parry_attempted:
    print('npc.path_follow.progress_ratio');
    print(npc.path_follow.progress_ratio);
    parry_attempted = true;
    parry_attempted_ratio = npc.path_follow.progress_ratio;
