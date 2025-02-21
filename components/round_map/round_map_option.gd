extends PanelContainer

@export var option := {id = 0, ai_difficulty = 0, enemy_count = 1, color_count = 1, stacking_enabled = false, earned_money = 4, numbered_card_count = 0, zero_card_count = 0, action_card_count = 0, wild_card_count = 0, wild_special_card_count = 0}

@onready var difficulty_label := %DifficultyLabel
@onready var enemy_count_label := %EnemyCountLabel
@onready var color_count_label := %ColorCountLabel
@onready var stacking_label := %StackingLabel
@onready var money_label := %MoneyLabel

@onready var color_count_texture := %ColorCountTexture
@onready var enemy_count_texture := %EnemyCountTexture

@onready var deck_preview := %DeckPreview

@onready var stacking_texture := %StackingTexture

@onready var choose_button := %ChooseButton

@onready var numbered_count_label := %NumberedCountLabel
@onready var zero_count_label := %ZeroCountLabel
@onready var action_count_label := %ActionCountLabel
@onready var wild_count_label := %WildCountLabel
@onready var special_count_label := %SpecialCountLabel
@onready var total_count_label := %TotalCountLabel

signal round_chosen(id: int)

func _ready() -> void:
	deck_preview.visible = false
	difficulty_label.text = "[b]%s" % Globals.get_ai_difficulty_text(option.ai_difficulty)
	enemy_count_label.text = "Enemy count: %s" % option.enemy_count
	color_count_label.text = "Color count: %s" % option.color_count
	stacking_label.text = "Stacking: %s" % ("enabled" if option.stacking_enabled else "disabled")
	money_label.text = "$%s" % option.earned_money
	
	color_count_texture.texture = load("res://art/ui/icons/round_map_icons/color_count/color_count_%s.png" % option.color_count)
	enemy_count_texture.texture = load("res://art/ui/icons/round_map_icons/enemy_count/enemy_count_%s.png" % option.color_count)
	
	stacking_texture.visible = option.stacking_enabled
	
	var total_numbered_count = option.numbered_card_count * option.color_count * 9
	var total_zero_count = option.zero_card_count * option.color_count * 1
	var total_action_count = option.action_card_count * option.color_count * 3
	var total_wild_count = option.wild_card_count * option.color_count * 2
	var total_special_count = option.wild_special_card_count * option.color_count * 8
	var total_card_count = (total_numbered_count + total_zero_count + total_action_count + total_wild_count + total_special_count)
	
	var numbered_count_text = ("%s (total %s) 1-9 cards" % [option.numbered_card_count, total_numbered_count]) if total_numbered_count > 0 else "No 1-9 cards"
	var zero_count_text = ("%s (total %s) 0 cards" % [option.zero_card_count, total_zero_count]) if total_zero_count > 0 else "No 0 cards"
	var action_count_text = ("%s (total %s) action cards" % [option.action_card_count, total_action_count]) if total_action_count > 0 else "No action cards"
	var wild_count_text = ("%s (total %s) wild cards" % [option.wild_card_count, total_wild_count]) if total_wild_count > 0 else "No wild cards"
	var special_count_text = ("%s (total %s) wild special cards" % [option.wild_special_card_count, total_special_count]) if total_special_count > 0 else "No special wild cards"
	var total_count_text = "Total %s" % total_card_count
	
	numbered_count_label.text = numbered_count_text
	zero_count_label.text = zero_count_text
	action_count_label.text =action_count_text 
	wild_count_label.text = wild_count_text
	special_count_label.text = special_count_text 
	
	total_count_label.text = total_count_text
	
	var choose_button_theme
	match option.ai_difficulty:
		0:
			choose_button_theme = load("res://themes/green.tres")
		1:
			choose_button_theme = load("res://themes/yellow.tres")
		2:
			choose_button_theme = load("res://themes/red.tres")
		3:
			choose_button_theme = load("res://themes/purple.tres")
	
	choose_button.theme = choose_button_theme
	
func _on_choose_button_pressed() -> void:
	emit_signal("round_chosen", option.id)


func _on_deck_container_mouse_entered() -> void:
	deck_preview.visible = true

func _on_deck_container_mouse_exited() -> void:
	deck_preview.visible = false


func _on_deck_texture_mouse_entered() -> void:
	deck_preview.visible = true

func _on_deck_texture_mouse_exited() -> void:
	deck_preview.visible = false
