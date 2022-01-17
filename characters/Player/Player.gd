extends KinematicBody2D


export var speed = 400  # How fast the player will move (pixels/sec).
var target_coords
var velocity = Vector2.ZERO
var screen_size  # Size of the game window.


func _ready():
	screen_size = get_viewport_rect().size

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			target_coords = event.position
