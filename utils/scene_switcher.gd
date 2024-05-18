extends Node

# Private variable
var _params = null;

# Call this instead to be able to provide arguments to the next scene
func change_scene(next_scene, params=null):
  _params = params;
  get_tree().change_scene_to_file(next_scene);

# In the newly opened scene, you can get the parameters by name
func get_param(name_):
  if _params != null and _params.has(name_):
    return _params[name_];
  return null;

# In the newly opened scene, you can get all the parameters
func get_params():
  return _params;

# Example usage:
# In the calling scene
# SceneSwitcher.change_scene("map_viewer.tscn", {"location": selected_location})
# In the new scene
# var current_location = SceneSwitcher.get_param("location")
