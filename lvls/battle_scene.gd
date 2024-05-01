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

func full_round(attacker: CombatUnit, defender: CombatUnit):
  await attack_sequence(attacker, defender);
  is_player_turn = !is_player_turn;
  await attack_sequence(defender, attacker);

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
  return await tween.finished;

func _on_attack_pressed():
  if is_player_turn and npc.path_follow.progress_ratio == 0:
    is_player_turn = !is_player_turn;
    full_round(player, npc);
  else:
    # TODO: parry based on progress_ratio maybe if between 0.8 and 1 then parry instead of taking damage?
    # maybe creating a 'parried' flag to check in the attack_sequence to see who damage should be put on and changing player sprite
    # TODO: also only allow this path if the player has only tried to parry 1 time, all other parry attempts should come to this
    #   flag for 'parry_attempted'
    print('npc.path_follow.progress_ratio');
    print(npc.path_follow.progress_ratio);
