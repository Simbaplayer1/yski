extends Control

@onready var heart_text := %HeartText
@onready var heart_1 := %Heart1
@onready var heart_2 := %Heart2
@onready var heart_3 := %Heart3

@onready var ai_text = %AiText
@onready var ai_level_1 = %AiLevel1
@onready var ai_level_2 = %AiLevel2
@onready var ai_level_3 = %AiLevel3
@onready var ai_level_4 = %AiLevel4

@onready var starting_money_text = %StartingMoneyText

var heart_texture_filled := load("res://art/ui/icons/hearts/heart_1.png")
var heart_texture_unfilled := load("res://art/ui/icons/hearts/heart_2.png")
var heart_texture_insane := load("res://art/ui/icons/hearts/heart_3.png")

var ai_texture_easy := load("res://art/ui/icons/ai_level/ai_level_1.png")
var ai_texture_mediun := load("res://art/ui/icons/ai_level/ai_level_2.png")
var ai_texture_hard := load("res://art/ui/icons/ai_level/ai_level_3.png")
var ai_texture_insane := load("res://art/ui/icons/ai_level/ai_level_4.png")
var ai_texture_empty := load("res://art/ui/icons/ai_level/ai_level_5.png")

var starting_lives: = 0
var starting_money: int

func set_difficulty(difficulty: Game.Difficulty):
	match difficulty:
		Game.Difficulty.HARD:
			heart_1.texture = heart_texture_filled
			heart_2.texture = heart_texture_filled
			heart_3.texture = heart_texture_unfilled
			heart_text.text = "2 Lives"
		
		Game.Difficulty.INSANE:
			heart_1.texture = heart_texture_insane
			heart_2.texture = heart_texture_unfilled
			heart_3.texture = heart_texture_unfilled
			heart_text.text = "1 Life"
		_:
			heart_1.texture = heart_texture_filled
			heart_2.texture = heart_texture_filled
			heart_3.texture = heart_texture_filled
			heart_text.text = "3 Lives"
	
	match difficulty:
		Game.Difficulty.EASY:
			ai_level_1.texture = ai_texture_easy
			ai_level_2.texture = ai_texture_empty
			ai_level_3.texture = ai_texture_empty
			ai_level_4.texture = ai_texture_empty
			ai_text.text = "Easy Ai"
		Game.Difficulty.MEDIUM:
			ai_level_1.texture = ai_texture_easy
			ai_level_2.texture = ai_texture_mediun
			ai_level_3.texture = ai_texture_empty
			ai_level_4.texture = ai_texture_empty
			ai_text.text = "Medium Ai"
		Game.Difficulty.HARD:
			ai_level_1.texture = ai_texture_easy
			ai_level_2.texture = ai_texture_mediun
			ai_level_3.texture = ai_texture_hard
			ai_level_4.texture = ai_texture_empty
			ai_text.text = "Hard Ai"
		Game.Difficulty.INSANE:
			ai_level_1.texture = ai_texture_easy
			ai_level_2.texture = ai_texture_mediun
			ai_level_3.texture = ai_texture_hard
			ai_level_4.texture = ai_texture_insane
			ai_text.text = "Insane Ai"
	
	match difficulty:
		Game.Difficulty.EASY:
			starting_money = 10
			starting_lives = 3
		Game.Difficulty.MEDIUM:
			starting_money = 8
			starting_lives = 3
		Game.Difficulty.HARD:
			starting_money = 6
			starting_lives = 2
		Game.Difficulty.INSANE:
			starting_money = 4
			starting_lives = 1
		
	starting_money_text.text = "Starting money: %s$" % starting_money
	Game.difficulty = difficulty
	
func _ready() -> void:
	set_difficulty(Game.Difficulty.MEDIUM)

func _on_easy_button_pressed() -> void:
	set_difficulty(Game.Difficulty.EASY)

func _on_medium_button_pressed() -> void:
	set_difficulty(Game.Difficulty.MEDIUM)

func _on_hard_button_pressed() -> void:
	set_difficulty(Game.Difficulty.HARD)

func _on_hardcore_button_pressed() -> void:
	set_difficulty(Game.Difficulty.INSANE)

var round_scene := "res://components/round_map/round_map.tscn"

func _on_start_button_pressed() -> void:
	Game.money = starting_money
	Game.lives = starting_lives
	Game.game_round = 0
	get_tree().change_scene_to_file(round_scene)
