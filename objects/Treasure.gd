extends Node2D

onready var animation_player = $AnimationPlayer
var is_open = false

func interact():
	animation_player.play("OpenChest")
	is_open = true
