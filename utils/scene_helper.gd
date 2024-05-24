extends Node

func make_pause_menu():
  var pause_menu = preload("res://scenes/pause_menu_component.tscn").instantiate();
  return pause_menu;

func make_stats_page():
  var stats_page = preload("res://scenes/stats_page.tscn").instantiate();
  stats_page.visible = false;
  return stats_page;

func toggle_node(node: Node) -> bool:
  var visible = not node.visible;
  node.visible = visible;
  return visible;

func fade_in(nodes: Array[Node], tween_time):
  for node in nodes:
    var tween = create_tween();
    node.modulate.a = 0;
    tween.tween_property(node, "modulate:a", 1, tween_time).set_trans(Tween.TRANS_EXPO);
