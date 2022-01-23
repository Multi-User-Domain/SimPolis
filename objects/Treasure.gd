extends Node2D

onready var animation_player = $AnimationPlayer
var is_open = false

func can_interact():
	return !is_open

func interact():
	if can_interact():
		animation_player.play("OpenChest")
		is_open = true
