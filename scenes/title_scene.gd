extends Node2D
class_name TitleScene

@onready var s = $Sprite2D;
# need this rect to be offset based on where the sprite is. as of nwo, it just tells me the size of the sprite

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://scenes/choose_char.tscn", {})

func _ready():
  AppState.load_data(AppState.current_data_file_name);
  OptionsHelper.set_options();
  print(s.get_rect());
  s.scale = Vector2(0.7, 0.7);
  
  
func _input(event: InputEvent):
  if event.is_action_pressed("tap"):

    # Get the size of the sprite
    var rect_size = s.get_texture().get_size() * s.scale
    # Get the global position of the sprite
    var sprite_position = s.global_position - (Vector2(80, 80) * s.scale);
    # Create a new Rect2 using the sprite's position and size
    var sprite_rect = Rect2(sprite_position, rect_size)
    
    # print('s.get_rect()')
    # print(s.get_rect())
    print('event.position')
    print(event.position)
    print('sprite_rect')
    print(sprite_rect)
    print('to_local(event.position)')
    print(to_local(event.position))
    print('make_input_local(event).position')
    print(make_input_local(event).position) # THIS IS IT!!
    if sprite_rect.has_point(make_input_local(event).position):
      print('hit')
  SceneHelper.process_input(event);

func _draw():
  # Get the size of the sprite
  var rect_size = s.get_texture().get_size() * s.scale
  # Get the global position of the sprite
  var sprite_position = s.global_position - (Vector2(80, 80) * s.scale);
  # Create a new Rect2 using the sprite's position and size
  var sprite_rect = Rect2(sprite_position, rect_size)
  
  print('left press')
  print('s.get_rect()')
  print(s.get_rect())
  draw_rect(sprite_rect, Color(1, 0, 0, 0.5))

func _on_animatable_body_2d_mouse_entered():
  print('entered')


func _on_animatable_body_2d_mouse_shape_entered(shape_idx):
  print('entered shape')


func _on_animatable_body_2d_input_event(viewport, event, shape_idx):
  print('input event')


