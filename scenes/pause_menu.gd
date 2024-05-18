extends Node2D

func _on_quit_button_up():
  get_tree().quit();

func _on_back_button_up():
  var scene_path = SceneSwitcher.get_param("return_scene");
  SceneSwitcher.change_scene(scene_path, {});
