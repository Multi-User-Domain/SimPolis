extends Node2D

onready var game = get_tree().current_scene
onready var sprite = get_node("Sprite")
export(Vector2) var size_cells = Vector2(2,2)
export var urlid := ""
export var building_name := ""


func _ready():
	# resize the sprite to the correct proportions
	var sprite_size = sprite.get_texture().get_size()
	if sprite_size.x > 0 and sprite_size.y > 0:
		var desired_size = size_cells * game.grid.cell_size
		sprite.set_scale(Vector2((desired_size.x / sprite_size.x), (desired_size.y / sprite_size.y)))
	# TODO: get a urlid from world server connection
	urlid = "_Building_" + building_name + str(randi())

func load(obj):
	urlid = obj["@id"]
	size_cells = Vector2(obj["size"].x, obj["size"].y)

	if "http://www.w3.org/2006/vcard/ns#fn" in obj:
		building_name = obj["http://www.w3.org/2006/vcard/ns#fn"]

func save(world_position=null):
	# serializes the building into JSON-LD for saving
	var save_data = {
		"@id": urlid,
		"@type": Globals.MUD.BUILDING,
		"http://www.w3.org/2006/vcard/ns#fn": building_name,
		"size": {
			"x": size_cells.x,
			"y": size_cells.y
		}
	}

	if world_position != null:
		save_data[world_position] = {
			"x": world_position.x,
			"y": world_position.y
		}

	return save_data
