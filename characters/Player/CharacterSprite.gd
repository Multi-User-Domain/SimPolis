extends Sprite

export var sprite_size = Vector2(64, 64)


func _load_texture_from_jsonld(data):
	# has a texture been given with the data?
	if "2Dgraphics:hasTexture" in data:
		# TODO
		pass

	# if not, attempt to find a texture based on the species
	elif "mud:species" in data:
		if data["mud:species"] == Globals.SPECIES.VAMPIRE:
			set_texture(load("res://assets/fox/vampire.png"))

	# default to generic character sprite
	else:
		set_texture(load("res://assets/fox/fox.png"))

func load_sprite_from_jsonld(data):
	_load_texture_from_jsonld(data)

	# TODO: load animations
	# card_data["2Dgraphics:animation"]
