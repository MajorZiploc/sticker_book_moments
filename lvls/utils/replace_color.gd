extends Node


func change_color(image: Image, source_color: Color, target_color: Color):
  #image.lock()
  for y in image.get_height():
    for x in image.get_width():
      if image.get_pixel(x, y) == source_color:
         image.set_pixel(x, y, target_color)
  #image.unlock();
  var texture = ImageTexture.create_from_image(image);
  return texture;
