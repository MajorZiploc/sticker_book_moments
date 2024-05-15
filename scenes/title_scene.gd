extends Node2D
class_name TitleScene

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://scenes/choose_char.tscn", {})

func _ready():
  AppState.load_data(AppState.current_data_file_name);
