extends HBoxContainer

func _on_play_button_pressed() -> void:
	get_parent().play()

func _on_color_sort_toggled(_toggled_on: bool) -> void:
	get_parent().sort_hand(Game.SortMethod.COLOR)

func _on_value_sort_button_toggled(_toggled_on: bool) -> void:
	get_parent().sort_hand(Game.SortMethod.VALUE)
