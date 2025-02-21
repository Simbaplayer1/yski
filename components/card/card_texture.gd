extends TextureRect

var is_hovering = false
var mouse_smoothing_speed = 10.0
var current_mouse_pos: Vector2
var target_mouse_pos: Vector2

func _ready() -> void:
	await get_tree().process_frame
	material.set_shader_parameter("offset", randf_range(-1000, 1000))

func _physics_process(delta: float) -> void:
	if is_hovering:
		target_mouse_pos = get_global_mouse_position()
		current_mouse_pos = current_mouse_pos.lerp(target_mouse_pos, delta * mouse_smoothing_speed)
		material.set_shader_parameter("mouse_position", current_mouse_pos)
		material.set_shader_parameter("sprite_position", global_position)
	else:
		target_mouse_pos = global_position
		current_mouse_pos = current_mouse_pos.lerp(target_mouse_pos, delta * mouse_smoothing_speed)

func _on_card_toggle_shake(enabled: bool) -> void:
	material.set_shader_parameter("shake_enabled", enabled)
	if !enabled:
		material.set_shader_parameter("mouse_position", Vector2.ZERO)
