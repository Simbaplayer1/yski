extends Button

@onready var card_count_text = %CardCountText

var initial_deck_size := 0

var texture_crop_stages := 7

func _ready() -> void:
	initial_deck_size = Round.deck.size()
	
func _on_game_update_deck() -> void:
	var deck_size := Round.deck.size()
	#var percent_remaining := (float(deck_size) / float(initial_deck_size)) * 100
	#texture_crop_stages
	card_count_text.text = var_to_str(deck_size)
