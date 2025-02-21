extends Node

var id_index := 0

func reset_id() -> void:
	id_index = 0
	
func generate_id() -> int:
	id_index += 1
	return id_index

func print_card(text: String, card: Dictionary) -> void:
	print_rich(text + " [color=%s]" % Globals.get_color_str(card.color).to_lower() + Globals.get_value_str(card.value))
	
func player_card_by_id(card_id: int) -> Dictionary:
	return Game.get_user_hand()[Game.get_user_hand().find_custom(func(card): return card.id == card_id)]

func find(array: Array, method: Callable):
	return array[array.find_custom(method)]

func get_ai_difficulty_text(enemy_level: int) -> String:
	var enemy_level_str = ""
	match enemy_level:
		0:
			enemy_level_str = "Easy"
		1:
			enemy_level_str = "Medium"
		2:
			enemy_level_str = "Hard"
		3:
			enemy_level_str = "Insane"
	return enemy_level_str

func get_color_str(color: int) -> String:
	var colors = [
		"Red",
		"Yellow",
		"Green",
		"Blue",
		"Rose",
		"Orange",
		"Cyan",
		"Purple",
		"Black",
	]
	return colors[color]

func get_short_value_str(value: int) -> String:
	var values = [
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"0",
		"R",
		"S",
		"+2",
		"Wild",
		"W +2",
		"W +4",
		"W +6",
		"W +8",
		"W +10",
		"Reverse +4",
		"W Skip",
		"2x Skip",
		"Skip All",
	]
	return values[value]

func get_value_str(value: int) -> String:
	var values = [
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"0",
		"Reverse",
		"Skip",
		"Draw Two",
		"Wild",
		"Wild Draw Two",
		"Wild Draw Four",
		"Wild Draw Six",
		"Wild Draw Eight",
		"Wild Draw Ten",
		"Wild Reverse Draw Four",
		"Wild Skip",
		"Double Skip",
		"Skip All",
	] 
	return values[value]

func get_card_texture(card: Dictionary) -> int:
	var card_index := 1
	var card_color = card.color
	var card_value = card.value
	
	if card_color == -1:
		card_index += (184 + card_value)
	else:
		card_index += ((card_color * 23) + card_value)
	return card_index

func animate_card_float(self_: Node, start_size: float, height: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self_, "position:y", -height , 0.15)
	tween.parallel().tween_property(self_, "size:y", start_size + height, 0.15)

func animate_card_scale(self_: Node, scale_: float) -> void:
	var hover_size := Vector2(scale_, scale_)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self_, "scale", hover_size, 0.1)

func sort_card_color(a, b) -> bool:
	return a["value"] < b["value"] if a["color"] == b["color"] else a["color"] < b["color"]

func sort_card_value(a, b) -> bool:
	var a_val = a["value"]
	var b_val = b["value"]
	var a_color = a["color"]
	var b_color = b["color"]
	
	# Handle black cards first (-1 color)
	if a_color == -1 and b_color != -1:
		return true  # a goes to back
	elif a_color != -1 and b_color == -1:
		return false  # b goes to back
	elif a_color == -1 and b_color == -1:
		return a_val < b_val  # both black, sort by value
		
	# Check value ranges
	var a_in_range = a_val >= 0 and a_val <= 9
	var b_in_range = b_val >= 0 and b_val <= 9
	
	# If values are different
	if a_val != b_val:
		# If one is >9 and other is 0-9, >9 comes first
		if !a_in_range and b_in_range:
			return true  # b (0-9) goes after
		elif a_in_range and !b_in_range:
			return false  # a (0-9) goes after
		elif a_in_range and b_in_range:
			# Both are number cards (0-9), handle 0 specially
			if a_val == 0:
				return true  # 0 comes first
			elif b_val == 0:
				return false  # 0 comes first
			else:
				return a_val < b_val  # normal number sorting
		else:
			return a_val < b_val  # special card sorting
	
	# If values are the same, sort by color
	return a_color < b_color


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var is_windows := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_windows else DisplayServer.WINDOW_MODE_WINDOWED)
