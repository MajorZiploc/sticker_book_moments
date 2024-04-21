extends CharacterBody2D

enum COW_STATE { IDLE, WALK };

@export var move_speed: float = 30;
@export var idle_time: float = 5;
@export var walk_time: float = 2;

@onready var state_machine = $AnimationTree.get("parameters/playback");

var move_direction: Vector2 = Vector2.ZERO;
var current_state: COW_STATE = COW_STATE.IDLE;

func _ready():
  pick_new_state();

func _physics_process(delta):
  if (current_state != COW_STATE.WALK): return
  velocity = move_direction * move_speed;
  move_and_slide();
  
func select_new_direction():
  move_direction = Vector2(
    randi_range(-1, 1)
    , randi_range(-1, 1)
  );
  if (move_direction.x != 0):
    $Sprite2D.flip_h = move_direction.x < 0;

func pick_new_state():
  if (current_state == COW_STATE.IDLE):
    state_machine.travel("walk_right");
    current_state = COW_STATE.WALK;
    select_new_direction();
    $Timer.start(walk_time);
  elif (current_state == COW_STATE.WALK):
    state_machine.travel("idle_right");
    current_state = COW_STATE.IDLE;
    select_new_direction();
    $Timer.start(idle_time);

func _on_timer_timeout():
  pick_new_state();
