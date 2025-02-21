extends Control

signal update_deck

signal update_user_hand
signal update_user_action(user_turn: bool)
signal animate_user_cards(cards: Array)
signal show_draw_alert

signal init_enemy_list
signal update_enemy_list
signal update_enemy_hand
signal animate_enemy_cards(cards: Array)

signal add_to_discard_pile(card: Dictionary)
signal update_discard_color(color: int)
signal reset_discard_pile

signal play_animation(animation: Game.Animations)
signal play_enemy_animation(animation: Game.Animations, enemy: Dictionary)

signal add_event(event: Dictionary)
signal show_color_picker

signal init_deck_modal_deck(deck: Array)
signal init_deck_modal_width

var temp_user_played_cards := []

func _ready() -> void:
	init_game()

func init_game() -> void:
	Round.round_active = true
	var initial_deck = Round.deck.duplicate()
	emit_signal("init_deck_modal_deck", initial_deck)
	Round.deck.shuffle()
	init_hands()
	init_discard_pile()
	emit_signal("init_enemy_list")
func init_hands() -> void:
	for player in Round.players:
		for i in Round.starting_card_count:
			player.hand.append(draw_card())
func init_discard_pile() -> void:
	emit_signal("reset_discard_pile")
	if Round.zero_card_count ==0 && Round.numbered_card_count == 0:
		var rand_card = Round.create_card(randi_range(0, Round.color_count), randi_range(0,9))
		Round.discard_pile.append(rand_card)
		emit_signal("add_to_discard_pile", rand_card)
		return
	while true:
		var drawn_card = draw_card()
		if drawn_card.value < 10:
			Round.discard_pile.append(drawn_card)
			emit_signal("add_to_discard_pile", drawn_card)
			break
		else:
			Round.deck.push_back(drawn_card)

func draw_card() -> Dictionary:
	if Round.deck.size() < 1:
		var last_card = Round.get_discard_card()
		Round.discard_pile.shuffle()
		Round.deck = Round.discard_pile
		Round.discard_pile = [last_card]
	var drawn_card = Round.deck.pop_front()
	emit_signal("update_deck")
	return drawn_card

func play_cards(cards_to_play: Array):
	if cards_to_play.is_empty(): return
	var player = Round.get_current_player()
	if !player.is_user:
			await get_tree().create_timer(Game.enemy_delay).timeout
	for card in cards_to_play:
		Globals.print_card("%s played" % player.name, card)
		player.hand.erase(card)
		Round.discard_pile.append(card)
	
	if player.is_user:
		emit_signal("update_user_hand")
	else:
		emit_signal("update_enemy_hand")
	
	if player.is_user:
		emit_signal("animate_user_cards", cards_to_play)
	else:
		emit_signal("animate_enemy_cards", cards_to_play)
	await get_tree().create_timer(Game.card_animation_time).timeout
	for card in cards_to_play:
		emit_signal("add_to_discard_pile", card)
	emit_signal("add_event", {player = player, action = "played" , cards = cards_to_play})

func pickup_card(player: Dictionary) -> Dictionary:
	var drawn_card = draw_card()
	player.hand.append(drawn_card)
	if player.is_user:
		emit_signal("update_user_hand")
	else:
		emit_signal("update_enemy_hand")
		emit_signal("update_enemy_list")
	return drawn_card

func enemy_select_cards() -> Array:
	var discard_card = Round.get_discard_card()
	var selected_cards := []
	var playble_sets : Array[Array] = []
	var enemy = Round.get_current_player()
	
	for card in enemy.hand:
		if card.color == discard_card.color || card.value == discard_card.value || card.color == 4:
			playble_sets.append([card])
	
	for card_set in playble_sets:
		var first_card = card_set[0]
		var difference = enemy.hand.filter(func(c): return !card_set.has(c))
		for card in difference:
			if card.value == first_card.value:
				card_set.append(card)
	
	var longest_set := []
	var player_card_count = Round.get_user().hand.size()
	
	if player_card_count <= 3:
		var draw_sets = playble_sets.filter(func(s): 
			return s.any(func(c): return c.value in [12, 13]))
		if draw_sets.size() > 0:
			draw_sets.sort_custom(func(a, b): return a.size() > b.size())
			longest_set = draw_sets[0]
	
	if longest_set.is_empty():
		playble_sets.sort_custom(func(a, b): return a.size() > b.size())
		longest_set = playble_sets[0] if playble_sets.size() > 0 else []
	
	for card in longest_set:
		selected_cards.append(card)

	return selected_cards

func enemy_select_color() -> int:
	var color_counts = []
	for i in 4:
		color_counts.append({"color": i, "count": Round.get_current_player().hand.filter(func(c): return c.color == i).size()})
	color_counts.sort_custom(func(a, b): return a.count < b.count)
	return color_counts[-1].color

func enemy_play() -> Array:
	var selected_cards = []
	var drawn_cards_count = 0
	while drawn_cards_count < Round.draw_limit:
		selected_cards = enemy_select_cards()
		if selected_cards.is_empty():
			await get_tree().create_timer(Game.enemy_delay).timeout
			var enemy = Round.get_current_player()
			var picked_card = pickup_card(enemy)
			emit_signal("add_event", {player = enemy, action = "drew" , cards = [picked_card]})
			drawn_cards_count += 1
		else:
			break
	
	if !selected_cards.is_empty() && selected_cards[0].is_wild:
			Round.change_discard_color(enemy_select_color())
	return selected_cards

