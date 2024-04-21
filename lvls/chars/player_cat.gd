extends CharacterBody2D

# @export makes this variable available in the inspect tab
@export var move_speed: float = 100;
@export var starting_direction: Vector2 = Vector2(0, 1);
@export var source_color = Color(ColorPalette.get_color(0));
@export var target_color = Color(ColorPalette.get_color(1));

@onready var state_machine = $AnimationTree.get("parameters/playback");
@onready var bg_egg = $bg_egg;

func _ready():
  update_animation_parameters(starting_direction);
  var image: Image = $Sprite2D.texture.get_image();
  $Sprite2D.texture = ReplaceColor.change_color(image, source_color, target_color);

func _physics_process(_delta):
  var input_direction = Vector2(
    Input.get_action_strength("right") - Input.get_action_strength("left")
    , Input.get_action_strength("down") - Input.get_action_strength("up")
  );
  # print(input_direction)
  update_animation_parameters(input_direction);
  velocity = input_direction * move_speed;
  move_and_slide();
  pick_new_state();
  
func update_animation_parameters(move_input: Vector2):
  if (move_input != Vector2.ZERO):
    $AnimationTree.set("parameters/Walk/blend_position", move_input)
    $AnimationTree.set("parameters/Idle/blend_position", move_input)
  
func pick_new_state():
  if (velocity != Vector2.ZERO):
    state_machine.travel("Walk");
    bg_egg.visible = false;
  else:
    state_machine.travel("Idle");
    bg_egg.visible = true;
