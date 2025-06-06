extends Node

func find_index(pred, lst: Array):
  for i in lst.size():
    var el = lst[i];
    if pred.call(el):
      return i;
  return -1;

func dict_get(dict: Dictionary, keys: Array[String], default_value):
  var cur_idx = 0;
  var last_idx = keys.size() - 1;
  var cur_dict = dict if dict else {};
  while cur_idx < last_idx:
    var key = keys[cur_idx];
    cur_dict = cur_dict.get(key, {});
    cur_idx = cur_idx + 1;
  var item = cur_dict.get(keys[cur_idx], default_value);
  var item_type = typeof(item);
  var res = item if (item_type == TYPE_OBJECT and weakref(item).get_ref()) or item_type != TYPE_OBJECT else default_value;
  return res;
