extends Node2D
class_name TitleScene

@onready var ui = $ui_root/ui;

var pause_menu = null;

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://scenes/choose_char.tscn", {})

func _ready():
  AppState.load_data(AppState.current_data_file_name);
  OptionsHelper.set_options();
  
func _input(event: InputEvent):
  pause_menu = SceneHelper.toggle_pause_menu(event, ui, pause_menu);
  print(pause_menu)
