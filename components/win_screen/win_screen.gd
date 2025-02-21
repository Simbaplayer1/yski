extends Control

@onready var winner_label = %WinnerLabel

func _ready() -> void:
	winner_label.text = "[b]%s wins!" % "user"

func _on_continue_button_pressed() -> void:
	var money_to_earn := Round.money_to_earn
	Game.money += money_to_earn
	Round.money_to_earn = 0
	get_tree().change_scene_to_file("res://components/round_map/round_map.tscn")
