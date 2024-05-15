extends Node

var palette = [
  Color('#f3f2c0'),
  Color('#11d5d1'),
];

func get_color(idx: int):
  return palette[idx % palette.size()];
