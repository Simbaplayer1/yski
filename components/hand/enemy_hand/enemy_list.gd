extends PanelContainer

@onready var enemy_container := %EnemyContainer

var list_item_scene = preload("res://components/hand/enemy_hand/enemy_list_item.tscn")

signal update_items
signal play_enemy_animation(animation: Game.Animations, enemy: Dictionary)

func _ready() -> void:
	for child in enemy_container.get_children():
		child.call_deferred("free")

func init_list(enemies: Array):
	for enemy in enemies:
		var list_item_obj = list_item_scene.instantiate()
		list_item_obj.enemy = enemy
		enemy_container.add_child(list_item_obj)

func update_list():
	emit_signal("update_items")

func play_animation(animation: Game.Animations, enemy: Dictionary):
	emit_signal("play_enemy_animation", animation, enemy)
