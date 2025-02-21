extends PanelContainer

@onready var avatar_texture := %AvatarTexture
@onready var name_label := %NameLabel
@onready var hand_label := %HandLabel
@onready var animation_player := $AnimationPlayer

@onready var enemy_animations := %EnemyAnimations

@export var enemy := {name = "Enemy", id = 2, hand = []}

func _ready() -> void:
	get_parent().get_parent().get_parent().connect("update_items", _on_update_items)
	get_parent().get_parent().get_parent().connect("play_enemy_animation", _on_play_enemy_animation)
	avatar_texture.texture = load("res://art/ui/player_avatars/player_avatar_%s.png" % enemy.id)
	name_label.text = enemy.name
	hand_label.text = var_to_str(enemy.hand.size()) + " cards"
	enemy_animations.visible = false

func _on_play_enemy_animation(animation: Game.Animations, _enemy: Dictionary):
	if enemy.id == _enemy.id:
		match animation:
			Game.Animations.SKIP:
				animation_player.play("skip")
			Game.Animations.DRAW_TWO:
				animation_player.play("draw_two")

func _on_update_items():
	var current_player = Round.get_current_player()
	var is_playing = enemy.id == current_player.id
	self.material.set_shader_parameter("effect_enabled", is_playing)
	hand_label.text = var_to_str(enemy.hand.size()) + " cards"
