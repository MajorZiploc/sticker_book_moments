extends Control
class_name PauseMenuComponent

@onready var qte_type_option_btn: OptionButton = $tabs/settings/vbox/qte_type/selector;
@onready var screen_mode_option_btn: OptionButton = $tabs/settings/vbox/fullscreen_toggle/box/selector;
@onready var mobile_checkbox: CheckBox = $tabs/settings/vbox/mobile/checkbox;
@onready var music_checkbox: CheckBox = $tabs/settings/vbox/music/checkbox;

func _ready():
  var qte_type_option_popup = qte_type_option_btn.get_popup();
  qte_type_option_popup.connect("id_pressed", on_qte_type_option_popup_pressed);
  qte_type_option_btn.selected = AppState.data.get(Constants.options, {}).get("qte_mode", -1);
  var screen_mode_option_popup = screen_mode_option_btn.get_popup();
  screen_mode_option_popup.connect("id_pressed", on_screen_mode_option_popup_pressed);
  screen_mode_option_btn.selected = AppState.data.get(Constants.options, {}).get("window_mode", -1);
  var is_mobile = AppState.data.get(Constants.options, {}).get("is_mobile", false);
  var music_on = AppState.data.get(Constants.options, {}).get("music", {}).get("bg", {}).get("on", true)
  mobile_checkbox.button_pressed = is_mobile;
  music_checkbox.button_pressed = music_on;
  mobile_checkbox.connect("toggled", _on_mobile_checkbox_toggled);
  music_checkbox.connect("toggled", _on_music_checkbox_toggled);

func _on_back_button_up():
  queue_free();

func on_qte_type_option_popup_pressed(qte_mode):
  AppState.insert_data(Constants.options, { "qte_mode": qte_mode });
  AppState.save_session();

func on_screen_mode_option_popup_pressed(window_mode):
  OptionsHelper.set_window_mode(window_mode);
  AppState.insert_data(Constants.options, { "window_mode": window_mode });
  AppState.save_session();

func _on_quit_button_up():
  if OSHelper.is_web(): SceneSwitcher.change_scene("res://scenes/title_scene.tscn", {})
  else: get_tree().quit();

func _on_mobile_checkbox_toggled(toggled_on: bool):
  OptionsHelper.set_is_mobile(toggled_on);
  AppState.save_session();

func _on_music_checkbox_toggled(toggled_on: bool):
  OptionsHelper.set_music_on(toggled_on);
  OptionsHelper.sync_music();
  AppState.save_session();
