extends Node

func is_mobile():
  # TODO: test this on mobile devices. the OS.has_feature should be enough. the rest likely isnt needed
  var os_name = OS.get_name();
  return OS.has_feature("mobile") or os_name == "Android" or os_name == "iOS";
