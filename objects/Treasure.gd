extends "InteractiveObject.gd"

onready var animation_player = $AnimationPlayer
var is_open = false

func can_interact(agent: Node):
	return !is_open

func interact(agent: Node):
	if can_interact(agent):
		animation_player.play("OpenChest")
		is_open = true
