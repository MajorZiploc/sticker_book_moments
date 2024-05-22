extends Control
class_name PauseMenuComponent

@onready var qte_type_option_btn: OptionButton = $tabs/settings/vbox/qte_type/selector;
@onready var screen_mode_option_btn: OptionButton = $tabs/settings/vbox/fullscreen_toggle/box/selector;

func _ready():
  var qte_type_option_popup = qte_type_option_btn.get_popup();
  qte_type_option_popup.connect("id_pressed", on_qte_type_option_popup_pressed);
  qte_type_option_btn.selected = AppState.data.get("options", {}).get("qte_mode", -1);
  var screen_mode_option_popup = screen_mode_option_btn.get_popup();
  screen_mode_option_popup.connect("id_pressed", on_screen_mode_option_popup_pressed);
  screen_mode_option_btn.selected = AppState.data.get("options", {}).get("window_mode", -1);

func _on_back_button_up():
  self.visible = false;

func on_qte_type_option_popup_pressed(qte_mode):
  AppState.insert_data("options", { "qte_mode": qte_mode });
  AppState.save_session();

func on_screen_mode_option_popup_pressed(window_mode):
  OptionsHelper.set_window_mode(window_mode);
  AppState.insert_data("options", { "window_mode": window_mode });
  AppState.save_session();

func _on_quit_button_up():
  if OSHelper.is_web(): SceneSwitcher.change_scene("res://scenes/title_scene.tscn", {})
  else: get_tree().quit();
