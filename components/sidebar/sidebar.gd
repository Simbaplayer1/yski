extends VBoxContainer

@onready var event_feed := %EventFeed

func _on_game_add_event(event: Dictionary) -> void:
	event_feed.add_event(event)
