extends "res://objects/InteractiveObject.gd"

onready var animation_player = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
var is_open = false
var size_cells := Vector2(2,2)
export var urlid := ""

func _ready():
	# TODO: get a urlid from world server connection
	urlid = "_Treasure_" + str(randi())
	
	# make sure animation is in correct state
	if is_open:
		sprite.set_frame(1)

func can_interact(agent: Node):
	return !is_open

func interact(agent: Node):
	if can_interact(agent):
		animation_player.play("OpenChest")
		is_open = true

func load(obj):
	urlid = obj["@id"]
	size_cells = Vector2(obj["size"].x, obj["size"].y)
	is_open = obj["is_open"]

func save(world_position=null):
	# serializes the building into JSON-LD for saving
	var save_data = {
		"@id": urlid,
		"@type": "http://purl.org/net/VideoGameOntology#Item",
		"size": {
			"x": size_cells.x,
			"y": size_cells.y
		},
		"is_open": is_open
	}

	if world_position != null:
		save_data[world_position] = {
			"x": world_position.x,
			"y": world_position.y
		}

	return save_data