func view_animation(animation: Animations, player: Dictionary):
	match animation:
		Animations.REVERSE:
			if player.is_user:
				emit_signal("play_animation", Game.Animations.REVERSE)
			else:
				emit_signal("play_enemy_animation", Game.Animations.REVERSE, player)
		Animations.SKIP:
			if player.is_user:
				emit_signal("play_animation", Game.Animations.SKIP)
			else:
				emit_signal("play_enemy_animation", Game.Animations.SKIP, player)
		Animations.DRAW:
			if player.is_user:
				emit_signal("play_animation", Game.Animations.DRAW_TWO)
			else:
				emit_signal("play_enemy_animation", Game.Animations.DRAW_TWO, player)
		Animations.WILD:
			if player.is_user:
				pass
			else:
				emit_signal("play_animation", Game.Animations.WILD)
	await get_tree().create_timer(1).timeout

enum Animations {
	REVERSE,
	SKIP,
	DRAW,
	WILD
}

var turn_draw_count := 0
var turn_skip_count := 0

func pre_turn(played_cards: Array) -> void:
	var player = Round.get_current_player()
	
	if !played_cards.is_empty():
		var turn_reverse_count := 0
		var turn_wild_played := false
		
		for card in played_cards:
			turn_reverse_count += card.reverse_count
			turn_skip_count += card.skip_count
			turn_draw_count += card.draw_count
			turn_wild_played = card.is_wild
			
		if turn_reverse_count > 0:
			for _i in turn_reverse_count:
				Round.reverse_direction()
				emit_signal("add_event", {player = Round.get_current_player(), action = "reversed" , cards = []})
			if Round.player_count <= 2:
				Round.advance_turn()
			player = Round.get_current_player()
			view_animation(Animations.REVERSE, player)
			
		if turn_skip_count > 0:
			for _i in turn_skip_count:
				Round.advance_turn()
				player = Round.get_current_player()
				view_animation(Animations.SKIP, player)
				emit_signal("add_event", {player = Round.get_current_player(), action = "skipped" , cards = []})
			turn_skip_count = 0
		
		if turn_draw_count > 0:
			Round.advance_turn()
			player = Round.get_current_player()
			await view_animation(Animations.DRAW, player)
			var drawn_cards = []
			for _i in turn_draw_count:
				var drawn_card = pickup_card(player)
				drawn_cards.append(drawn_card)
				print(player.name, " Drew")
			emit_signal("add_event", {player = player, action = "drew" , cards = drawn_cards})
			turn_draw_count = 0
		
		if turn_wild_played:
			view_animation(Animations.WILD, player)
		
		Round.advance_turn()
	elif Round.turn_count > 1:
		Round.advance_turn()
		
	player = Round.get_current_player()
	print("Next Player: ", player.name)
	
	start_turn(player)

func start_turn(player: Dictionary) -> void:
	emit_signal("update_user_action", player.is_user)
	if player.is_user:
		emit_signal("update_user_hand")
	else:
		emit_signal("update_enemy_hand")
	emit_signal("update_enemy_list")
	Round.user_draw_count = 0
	if !player.is_user:
		await get_tree().create_timer(Game.enemy_delay).timeout
		var cards_to_play = await enemy_play()
		end_turn(cards_to_play, player)

func end_turn(cards_to_play: Array, player: Dictionary) -> void:
	await play_cards(cards_to_play)
	emit_signal("update_enemy_list")
	if player.hand.is_empty():
		var winning_player = Round.get_current_player()
		print(winning_player.name, " won!")
		emit_signal("add_event", {player = winning_player, action = "won!" , cards = []})
		Round.winning_player = winning_player
		await get_tree().create_timer(1).timeout
		Round.round_active = false
		Round.reset_round()
		get_tree().change_scene_to_file("res://components/win_screen/win_screen.tscn")
		return
	if !cards_to_play.is_empty() && Round.get_current_player().is_user && cards_to_play[0].is_wild:
		temp_user_played_cards = cards_to_play
		emit_signal("show_color_picker")
		return
	if !Round.get_current_player().is_user:
		await get_tree().create_timer(Game.enemy_delay).timeout
	
	pre_turn(cards_to_play)

func _on_pre_game_modal_is_finished(dissolve_time: float) -> void:
	emit_signal("update_user_hand")
	emit_signal("update_enemy_hand")
	emit_signal("init_deck_modal_width")
	await get_tree().create_timer(dissolve_time).timeout
	pre_turn([])

func _on_user_hand_play_cards(cards: Array) -> void:
	if cards.is_empty() && Round.user_draw_count == Round.draw_limit:
		end_turn(cards, Round.get_user())
	elif !cards.is_empty():
		end_turn(cards, Round.get_user())

func _on_color_pick_modal_color_is_chosen(color: int) -> void:
	emit_signal("update_discard_color", color)
	emit_signal("add_event", {player = Round.get_current_player(), action = "picked %s" % Globals.get_color_str(color) , cards = []})
	temp_user_played_cards[-1].color = color
	pre_turn(temp_user_played_cards)
	temp_user_played_cards = []

func _on_deck_pressed() -> void:
	if Round.user_draw_count < Round.draw_limit:
		var drawn_card = draw_card()
		var user = Round.get_user()
		user.hand.append(drawn_card)
		Round.user_draw_count += 1
		emit_signal("add_event", {player = user, action = "drew" , cards = [drawn_card]})
		emit_signal("update_user_hand")
	else:
		emit_signal("show_draw_alert")

func _on_animation_modal_is_finished() -> void:
	pass
	#Round.advance_turn()
		#
	#var player = Round.get_current_player()
	#
	#if !player.is_user:
		#await get_tree().create_timer(Game.enemy_delay).timeout
	#start_turn(player)

#Cheats
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("win"):
		Round.winning_player = Round.get_current_player()
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://components/win_screen/win_screen.tscn")
