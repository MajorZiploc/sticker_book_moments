extends Node

func set_options():
  set_window_mode(AppState.data.get(Constants.options, {}).get("window_mode", DisplayServer.window_get_mode()));
  set_qte_mode(AppState.data.get(Constants.options, {}).get("qte_mode", BattleSceneHelper.QTEMode.TOUCH if OSHelper.is_mobile() else BattleSceneHelper.QTEMode.BUTTON));

func set_window_mode(window_mode):
  DisplayServer.window_set_mode(window_mode);
  AppState.insert_data(Constants.options, { "window_mode": window_mode });

func set_qte_mode(qte_mode):
  AppState.insert_data(Constants.options, { "qte_mode": qte_mode });
