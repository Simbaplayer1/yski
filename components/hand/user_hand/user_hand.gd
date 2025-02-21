extends VBoxContainer

@onready var card_container := %CardContainer
@onready var user_panel := %UserPanel

@onready var draw_limit_panel := %DrawLimitPanel
@onready var animation_player := $AnimationPlayer

signal play_cards(card_ids: Array)

var card_scene := preload("res://components/card/card.tscn")
var selected_cards := []

func _ready() -> void:
	draw_limit_panel.visible = false

func sort_hand(method: Game.SortMethod):
	var new_hand := []
	new_hand = Round.get_user().hand
	new_hand.sort_custom(Globals.sort_card_color if method == Game.SortMethod.COLOR else Globals.sort_card_value)
	
	for child in card_container.get_children():
		child.call_deferred("free")
		if child == card_container.get_children()[-1]:
			child.tree_exited.connect(_on_card_freed_2.bind(new_hand))

func _on_card_freed_2(new_hand):
	for card in new_hand:
		var card_obj = card_scene.instantiate()
		card_obj.card = card
		card_obj.ghost_pos_to = card.position
		card_obj.select.connect(Callable(self, "_on_select_card"))
		card_obj.deselect.connect(Callable(self, "_on_deselect_card"))
		card_container.add_child(card_obj)
	card_container.redraw()

func update_hand(new_hand: Array) -> void:
	var prev_hand := []
		
	for child in card_container.get_children():
		prev_hand.append(child.card)
		
	var cards_to_remove := []
	var cards_to_add := []
	
	for card in prev_hand:
		if card not in new_hand:
			cards_to_remove.append(card)
			
	for card in new_hand:
		if card not in prev_hand:
			cards_to_add.append(card)
	
	if !cards_to_remove.is_empty():
		for card in cards_to_remove:
			if card_container.get_child_count() > 0:
				var card_obj = Globals.find(card_container.get_children(), func(child): return child.card.id == card.id)
				card_obj.call_deferred("free")
				if card == cards_to_remove[-1]:
					card_obj.tree_exited.connect(_on_card_freed.bind(card))
	else:
		for card in cards_to_add:
			var card_obj = card_scene.instantiate()
			card_obj.card = card
			card_obj.ghost_pos_to = card.position
			card_obj.select.connect(Callable(self, "_on_select_card"))
			card_obj.deselect.connect(Callable(self, "_on_deselect_card"))
			card_container.add_child(card_obj)
		card_container.redraw()

func _on_card_freed(_card):
	card_container.redraw()

func play() -> void:
	emit_signal("play_cards", selected_cards)
	selected_cards = []

func _on_select_card(card: Dictionary) -> void:
	selected_cards.append(card)

func _on_deselect_card(card: Dictionary) -> void:
	selected_cards.erase(card)

func _on_game_update_user_hand() -> void:
	update_hand(Round.get_user().hand)

func _on_game_update_user_action(user_turn: bool) -> void:
	card_container.is_disabled = !user_turn
	var user_panel_box := load("res://themes/panels/hand_border.tres")
	user_panel_box = user_panel_box.duplicate()
	user_panel_box.texture = load("res://art/ui/player_borders/player_border_%s.png" % ("1" if user_turn else "9"))
	user_panel.add_theme_stylebox_override("panel", user_panel_box)

func _on_game_animate_user_cards(cards: Array) -> void:
	var card_animation_layer := %CardAnimationLayer
	var discard_pile := %DiscardPile
	for card in cards:
		var children = card_container.get_children()
		var original_card = children[children.find_custom(func(child): return child.card.id == card.id)]
		var ghost_card = card_scene.instantiate()
		ghost_card.card = card
		ghost_card.ghost_pos_from = original_card.global_position
		ghost_card.ghost_pos_to = discard_pile.global_position + original_card.ghost_pos_to
		ghost_card.is_ghost = true
		card_animation_layer.add_child(ghost_card)
		
	await get_tree().create_timer(Game.card_animation_time).timeout
	for child in card_animation_layer.get_children():
		child.call_deferred("free")


func _on_game_show_draw_alert() -> void:
	animation_player.play("draw_limit_alert")
