extends "res://buildings/Building.gd"

func _ready():
	pass

# TODO: find a more DRY way to do this
func get_rdf_property(property):
	match property:
		"@type":
			return Globals.MUD_BUILDING.HOUSE
	
	return null
