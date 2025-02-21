extends Control

@export var hand: VBoxContainer
@export var is_disabled := false

func _ready() -> void:
	for child in get_children():
		child.call_deferred("free")

func redraw():
	var card_count := get_child_count()
	var card_width := 22.0
	var hand_width = card_count * card_width
	var container_width = self.size.x
	
	var separation = 10
	var is_overflowing = card_count * (card_width + separation) > container_width
	
	if is_overflowing:
		separation =-float((hand_width - container_width) / float(card_count - 1))
	
	for i in card_count:
		var child = get_children()[i]
		if is_overflowing:
			child.position.x = ((card_width + separation) * i)
		else:
			var total_width = ((card_width + separation) * card_count) - card_width / 2
			var offset = (float(container_width / 2.) - float(total_width / 2.))
			child.position.x = offset + ((card_width + separation) * i)
		child.position.y = 1

func can_select(card: Dictionary) -> bool:
	if is_disabled: return false
	if hand.selected_cards.is_empty():
		return Round.can_play(card)
	else:
		return card.value == Globals.find(Round.get_user().hand, func(user_card): return user_card.id == hand.selected_cards[0].id).value
