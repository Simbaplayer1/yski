extends Control

@onready var red_button := %RedButton
@onready var yellow_button := %YellowButton
@onready var green_button := %GreenButton
@onready var blue_button := %BlueButton

var appear_time := 0.5
var dissolve_time := 1.

signal color_is_chosen(color: int)

func _ready() -> void:
	visible = false
	toggle_buttons(true)

func show_popup() -> void:
	material.set_shader_parameter("time",1.)
	visible = true
	scale = Vector2(0,0)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1,1), appear_time)
	toggle_buttons(false)

func hide_popup() -> void:
	toggle_buttons(true)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(current_dissolve): material.set_shader_parameter("time",current_dissolve),
		1., 0., dissolve_time)
	await get_tree().create_timer(dissolve_time).timeout
	visible = false
	get_tree().paused = false

func toggle_buttons(value: bool) -> void:
	red_button.disabled = value
	yellow_button.disabled = value
	green_button.disabled = value
	blue_button.disabled = value

func _on_red_button_pressed() -> void:
	hide_popup()
	emit_signal("color_is_chosen", 0)

func _on_yellow_button_pressed() -> void:
	hide_popup()
	emit_signal("color_is_chosen", 1)

func _on_green_button_pressed() -> void:
	hide_popup()
	emit_signal("color_is_chosen", 2)

func _on_blue_button_pressed() -> void:
	hide_popup()
	emit_signal("color_is_chosen", 3)

func _on_game_show_color_picker() -> void:
	show_popup()
