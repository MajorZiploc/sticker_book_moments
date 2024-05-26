extends Control
class_name PauseMenuComponent

@onready var qte_type_option_btn: OptionButton = $tabs/settings/vbox/qte_type/selector;
@onready var screen_mode_option_btn: OptionButton = $tabs/settings/vbox/fullscreen_toggle/box/selector;
@onready var difficulty_option_btn: OptionButton = $tabs/settings/vbox/difficulty/selector;
@onready var mobile_checkbox: CheckBox = $tabs/settings/vbox/mobile/checkbox;
@onready var music_checkbox: CheckBox = $tabs/settings/vbox/music/checkbox;

var confirm_bg_panel: PanelContainer;
var confirm_panel: PanelContainer;

func _ready():
  var qte_type_option_popup = qte_type_option_btn.get_popup();
  qte_type_option_popup.connect("id_pressed", on_qte_type_option_popup_pressed);
  qte_type_option_btn.selected = Lang.dict_get(AppState.data, [Constants.options, "qte_mode"], -1);
  var difficulty_option_popup = difficulty_option_btn.get_popup();
  difficulty_option_popup.connect("id_pressed", on_difficulty_option_popup_pressed);
  difficulty_option_btn.selected = Lang.dict_get(AppState.data, [Constants.options, "difficulty"], -1);
  var screen_mode_option_popup = screen_mode_option_btn.get_popup();
  screen_mode_option_popup.connect("id_pressed", on_screen_mode_option_popup_pressed);
  screen_mode_option_btn.selected = Lang.dict_get(AppState.data, [Constants.options, "window_mode"], -1);
  var is_mobile = Lang.dict_get(AppState.data, [Constants.options, "is_mobile"], false);
  var music_on = Lang.dict_get(AppState.data, [Constants.options, "music", "bg", "on"], true);
  mobile_checkbox.button_pressed = is_mobile;
  music_checkbox.button_pressed = music_on;
  mobile_checkbox.connect("toggled", _on_mobile_checkbox_toggled);
  music_checkbox.connect("toggled", _on_music_checkbox_toggled);

func on_cancel_quit():
  confirm_bg_panel.queue_free();
  confirm_panel.queue_free();

func on_confirm_quit():
  if OSHelper.is_web(): SceneSwitcher.change_scene("res://scenes/title_scene.tscn", {})
  else: get_tree().quit();

func _on_back_button_up():
  queue_free();

func on_difficulty_option_popup_pressed(difficulty):
  AppState.insert_data(Constants.options, { "difficulty": difficulty });
  AppState.save_session();

func on_qte_type_option_popup_pressed(qte_mode):
  AppState.insert_data(Constants.options, { "qte_mode": qte_mode });
  AppState.save_session();

func on_screen_mode_option_popup_pressed(window_mode):
  OptionsHelper.set_window_mode(window_mode);
  AppState.insert_data(Constants.options, { "window_mode": window_mode });
  AppState.save_session();

func _on_quit_button_up():
  confirm_bg_panel = PanelContainer.new();
  confirm_bg_panel.custom_minimum_size = Vector2(1400, 900)
  confirm_panel = PanelContainer.new()
  confirm_panel.anchor_left = 0.5
  confirm_panel.anchor_top = 0.35
  confirm_panel.anchor_right = 0.37
  confirm_panel.anchor_bottom = 0.5
  var vbox = VBoxContainer.new();
  confirm_panel.theme_type_variation = &"PanelMediumSticker";
  var label = Label.new();
  label.text = "Are you sure?"
  label.theme_type_variation = &"HeaderMedium";
  var btn_hbox = HBoxContainer.new();
  var cancel_btn = Button.new();
  cancel_btn.text = "No";
  cancel_btn.connect("button_up", on_cancel_quit);
  var spacer = Control.new();
  var confirm_btn = Button.new();
  confirm_btn.text = "Yes";
  confirm_btn.connect("button_up", on_confirm_quit);
  spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
  btn_hbox.add_child(cancel_btn);
  btn_hbox.add_child(spacer);
  btn_hbox.add_child(confirm_btn);
  vbox.add_child(label);
  vbox.add_child(btn_hbox);
  confirm_panel.add_child(vbox);
  self.add_child(confirm_bg_panel);
  self.add_child(confirm_panel);

func _on_mobile_checkbox_toggled(toggled_on: bool):
  OptionsHelper.set_is_mobile(toggled_on);
  AppState.save_session();

func _on_music_checkbox_toggled(toggled_on: bool):
  OptionsHelper.set_music_on(toggled_on);
  OptionsHelper.sync_music();
  AppState.save_session();
