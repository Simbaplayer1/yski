extends VBoxContainer

@onready var card_container := %CardContainer
@onready var enemy_panel := %EnemyPanel
@onready var enemy_list := %EnemyList

var card_scene := preload("res://components/card/card.tscn")

func update_hand(new_hand: Array) -> void:
	var container_children = card_container.get_children()
	for child in container_children:
		child.call_deferred("free")

	for card in new_hand:
		var card_obj = card_scene.instantiate()
		card_obj.card = card
		card_obj.ghost_pos_to = card.position
		card_obj.enemy_card = true
		card_container.add_child(card_obj)
	await get_tree().physics_frame
	card_container.redraw()

func _on_game_update_enemy_hand() -> void:
	var current_player = Round.get_current_player()
	update_hand(current_player.hand)

func _on_game_update_enemy_list() -> void:
	enemy_list.update_list()
	var current_player = Round.get_current_player()
	var enemy_panel_box := load("res://themes/panels/hand_border.tres")
	enemy_panel_box = enemy_panel_box.duplicate()
	enemy_panel_box.texture = load("res://art/ui/player_borders/player_border_%s.png" % (current_player.id if !current_player.is_user else "9"))
	enemy_panel.add_theme_stylebox_override("panel", enemy_panel_box)

func _on_game_animate_enemy_cards(cards: Array) -> void:
	var card_animation_layer := %CardAnimationLayer
	var discard_pile := %DiscardPile
	for card in cards:
		var children := card_container.get_children()
		var original_card := children[children.find_custom(func(child): return child.card.id == card.id)]
		var ghost_card := card_scene.instantiate()
		ghost_card.card = card
		ghost_card.ghost_pos_from = original_card.global_position
		ghost_card.ghost_pos_to = discard_pile.global_position + original_card.ghost_pos_to
		ghost_card.is_ghost = true
		card_animation_layer.add_child(ghost_card)
		
	await get_tree().create_timer(Game.card_animation_time).timeout
	for child in card_animation_layer.get_children():
		child.call_deferred("free")

func _on_game_init_enemy_list() -> void:
	var enemies = Round.players.filter(func(player): return !player.is_user)
	enemy_list.init_list(enemies)
	enemy_list.update_list()

func _on_game_play_enemy_animation(animation: Game.Animations, enemy: Dictionary) -> void:
	enemy_list.play_animation(animation, enemy)
