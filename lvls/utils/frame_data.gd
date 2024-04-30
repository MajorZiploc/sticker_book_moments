extends Node

class AnimateData:
  var tweens: Array[Tween];
  var play;
  var stop;
  func _init(tweens: Array[Tween] = [], play = (func(): return 0), stop = (func(): return 0)):
    self.tweens = tweens;
    self.play = play;
    self.stop = stop;

class Data:
  var animate: AnimateData;
  func _init(animate = AnimateData.new()):
    self.animate = animate;

func take_frame_animation_action(frame_data_dict: Dictionary, frame_type_to_play, actual_frame_type):
  var frame_data: Data = frame_data_dict[actual_frame_type];
  if actual_frame_type == frame_type_to_play:
    frame_data.animate.play.call();
  else:
    frame_data.animate.stop.call();

