extends Node2D

@onready var ui = $ui_root/ui;

var pause_menu: Node;

func _ready():
  pause_menu = SceneHelper.make_pause_menu();
  AppState.insert_data(Constants.game_state, {
    "game_completion_count": AppState.data.get(Constants.game_state, {}).get("game_completion_count", 0) + 1,
  });
  ui.add_child(pause_menu);

func _input(event: InputEvent):
  var visible_ = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible_: return;

func _on_back_to_title_screen_btn_button_up():
  # TODO: add fate out
  SceneSwitcher.change_scene("res://scenes/title_scene.tscn", {})

func _on_options_btn_button_up():
  SceneHelper.toggle_pause_menu_btn(pause_menu);
