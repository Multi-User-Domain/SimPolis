extends KinematicBody2D


export var speed = 400  # How fast the player will move (pixels/sec).
var target_coords
var velocity = Vector2.ZERO
var screen_size  # Size of the game window.


func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	if target_coords:
		if (target_coords - get_position()).length() > 10:			
			velocity = (target_coords - get_position()).normalized() * speed
			move_and_slide(velocity, Vector2(0, -1))
		else:
			set_position(target_coords)
			target_coords = null

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			target_coords = event.position
