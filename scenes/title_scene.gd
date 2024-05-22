extends Node2D
class_name TitleScene

@onready var ui = $ui_root/ui;

var pause_menu: Node;

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://scenes/choose_char.tscn", {})

func _ready():
  pause_menu = SceneHelper.make_pause_menu();
  ui.add_child(pause_menu);
  AppState.load_data(AppState.current_data_file_name);
  OptionsHelper.set_options();
  
func _input(event: InputEvent):
  visible = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible: return;
