extends KinematicBody2D

class_name Character

onready var game = get_tree().current_scene
onready var animation_player = get_node("AnimationPlayer")
export var speed: = 400  # How fast the player will move (pixels/sec).
export var character_name: = ""
var _target_coords # can be null or Vector2
var velocity: = Vector2.ZERO
var screen_size  # Size of the game window.

signal destination_arrived # triggered when movement complete


func _ready():
	screen_size = get_viewport_rect().size
	$NameLabel.text = character_name

func _physics_process(delta):
	if _target_coords:
		if (_target_coords - get_position()).length() > 10:
			velocity = (_target_coords - get_position()).normalized() * speed
			move_and_slide(velocity, Vector2(0, -1))
			if velocity.x > 0:
				animation_player.play("RunRight")
			else:
				animation_player.play("RunLeft")
		else:
			set_position(_target_coords)
			_target_coords = null
			emit_signal("destination_arrived")
			if velocity.x > 0:
				animation_player.play("IdleRight")
			else:
				animation_player.play("IdleLeft")

func set_target_coords(coords: Vector2, callback=null):
	_target_coords = coords

func _on_KinematicBody2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		select()

func select():
	game.select_character(self)
	$NameLabel.set_visible_characters(-1)

func deselect():
	game.selected_character = null
	$NameLabel.set_visible_characters(0)
