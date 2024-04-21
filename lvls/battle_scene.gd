extends Node2D

@onready var battle_char_left = $battle_char_left;

# Called when the node enters the scene tree for the first time.
func _ready():
  var texture = preload("res://art/Sprout Lands - Sprites - Basic pack/Characters/Basic Charakter Spritesheet.png");
  if texture and texture is Texture:
    battle_char_left.sprite.texture = texture;
    battle_char_left.sprite.vframes = 4;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass
