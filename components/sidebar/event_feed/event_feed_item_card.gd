extends PanelContainer

@export var card := {value = 0, color = 0}
@export var is_draw := false
@export var is_user := false
@onready var value_label := %ValueLabel

func _ready() -> void:
	if !is_user && is_draw || card.color == -1:
		self.add_theme_stylebox_override("panel", load("res://themes/panels/black_panel.tres"))
	else:
		self.theme = load("res://themes/%s.tres" % (Globals.get_color_str(card.color).to_lower()))
	var card_text = Globals.get_short_value_str(card.value)
	value_label.text = "?" if is_draw && !is_user else card_text
