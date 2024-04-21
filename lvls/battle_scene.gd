extends Node2D

@onready var battle_char_left = $battle_char_left;
@onready var battle_char_right = $battle_char_right;

# Called when the node enters the scene tree for the first time.
func _ready():
  var texture = preload("res://art/my/chars/berserk_axer.png");
  if texture and texture is Texture:
    battle_char_right.sprite.texture = texture;
  # battle_char_right.sprite.vframes = 4;
  battle_char_left.sprite.flip_h = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass
