extends KinematicBody2D


onready var animation_player = $AnimationPlayer
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
			if velocity.x > 0:
				animation_player.play("RunRight")
			else:
				animation_player.play("RunLeft")
		else:
			set_position(target_coords)
			target_coords = null
			if velocity.x > 0:
				animation_player.play("IdleRight")
			else:
				animation_player.play("IdleLeft")

func _on_KinematicBody2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		emit_signal("player_selected")
		select()

func select():
	$NameLabel.set_visible_characters(-1)

func deselect():
	$NameLabel.set_visible_characters(0)
