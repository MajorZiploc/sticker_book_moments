extends Node

func set_options():
  set_window_mode(AppState.data.get(Constants.options, {}).get("window_mode", DisplayServer.window_get_mode()));
  var is_mobile = AppState.data.get(Constants.options, {}).get("is_mobile", false);
  set_qte_mode(AppState.data.get(Constants.options, {}).get("qte_mode", BattleSceneHelper.QTEMode.TOUCH if is_mobile else BattleSceneHelper.QTEMode.BUTTON));
  set_music_on(AppState.data.get(Constants.options, {}).get("music", {}).get("bg", {}).get("on", true));

func set_window_mode(window_mode):
  DisplayServer.window_set_mode(window_mode);
  AppState.insert_data(Constants.options, { "window_mode": window_mode });

func set_qte_mode(qte_mode):
  AppState.insert_data(Constants.options, { "qte_mode": qte_mode });

func set_is_mobile(is_mobile):
  AppState.insert_data(Constants.options, { "is_mobile": is_mobile });

func set_music_on(music_on):
  AppState.insert_data(Constants.options, { "music": { "bg": { "on": music_on } } });

func sync_music():
  var music: AudioStreamPlayer2D = AppState.dirty_data.get("music", {}).get("bg", {}).get("audio_stream_player_2d", null);
  if not music: return;
  if AppState.data.get(Constants.options, {}).get("music", {}).get("bg", {}).get("on", true):
    music.play();
  else:
    music.stop();
