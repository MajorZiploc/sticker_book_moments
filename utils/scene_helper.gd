extends Node

func toggle_pause_menu(event: InputEvent, parent: Node, pause_menu: Node):
  if event.is_action_pressed("pause"):
    if pause_menu:
      parent.remove_child(pause_menu);
      return null;
    else:
      var new_pause_menu = preload("res://scenes/pause_menu_component.tscn").instantiate();
      parent.add_child(new_pause_menu);
      return new_pause_menu;
  return pause_menu;
