extends Node2D
class_name TitleScene

@onready var ui = $ui_root/ui;

var pause_menu: Node;

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://scenes/choose_char.tscn", {})

func _ready():
  self.modulate.a = 0;
  ui.modulate.a = 0;
  var scene_tween_time = Constants.std_tween_time;
  var scene_tween = create_tween();
  scene_tween.tween_property(self, "modulate:a", 1, scene_tween_time).set_trans(Tween.TRANS_EXPO);
  var ui_tween_time = Constants.std_tween_time;
  var ui_tween = create_tween();
  ui_tween.tween_property(ui, "modulate:a", 1, ui_tween_time).set_trans(Tween.TRANS_EXPO);
  pause_menu = SceneHelper.make_pause_menu();
  AppState.load_data(AppState.current_data_file_name);
  OptionsHelper.set_options();
  ui.add_child(pause_menu);
  await get_tree().create_timer(max(scene_tween_time, ui_tween_time)).timeout;
  
func _input(event: InputEvent):
  var visible_ = SceneHelper.toggle_pause_menu(event, pause_menu);
  if visible_: return;

func _on_options_btn_button_up():
  SceneHelper.toggle_pause_menu_btn(pause_menu);
