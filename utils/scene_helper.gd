extends Node

func make_pause_menu():
  var pause_menu = preload("res://scenes/pause_menu_component.tscn").instantiate();
  pause_menu.visible = false;
  return pause_menu;

func toggle_pause_menu_btn(pause_menu: Node) -> bool:
  var visible = not pause_menu.visible;
  pause_menu.visible = visible;
  return visible;

func toggle_pause_menu(event: InputEvent, pause_menu: Node) -> bool:
  var visible = false;
  if event.is_action_pressed("pause"):
    visible = not pause_menu.visible;
    pause_menu.visible = visible;
  return visible;

func fade_in(nodes: Array[Node], tween_time):
  for node in nodes:
    var tween = create_tween();
    node.modulate.a = 0;
    tween.tween_property(node, "modulate:a", 1, tween_time).set_trans(Tween.TRANS_EXPO);
