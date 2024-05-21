extends Node

func find_index(pred, lst: Array):
  for i in lst.size():
    var el = lst[i];
    if pred.call(el):
      return i;
  return -1;
