extends PanelContainer

@onready var turn_label := %TurnLabel
@onready var round_label := %RoundLabel
@onready var card_count_label := %CardCountLabel
@onready var money_label := %MoneyLabel

@onready var draw_count_label := %DrawCountLabel
@onready var draw_limit_label := %DrawLimitLabel

func _process(_delta: float) -> void:
	round_label.text = var_to_str(Game.game_round)
	money_label.text = "$%s" % Game.money
	
	if Round.round_active:
		turn_label.text = var_to_str(Round.turn_count)
		draw_limit_label.text = var_to_str(Round.draw_limit)
		draw_count_label.text = var_to_str(Round.user_draw_count)
		card_count_label.text = var_to_str(Round.get_user().hand.size())
	else:
		turn_label.text = "0"
