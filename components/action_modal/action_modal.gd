extends Control

@onready var animation_player := $AnimationPlayer
@onready var reverse_animation := $ReverseAnimation
@onready var skip_animation := $SkipAnimation
@onready var draw_two_animation := $DrawTwoAnimation
@onready var draw_four_animation := $DrawFourAnimation
@onready var wild_animation := $WildAnimation

var animation_time := 2.0

signal is_finished

func _on_game_play_animation(animation: Game.Animations) -> void:
	self.visible = true
	
	match animation:
		Game.Animations.REVERSE:
			animation_player.play("reverse")
			reverse_animation.start()
			print("Played animation REVERSE")
			
		Game.Animations.SKIP:
			animation_player.play("skip")
			skip_animation.start()
			print("Played animation SKIP")
			
		Game.Animations.DRAW_TWO:
			animation_player.play("skip")
			draw_two_animation.start()
			print("Played animation DRAW_TWO")
			
		Game.Animations.DRAW_FOUR:
			animation_player.play("draw_four")
			draw_four_animation.start()
			print("Played animation DRAW_FOUR")
			
		Game.Animations.WILD:
			animation_player.play("wild")
			wild_animation.start()
			print("Played animation WILD")
			
	await get_tree().create_timer(animation_time).timeout
	emit_signal("is_finished")
	self.visible = false
