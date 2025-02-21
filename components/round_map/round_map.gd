extends Control

var options := []
var option_scene = preload("res://components/round_map/round_map_option.tscn")

@onready var option_container := %RoundOptionContainer

signal update_map_view(state: int)

enum RoundType {
	SMALL,
	BIG,
	BOSS
}

const ROUND_CONFIGS = {
	RoundType.SMALL: {
		Game.Difficulty.EASY: {
			enemy_count_range = [1, 1],
			ai_difficulty = 0,
			color_count = 4,
			money_range = [1, 4],
			options_count = 2,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 0
		},
		Game.Difficulty.MEDIUM: {
			enemy_count_range = [1, 2],
			ai_difficulty = 1,
			color_count = 4,
			money_range = [2, 5],
			options_count = 2,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 0
		},
		Game.Difficulty.HARD: {
			enemy_count_range = [2, 2],
			ai_difficulty = 2,
			color_count = 4,
			money_range = [3, 6],
			options_count = 3,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		},
		Game.Difficulty.INSANE: {
			enemy_count_range = [2, 3],
			ai_difficulty = 3,
			color_count = 6,
			money_range = [4, 8],
			options_count = 3,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		}
	},
	RoundType.BIG: {
		Game.Difficulty.EASY: {
			enemy_count_range = [2, 3],
			ai_difficulty = 0,
			color_count = 4,
			money_range = [3, 6],
			options_count = 2,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		},
		Game.Difficulty.MEDIUM: {
			enemy_count_range = [3, 4],
			ai_difficulty = 1,
			color_count = 4,
			money_range = [4, 7],
			options_count = 2,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		},
		Game.Difficulty.HARD: {
			enemy_count_range = [4, 6],
			ai_difficulty = 2,
			color_count = 6,
			money_range = [5, 9],
			options_count = 3,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		},
		Game.Difficulty.INSANE: {
			enemy_count_range = [5, 8],
			ai_difficulty = 3,
			color_count = 8,
			money_range = [6, 12],
			options_count = 3,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		}
	},
	RoundType.BOSS: {
		Game.Difficulty.EASY: {
			enemy_count_range = [1, 1],
			ai_difficulty = 1,
			color_count = 4,
			money_range = [5, 8],
			options_count = 1,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		},
		Game.Difficulty.MEDIUM: {
			enemy_count_range = [1, 2],
			ai_difficulty = 2,
			color_count = 6,
			money_range = [6, 10],
			options_count = 1,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		},
		Game.Difficulty.HARD: {
			enemy_count_range = [1, 2],
			ai_difficulty = 2,
			color_count = 8,
			money_range = [8, 12],
			options_count = 2,
			draw_limit = [3,5],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 2,
			action_card_count = 4,
			zero_card_count = 1,
			wild_card_count = 4,
			wild_special_card_count = 2
		},
		Game.Difficulty.INSANE: {
			enemy_count_range = [2, 3],
			ai_difficulty = 3,
			color_count = 8,
			money_range = [10, 15],
			options_count = 1,
			draw_limit = [0,2],
			stacking_enabled = true,
			starting_card_count = 7,
			numbered_card_count = 3,
			action_card_count = 6,
			zero_card_count = 2,
			wild_card_count = 8,
			wild_special_card_count = 4
		}
	}
}

func _ready() -> void:
	# Clear existing options
	for child in option_container.get_children():
		child.call_deferred("free")
	
	Game.game_round += 1
	Game.round_type += 1
	if Game.round_type > 3:
		Game.round_type = 1
	
	# Determine round type
	var round_type: RoundType
	if Game.game_round % 3 == 0:
		round_type = RoundType.BOSS
		emit_signal("update_map_view", 3)
	elif Game.game_round % 2 == 0:
		round_type = RoundType.BIG
		emit_signal("update_map_view", 2)
	else:
		round_type = RoundType.SMALL
		emit_signal("update_map_view", 1)
	
	var config = ROUND_CONFIGS[round_type][Game.difficulty]
	options = generate_round_options(config)
	
	for option in options:
		var option_obj = option_scene.instantiate()
		option_obj.option = option
		option_obj.round_chosen.connect(Callable(_on_option_round_chosen))
		option_container.add_child(option_obj)

