extends KinematicBody2D


export var speed = 400  # How fast the player will move (pixels/sec).
export var character_name = ""
var target_coords
var velocity = Vector2.ZERO
var screen_size  # Size of the game window.

signal player_selected


func _ready():
	screen_size = get_viewport_rect().size
	$NameLabel.text = character_name

func _physics_process(delta):
	if target_coords:
		if (target_coords - get_position()).length() > 10:
			velocity = (target_coords - get_position()).normalized() * speed
			move_and_slide(velocity, Vector2(0, -1))
		else:
			set_position(target_coords)
			target_coords = null

func _on_KinematicBody2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		emit_signal("player_selected")
