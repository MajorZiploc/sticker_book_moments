extends Control
class_name StatsPage

@onready var items_used_value: Label = $stats_panel/vbox/items_used/value;
@onready var parries_value: Label = $stats_panel/vbox/parries/value;
@onready var battle_wins_value: Label = $stats_panel/vbox/battle_wins/value;
@onready var battle_lost_value: Label = $stats_panel/vbox/battle_lost/value;
@onready var game_completions_value: Label = $stats_panel/vbox/game_completions/value;

func _ready():
  # AppState.load_data(AppState.current_data_file_name); # NOTE: REMOVE THIS LINE
  var metrics = AppState.data.get(Constants.metrics, {});
  var used_items = metrics.get("used_items", {});
  var total_items_used = 0;
  for key in used_items.keys():
    var entry = used_items[key];
    total_items_used = total_items_used + entry;
  items_used_value.text = str(total_items_used);
  var parries = metrics.get("parries", {});
  parries_value.text = str(parries.get("perfect", 0));
  var battle_results = metrics.get("battle_results", {});
  battle_wins_value.text = str(battle_results.get("wins", 0));
  battle_lost_value.text = str(battle_results.get("loses", 0));
  var game_completion = metrics.get("game_completion", {});
  game_completions_value.text = str(game_completion.get("count", 0));

func _on_close_btn_button_up():
  visible = false;