func generate_round_options(config: Dictionary) -> Array:
	var round_options := []
	
	for i in range(config.options_count):
		var option = {
			id = i,
			ai_difficulty = config.ai_difficulty,
			enemy_count = randi_range(config.enemy_count_range[0], config.enemy_count_range[1]),
			color_count = config.color_count,
			stacking_enabled = config.stacking_enabled,
			earned_money = randi_range(config.money_range[0], config.money_range[1]),
			draw_limit = randi_range(config.draw_limit[0], config.draw_limit[1]),
			starting_card_count = config.starting_card_count,
			numbered_card_count = config.numbered_card_count,
			zero_card_count = config.zero_card_count,
			action_card_count = config.action_card_count,
			wild_card_count = config.wild_card_count,
			wild_special_card_count = config.wild_special_card_count
		}
		round_options.append(option)
	
	return round_options

var round_scene := "res://components/game/game.tscn"

func init_deck() -> Array:
	var deck = []
	
	for i in Round.numbered_card_count:
		for c in Round.color_count:
			for v in 13:
				if v < 9:
					deck.append(Round.create_card(c, v))#1-9

	for i in Round.action_card_count:
		for c in Round.color_count:
			for v in 13:
				if v > 9 && v < 13:
					deck.append(Round.create_card(c, v)) #Skip,Reverse,Draw2

	for i in Round.zero_card_count:
		for c in Round.color_count:
			deck.append(Round.create_card(c, 9)) #0

	for i in Round.wild_card_count:
		deck.append(Round.create_card(-1, 13)) #Wild
		deck.append(Round.create_card(-1, 15)) #Wild Draw 4
	
	for i in Round.wild_special_card_count:
		deck.append(Round.create_card(-1, 14)) #Wild Draw 2
		deck.append(Round.create_card(-1, 16)) #Wild Draw 6
		deck.append(Round.create_card(-1, 17)) #Wild Draw 8
		deck.append(Round.create_card(-1, 18)) #Wild Draw 10
		deck.append(Round.create_card(-1, 19)) #Wild Draw 4 Reverse
		deck.append(Round.create_card(-1, 20)) #Wild Skip
	for i in Round.wild_special_card_count:
		for c in Round.color_count:
			deck.append(Round.create_card(c, 21)) #Double Skip
			deck.append(Round.create_card(c, 22)) #Skip All 
		
	Globals.reset_id()
	return deck
	
func init_players() -> void:
	var enemy_names = ["Enemy 1", "Enemy 2", "Enemy 3", "Enemy 4", "Enemy 5", "Enemy 6", "Enemy 7"]
	for i in Round.player_count:
		if i == 0:
			Round.create_player("User", Globals.generate_id() , true)
		else:
			Round.create_player(enemy_names[i - 1], Globals.generate_id(), false)

func _on_option_round_chosen(id):
	Round.reset_round()
	var chosen_option = Globals.find(options, func(option): return option.id == id)
	Round.player_count = 1 + chosen_option.enemy_count
	Round.draw_limit = chosen_option.draw_limit
	Round.starting_card_count = chosen_option.starting_card_count
	Round.stacking_enabled = chosen_option.stacking_enabled
	Round.ai_difficulty = chosen_option.ai_difficulty

	Round.color_count = chosen_option.color_count
	
	Round.numbered_card_count = chosen_option.numbered_card_count
	Round.zero_card_count = chosen_option.zero_card_count
	Round.action_card_count = chosen_option.action_card_count
	Round.wild_card_count = chosen_option.wild_card_count
	Round.wild_special_card_count = chosen_option.wild_special_card_count
	
	Round.money_to_earn = chosen_option.earned_money
	init_players()
	Round.deck = init_deck()
	Round.start_turn()
	Round.advance_turn()
	
	get_tree().change_scene_to_file(round_scene)
