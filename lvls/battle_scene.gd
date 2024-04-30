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
  npc.char.update_sprite_texture("res://art/my/chars/two_handed_axer.png");
  player.char.to_player();
  player.char.idle();
  npc.char.idle();

func attack_sequence(attacker: CombatUnit, defender: CombatUnit):
  attacker.char.preatk();
  defender.char.readied();
  var tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1).set_trans(Tween.TRANS_EXPO);
  await tween.finished;
  attacker.char.postatk();
  defender.char.take_damage(1);
  # HACK: to let the postatk frame show for a second
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1);
  await tween.finished;
  attacker.char.idle();
  defender.char.idle();
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 0, 1).set_trans(Tween.TRANS_CUBIC);
  await tween.finished;
  if !is_player_turn:
    is_player_turn = !is_player_turn;
    attack_sequence(npc, player);

func _on_attack_pressed():
  if is_player_turn:
    is_player_turn = !is_player_turn;
    attack_sequence(player, npc);
