extends "res://buildings/Building.gd"


func _ready():
	pass

func save(world_position=null):
	var save_data = .save(world_position)
	save_data["@type"] = Globals.MUD_BUILDING.HOUSE
	return save_data
