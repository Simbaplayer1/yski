extends GridContainer

@export var event := {player = {id = 1, is_user = false}, action = "played", cards = []}

@onready var player_avatar_texture := %PlayerAvatarTexture
@onready var action_label := %ActionLabel
@onready var card_count_label := %CardCountLabel
@onready var card_container := %CardContainer

var event_item_card_scene := preload("res://components/sidebar/event_feed/event_feed_item_card.tscn")

func _ready() -> void:
	player_avatar_texture.texture = load("res://art/ui/player_avatars/player_avatar_%s.png" % (event.player.id))
	action_label.text = event.action
	for child in card_container.get_children():
		child.call_deferred("free")

	if !event.player.is_user:
		if event.cards.size() > 1:
			card_count_label.text = "%sx" % event.cards.size()
		else:
			card_count_label.visible = false
		var event_item_card_obj = event_item_card_scene.instantiate()
		event_item_card_obj.is_draw = event.action == "drew"
		event_item_card_obj.is_user = event.player.is_user
		card_container.add_child(event_item_card_obj)
	else:
		card_count_label.visible = false
		for card in event.cards:
			var event_item_card_obj = event_item_card_scene.instantiate()
			event_item_card_obj.card = card
			event_item_card_obj.is_draw = event.action == "drew"
			event_item_card_obj.is_user = event.player.is_user
			card_container.add_child(event_item_card_obj)
