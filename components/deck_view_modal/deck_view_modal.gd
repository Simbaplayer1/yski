extends Control

@onready var red_container := %RedCardContainer
@onready var yellow_container := %YellowCardContainer
@onready var green_container := %GreenCardContainer
@onready var blue_container := %BlueCardContainer
@onready var rose_container := %RoseCardContainer
@onready var orange_container := %OrangeCardContainer
@onready var cyan_container := %CyanCardContainer
@onready var purple_container := %PurpleCardContainer
@onready var black_container := %BlackCardContainer

var card_scene := preload("res://components/card/card.tscn")

var container_width := 0.
var deck := []

func _ready() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	visible = true
	clear_container(red_container)
	clear_container(yellow_container)
	clear_container(green_container)
	clear_container(blue_container)
	clear_container(rose_container)
	clear_container(orange_container)
	clear_container(cyan_container)
	clear_container(purple_container)
	clear_container(black_container)

func clear_container(container: Panel):
	for child in container.get_children():
		child.call_deferred("free")

func update(deck: Array):
	deck.sort_custom(Globals.sort_card_value)
	
	for card in deck:
		var card_obj = card_scene.instantiate()
		card_obj.card = card
		card_obj.is_static = true
		var container = get("%s_container" % Globals.get_color_str(card.color).to_lower())
		container.add_child(card_obj)
		redraw_container(container)

func redraw_container(conatiner: Panel):
	var card_count := conatiner.get_child_count()
	var card_width := 11.0
	var hand_width = card_count * card_width
	
	var separation = 5
	var is_overflowing = card_count * (card_width + separation) > container_width
	
	if is_overflowing:
		separation = -float((hand_width - container_width) / float(card_count - 1))
	
	for i in card_count:
		var child = conatiner.get_children()[i]
		child.scale = Vector2(0.5, 0.5)
		if is_overflowing:
			child.position.x = ((card_width + separation) * i)
		else:
			child.position.x = ((card_width + separation) * i)

func _on_view_deck_button_pressed() -> void:
	visible = true

func _on_close_button_pressed() -> void:
	visible = false

func _on_game_init_deck_modal_deck(deck: Array) -> void:
	self.deck = deck

func _on_game_init_deck_modal_width() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	container_width = red_container.size.x
	update(deck)
	visible = false
