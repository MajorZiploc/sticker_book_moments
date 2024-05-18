extends Node

func set_options():
  set_window_mode(AppState.data.get('options', {}).get('window_mode', DisplayServer.window_get_mode()));

func set_window_mode(new_window_mode):
  var window_mode = (
    DisplayServer.WINDOW_MODE_WINDOWED if new_window_mode == DisplayServer.WINDOW_MODE_WINDOWED
    else DisplayServer.WINDOW_MODE_FULLSCREEN
  );
  DisplayServer.window_set_mode(window_mode);
  AppState.insert_data('options', { 'window_mode': window_mode });
