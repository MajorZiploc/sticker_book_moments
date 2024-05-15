extends Node

class AnimateData:
  var tweens: Array[Tween];
  var play;
  var stop;
  func _init(tweens_: Array[Tween] = [], play_ = (func(): return 0), stop_ = (func(): return 0)):
    self.tweens = tweens_;
    self.play = play_;
    self.stop = stop_;

class Data:
  var animate: AnimateData;
  func _init(animate_ = AnimateData.new()):
    self.animate = animate_;

