extends Node

func process_input(event: InputEvent):
  if event.is_action_pressed("pause"):
    SceneSwitcher.change_scene("res://scenes/pause_menu.tscn", { "return_scene": get_tree().current_scene.scene_file_path });

func toggle_pause_menu(event: InputEvent, parent: Node, pause_menu: Node):
  if event.is_action_pressed("pause"):
    if pause_menu:
      parent.remove_child(pause_menu);
      return null;
    else:
      # TODO: remove the need for return_scene
      # SceneSwitcher.change_scene("res://scenes/pause_menu.tscn", { "return_scene": get_tree().current_scene.scene_file_path });
      var new_pause_menu = preload("res://scenes/pause_menu_component.tscn").instantiate();
      parent.add_child(new_pause_menu);
      return new_pause_menu;
  return pause_menu;
