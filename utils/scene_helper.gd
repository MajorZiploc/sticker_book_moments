extends Node

func process_input(event: InputEvent):
  if event.is_action_pressed("pause"):
    SceneSwitcher.change_scene("res://scenes/pause_menu.tscn", {});
