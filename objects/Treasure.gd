extends "res://objects/InteractiveObject.gd"

onready var animation_player = get_node("AnimationPlayer")
var is_open = false
var size_cells := Vector2(2,2)

func can_interact(agent: Node):
	return !is_open

func interact(agent: Node):
	if can_interact(agent):
		animation_player.play("OpenChest")
		is_open = true
