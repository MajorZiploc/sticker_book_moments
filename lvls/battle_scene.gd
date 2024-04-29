extends Node2D

class CombatUnit:
    var char: BattleChar;
    var path_follow: PathFollow2D;
    func _init(char, path_follow):
      self.char = char;
      self.path_follow = path_follow;

@onready var player = CombatUnit.new($path_left/path_follow/battle_char, $path_left/path_follow);
@onready var npc = CombatUnit.new($path_right/path_follow/battle_char, $path_right/path_follow);

@export var is_player_turn = true;

var attack_shift = Vector2(175, 0);

# Called when the node enters the scene tree for the first time.
func _ready():
  player.char.update_sprite_texture("res://art/my/chars/dual_hybrid.png");
  player.char.to_player();
  player.char.idle();
  npc.char.idle();

func start_char_turn(attacker: CombatUnit, defender: CombatUnit):
  attacker.char.preatk();
  defender.char.readied();
  var tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1).set_trans(Tween.TRANS_EXPO);
  tween.connect("finished", func(): on_end_char_action(attacker, defender))

func on_end_char_action(attacker: CombatUnit, defender: CombatUnit):
  attacker.char.postatk();
  defender.char.take_damage(1);
  # HACK: to let the postatk frame show for a second
  var tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1);
  tween.connect("finished", func(): on_end_char_turn(attacker, defender))

func on_end_char_turn(attacker: CombatUnit, defender: CombatUnit):
  attacker.char.idle();
  defender.char.idle();
  var tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 0, 1).set_trans(Tween.TRANS_CUBIC);
  tween.connect("finished", func(): on_finished_char_move_reset(attacker, defender))

func on_finished_char_move_reset(attacker: CombatUnit, defender: CombatUnit):
  if !is_player_turn:
    is_player_turn = !is_player_turn;
    start_char_turn(npc, player);

func _on_attack_pressed():
  if is_player_turn:
    is_player_turn = !is_player_turn;
    start_char_turn(player, npc);
