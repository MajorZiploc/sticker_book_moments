extends Node

func set_options():
  set_window_mode(AppState.data.get("options", {}).get("window_mode", DisplayServer.window_get_mode()));
  set_qte_modes(AppState.data.get("options", {}).get("qte_modes", [BattleSceneHelper.QTEType.TOUCH] if OSHelper.is_mobile() else BattleSceneHelper.QTEType.keys()));

func set_window_mode(new_window_mode):
  var window_mode = (
    DisplayServer.WINDOW_MODE_WINDOWED if new_window_mode == DisplayServer.WINDOW_MODE_WINDOWED
    else DisplayServer.WINDOW_MODE_FULLSCREEN
  );
  DisplayServer.window_set_mode(window_mode);
  AppState.insert_data("options", { "window_mode": window_mode });

func set_qte_modes(qte_modes: Array):
  AppState.insert_data("options", { "qte_modes": qte_modes });
