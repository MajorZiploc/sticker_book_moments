extends Node2D
class_name TitleScene

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://lvls/battle_scene.tscn", {})
