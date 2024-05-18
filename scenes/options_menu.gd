extends Node2D

func _on_back_button_up():
  SceneSwitcher.change_scene("res://scenes/pause_menu.tscn", SceneSwitcher.get_params());

func _on_test_button_up():
  DisplayServer.window_set_mode(
    DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED
    else DisplayServer.WINDOW_MODE_WINDOWED
  );
