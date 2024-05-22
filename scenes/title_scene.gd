extends Node2D
class_name TitleScene

@onready var ui = $ui_root/ui;

var pause_menu: Node;

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://scenes/choose_char.tscn", {})

func _ready():
  pause_menu = SceneHelper.make_pause_menu();
  AppState.load_data(AppState.current_data_file_name);
  OptionsHelper.set_options();
  ui.add_child(pause_menu);
  
func _input(event: InputEvent):
  var visible_ = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible_: return;

func _on_options_btn_button_up():
  SceneHelper.toggle_pause_menu_btn(pause_menu);
