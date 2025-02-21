extends Node

@export var game_round := 0
@export var round_type := 1
@export var money := 0
@export var lives := 1

@export var enemy_delay := 0.85
@export var card_animation_time := 0.25
@export var difficulty: Difficulty

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	INSANE
}

enum Animations {
	REVERSE,
	SKIP,
	DRAW_TWO,
	DRAW_FOUR,
	WILD
}

enum SortMethod {
	COLOR,
	VALUE
}
