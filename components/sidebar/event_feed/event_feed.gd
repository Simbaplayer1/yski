extends PanelContainer

@onready var event_container := %EventContainer
@onready var scroll_container := %ScrollContainer

var event_item_scene := preload("res://components/sidebar/event_feed/event_feed_item.tscn")

func _ready() -> void:
	for child in event_container.get_children():
		child.call_deferred("free")

func add_event(event: Dictionary) -> void:
	var event_item_obj = event_item_scene.instantiate()
	event_item_obj.event = event
	event_container.add_child(event_item_obj)
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
