extends Control

@onready var tooltip := %Tooltip
@onready var tooltip_panel := %TooltipPanel
@onready var tooltip_label := %TooltipLabel
@onready var card_container := %CardContainer

var card_scene = preload("res://components/card/card.tscn")

func _ready() -> void:
	clear_pile()
	tooltip.visible = false

func clear_pile() -> void:
	for child in card_container.get_children():
		child.call_deferred("free")

func _on_game_add_to_discard_pile(card: Dictionary) -> void:
	var card_obj = card_scene.instantiate()
	card_obj.card = card
	card_obj.rotation = card.rotation
	card_obj.position = card.position
	card_obj.is_static = true
	card_container.add_child(card_obj)
	tooltip_panel.theme = load("res://themes/%s.tres" % Globals.get_color_str(card.color).to_lower())
	tooltip_label.text = Globals.get_short_value_str(card.value)

func _on_game_reset_discard_pile() -> void:
	clear_pile()

func _on_game_update_discard_color(color: int) -> void:
	var card_obj = card_container.get_child(-1)
	if !card_obj:
		printerr("Error")
		return
	var new_card_obj = card_obj.duplicate()
	card_obj.call_deferred("free")
	new_card_obj.card.color = color
	card_container.add_child(new_card_obj)
	tooltip_panel.theme = load("res://themes/%s.tres" % Globals.get_color_str(color).to_lower())

func _on_panel_mouse_entered() -> void:
	tooltip.visible = true

func _on_panel_mouse_exited() -> void:
	tooltip.visible = false
