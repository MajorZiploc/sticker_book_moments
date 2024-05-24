extends Node2D
class_name TitleScene

@onready var ui = $ui_root/ui;
@onready var mobile_checkbox: CheckBox = $ui_root/ui/mobile/checkbox;

var pause_menu: Node;
var stats_page: Node;

func _on_play_btn_button_up():
  SceneSwitcher.change_scene("res://scenes/choose_char.tscn", {})

func _ready():
  var scene_tween_time = Constants.std_tween_time;
  SceneHelper.fade_in([self, ui], scene_tween_time);
  stats_page = SceneHelper.make_stats_page();
  AppState.load_data(AppState.current_data_file_name);
  var is_mobile = AppState.data.get(Constants.options, {}).get("is_mobile", OSHelper.is_mobile());
  OptionsHelper.set_is_mobile(is_mobile);
  OptionsHelper.set_options();
  mobile_checkbox.button_pressed = is_mobile;
  ui.add_child(stats_page);
  AppState.save_session();
  await get_tree().create_timer(scene_tween_time).timeout;
  
func _on_options_btn_button_up():
  if not pause_menu:
    pause_menu = SceneHelper.make_pause_menu();
    ui.add_child(pause_menu);
  else:
    ui.remove_child(pause_menu);
    pause_menu = null;

func _on_stats_btn_button_up():
  SceneHelper.toggle_node(stats_page);

func _on_mobile_checkbox_toggled(toggled_on: bool):
  OptionsHelper.set_is_mobile(toggled_on);
  OptionsHelper.set_qte_mode(BattleSceneHelper.QTEMode.TOUCH if toggled_on else BattleSceneHelper.QTEMode.BUTTON);
  AppState.save_session();
