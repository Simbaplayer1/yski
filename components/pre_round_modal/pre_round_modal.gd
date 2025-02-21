extends Control

@onready var timer = $Timer

@onready var starting_player_panel := %StartingPlayerPanel
@onready var starting_player_label :=%StartingPlayerLabel

@onready var numbered_count_label :=%NumberedCountLabel
@onready var zero_count_label := %ZeroCountLabel
@onready var action_count_label := %ActionCountLabel
@onready var wild_count_label := %WildCountLabel
@onready var special_count_label := %SpecialCountLabel
@onready var card_count_label := %CardCountLabel

@onready var draw_limit_label := %DrawLimitLabel
@onready var stacking_label := %StackingLabel
@onready var enemy_count_label := %EnemyCountLabel

signal is_finished(dissolve_time: float)

var dissolve_time := 1.

func _ready() -> void:
	self.visible = true
	var starting_player = Round.get_current_player()
	starting_player_panel.theme = load("res://themes/%s.tres" % Globals.get_color_str(starting_player.id))
	starting_player_label.text = starting_player.name
	
	numbered_count_label.text = "%s of each 1-9 card" % Round.numbered_card_count
	numbered_count_label.text = "%s of each 0 card" % Round.zero_card_count
	numbered_count_label.text = "%s of each action card" % Round.action_card_count
	numbered_count_label.text = "%s of each wild card" % Round.wild_card_count
	numbered_count_label.text = "%s of each special card" % Round.wild_special_card_count
	card_count_label.text = "%s total cards" % Round.deck.size()

func _on_timer_timeout() -> void:
	emit_signal("is_finished", dissolve_time)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(current_dissolve): material.set_shader_parameter("time", current_dissolve), 
		1., 0., dissolve_time)
	await get_tree().create_timer(dissolve_time).timeout
	call_deferred("free")
