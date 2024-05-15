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

