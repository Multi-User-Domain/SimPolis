extends KinematicBody2D

class_name Character

onready var game = get_tree().current_scene
onready var animation_player = get_node("AnimationPlayer")
export var speed: = 400  # How fast the player will move (pixels/sec).
export var character_name: = ""
export var urlid := ""
var _target_coords # can be null or Vector2
var velocity: = Vector2.ZERO
var screen_size  # Size of the game window.

signal destination_arrived # triggered when movement complete


func _ready():
	screen_size = get_viewport_rect().size
	$NameLabel.text = character_name
	# TODO: get a urlid from world server connection
	urlid = "_Player_" + character_name + str(randi())

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

func set_position(position: Vector2):
	position += game.grid.half_cell_size
	.set_position(position)

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

func save(world_position=null):
	# serializes the character into JSON-LD for saving
	var save_data = {
		"@id": urlid,
		"http://www.w3.org/2006/vcard/ns#fn": character_name
	}

	if world_position != null:
		save_data[world_position] = {
			"x": world_position.x,
			"y": world_position.y
		}
	
	return save_data
