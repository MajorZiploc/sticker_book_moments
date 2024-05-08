extends Node2D
class_name TitleScene

func _on_play_btn_button_up():
  get_tree().change_scene_to_file("res://lvls/battle_scene.tscn");
