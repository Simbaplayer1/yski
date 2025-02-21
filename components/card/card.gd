extends Button

@onready var card_texture = %CardTexture

@export var card := {id = 0, color= 0, value = 0, rotation = 0, position = 0}
@export var ghost_pos_from: Vector2
@export var ghost_pos_to: Vector2
@export var is_ghost := false
@export var enemy_card := false
@export var is_static := false
@onready var start_pos := self.position.y
@onready var start_size := self.size.y

@onready var tooltip_panel := %TooltipPanel
@onready var tooltip_label := %TooltipLabel

signal select(card: Dictionary)
signal deselect(card: Dictionary)
signal toggle_shake(enabled: bool)

var is_selected := false

var tween

func _ready() -> void:
	card_texture.texture = load("res://art/cards/card_%s.png" % (208 if enemy_card else Globals.get_card_texture(card)))

	if is_ghost:
		is_static = true
		self.position = ghost_pos_from
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", ghost_pos_to, Game.card_animation_time)
		tween.parallel().tween_property(self, "rotation", card.rotation, Game.card_animation_time)
	
	tooltip_panel.visible = false
	if card.color == -1:
		tooltip_panel.add_theme_stylebox_override("panel", load("res://themes/panels/black_panel.tres"))
	else:
		tooltip_panel.theme = load("res://themes/%s.tres" % (Globals.get_color_str(card.color).to_lower()))
	
	var card_value_text := ""
	if card.value > 11:
		card_value_text = Globals.get_short_value_str(card.value)
	else:
		card_value_text = Globals.get_value_str(card.value)
	
	tooltip_label.text = card_value_text
	
	emit_signal("toggle_shake", !is_static)

func _on_mouse_entered() -> void: 
	if is_static: return
	if !enemy_card:
		tooltip_panel.visible = true
	if tween: tween.kill()
	card_texture.is_hovering = true

func _on_mouse_exited() -> void:
	if is_static: return
	if !enemy_card:
		tooltip_panel.visible = false
	if card_texture.material.get_shader_parameter("sprite_position") != null && card_texture.material.get_shader_parameter("mouse_position") != null:
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_method(
			func(pos): card_texture.material.set_shader_parameter("sprite_position",pos),
			card_texture.material.get_shader_parameter("sprite_position"), Vector2(0, 0), 0.5)
		tween.parallel().tween_method(
			func(pos): card_texture.material.set_shader_parameter("mouse_position",pos),
			 card_texture.material.get_shader_parameter("mouse_position"), Vector2(0, 0), 0.5)

	card_texture.is_hovering = false

func _on_pressed() -> void:
	if enemy_card || is_static: return
	
	if get_parent().can_select(card) && !is_selected:
		emit_signal("select", card)
		is_selected = true
	else:
		emit_signal("deselect", card)
		is_selected = false
	
	Globals.animate_card_float(self, start_size, 10 if is_selected else -1)
