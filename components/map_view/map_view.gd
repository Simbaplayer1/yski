extends TextureRect

func _on_round_map_update_map_view(state: int) -> void:
	self.texture = load("res://art/ui/icons/round_map_icons/map_state/map_state_%s.png" % state)
