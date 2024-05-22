extends Node2D

@onready var ui = $ui_root/ui;

var pause_menu: Node;

func _ready():
  var scene_tween_time = Constants.std_tween_time;
  SceneHelper.fade_in([self, ui], scene_tween_time);
  pause_menu = SceneHelper.make_pause_menu();
  AppState.insert_data(Constants.metrics, {
    "game_completion_count": AppState.data.get(Constants.metrics, {}).get("game_completion_count", 0) + 1,
  });
  ui.add_child(pause_menu);
  await get_tree().create_timer(scene_tween_time).timeout;

func _input(event: InputEvent):
  var visible_ = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible_: return;

func _on_back_to_title_screen_btn_button_up():
  # TODO: add fate out
  SceneSwitcher.change_scene("res://scenes/title_scene.tscn", {})

func _on_options_btn_button_up():
  SceneHelper.toggle_pause_menu_btn(pause_menu);

func _on_stats_btn_button_up():
  pass # Replace with function body.
