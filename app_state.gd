extends Node

var data_file_name_1 = {"name": "user://01.save"};

var current_data_file_name = data_file_name_1;

var data = {};

func load_data(data_file):
  if FileAccess.file_exists(data_file["name"]):
    var file = FileAccess.open(data_file["name"], FileAccess.READ)
    data = file.get_var();

func save_data(new_app_state, data_file):
  var file = FileAccess.open(data_file["name"], FileAccess.WRITE)
  file.store_var(new_app_state);

func delete_data(data_file):
  DirAccess.remove_absolute(data_file["name"])

func load_session():
  return load_data(current_data_file_name);

func save_session():
  return save_data(data, current_data_file_name);

func delete_session():
  return delete_data(current_data_file_name);

func insert_data(key, data_):
  data[key] = data.get(key, {});
  data[key].merge(data_, true);
