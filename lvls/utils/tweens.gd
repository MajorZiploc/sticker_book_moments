extends Node

func await_tweens(tweens: Array[Tween]):
  for tween in tweens:
    await tween.finished;
