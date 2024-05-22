extends Control
class_name PauseMenuComponent

@onready var qte_type_option_btn: OptionButton = $tabs/options/vbox/qte_type/selector;

func _ready():
  var qte_type_option_popup = qte_type_option_btn.get_popup();
  qte_type_option_popup.connect("id_pressed", on_qte_type_option_popup_pressed);
  qte_type_option_btn.selected = AppState.data.get("options", {}).get("qte_mode", -1);

func _on_back_button_up():
  self.visible = false;

func _on_fullscreen_toggle_button_up():
  var window_mode = (
    DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED
    else DisplayServer.WINDOW_MODE_WINDOWED
  );
  OptionsHelper.set_window_mode(window_mode);
  AppState.insert_data("options", { "window_mode": window_mode });
  AppState.save_session();

func on_qte_type_option_popup_pressed(qte_mode):
  AppState.insert_data("options", { "qte_mode": qte_mode });
  AppState.save_session();

func _on_quit_button_up():
  get_tree().quit();
