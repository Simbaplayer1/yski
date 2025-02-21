extends Control

@onready var background = $Background

func _ready() -> void:
	visible = false

func start():
	visible = true
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(val): background.material.set_shader_parameter("fade",val),
		3.0, 0.3, 0.75)
	tween.parallel().tween_method(
		func(val): background.material.set_shader_parameter("thickness",val),
		0.0, 0.7, 0.75)
		
	tween.tween_method(
		func(_val): return null,
		0.0, 0.0, 0.5)
		
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_method(
		func(val): background.material.set_shader_parameter("fade",val),
		0.3, 3.0, 0.75)
	tween.parallel().tween_method(
		func(val): background.material.set_shader_parameter("thickness",val),
		0.75, 0.0, 0.75)
