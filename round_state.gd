extends Node

#rules
@export var draw_limit: int
@export var starting_card_count: int
@export var stacking_enabled: bool
@export var ai_difficulty: int

@export var color_count: int
@export var numbered_card_count: int
@export var zero_card_count: int
@export var action_card_count: int
@export var wild_card_count: int
@export var wild_special_card_count: int

@export var discard_pile: Array

@export var player_count: int
@export var players: Array

@export var turn: int
@export var turn_direction: int
@export var turn_count: int
@export var deck: Array

@export var winning_player: Dictionary
@export var money_to_earn: int
@export var round_active := false
@export var user_draw_count := 0

func reset_round():
	draw_limit = 0
	starting_card_count = 0
	stacking_enabled = 0
	ai_difficulty = 0

	color_count = 0
	numbered_card_count = 0
	zero_card_count = 0
	action_card_count = 0
	wild_card_count = 0
	wild_special_card_count = 0

	discard_pile = []

	player_count = 0
	players = []
	turn = 0
	turn_direction = 1
	turn_count = 0
	deck = []

	money_to_earn = 0

func create_card(color: int, value: int) -> Dictionary:
	var reverse_count := 0
	var skip_count := 0
	var draw_count := 0
	var is_wild := false
	
	match value:
		10:
			#Reverse
			reverse_count = 1
		11:
			#Skip
			skip_count = 1
		12:
			#Draw 2
			draw_count = 2
		13:
			#Wild
			is_wild = true
		14:
			#Wild draw 2
			is_wild = true
			draw_count = 2
		15:
			#Wild draw 4
			is_wild = true
			draw_count = 4
		16:
			#Wild draw 6
			is_wild = true
			draw_count = 6
		17:
			#Wild draw 8
			is_wild = true
			draw_count = 8
		18:
			#Wild draw 10
			is_wild = true
			draw_count = 10
		19:
			#Wild draw 4 Reverse
			is_wild = true
			reverse_count = 1
			draw_count = 4
		20:
			#Wild skip
			is_wild = true
			skip_count = 1
		21:
			#Duble Skip
			skip_count = 2
		22:
			#Skip All
			skip_count = Round.players.size() -1
	
	var card =	{ 
		id = Globals.generate_id(),
		color = color, 
		value = value,
		reverse_count = reverse_count,
		skip_count = skip_count,
		draw_count = draw_count,
		is_wild = is_wild,
		rotation = deg_to_rad(randf_range(-15, 15)), 
		position = Vector2(randf_range(-3, 3), randf_range(-3, 3))
	}
	return card

func is_player_turn() -> bool:
	return false

func get_user() -> Dictionary:
	return players[0]

func get_next_player() -> Dictionary:
	var new_turn = turn
	new_turn += turn_direction
	if new_turn >= players.size():
		new_turn = 0
	elif new_turn < 0:
		new_turn = players.size() - 1
	return players[new_turn]

func get_current_player() -> Dictionary:
	return players[turn]

func reverse_direction():
	turn_direction *= -1

func start_turn():
	turn = randi_range(0, players.size() - 1)

func advance_turn() -> void:
	turn += turn_direction
	if turn >= players.size():
		turn = 0
	elif turn < 0:
		turn = players.size() - 1
	turn_count += 1

func create_player(player_name: String, id: int, is_user: bool) -> void:
	var new_player = {name = player_name, is_user = is_user, id = id, hand = []}
	players.append(new_player)

func can_play(card: Dictionary) -> bool:
	return card.color == get_discard_color() || card.value == get_discard_value() || card.color == -1

func get_discard_card() -> Dictionary:
	return discard_pile[discard_pile.size() - 1]

func get_discard_color() -> int:
	return get_discard_card().color

func get_discard_value() -> int:
	return get_discard_card().value

func change_discard_color(color: int) -> void:
	get_discard_card().color = color
