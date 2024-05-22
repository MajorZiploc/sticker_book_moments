extends Node

func make_pause_menu():
  var pause_menu = preload("res://scenes/pause_menu_component.tscn").instantiate();
  pause_menu.visible = false;
  return pause_menu;

func toggle_pause_menu(event: InputEvent, pause_menu: Node) -> bool:
  var visible = false;
  if event.is_action_pressed("pause"):
    visible = not pause_menu.visible;
    pause_menu.visible = visible;
  return visible;
