extends Node2D

onready var game = get_tree().current_scene
onready var description_label = get_node("ColorRect/MarginContainer/Description")
onready var sprite = get_node("ColorRect/MarginContainer2/Sprite")
var init_scale
var init_position
var focus_position
export(float) var grow_factor = 1.5
export(Globals.PLAY_TARGET) var play_target = Globals.PLAY_TARGET.MAP
export(String) var description = ""
export(Texture) var texture = null

var card_data = {}

var arrow_prompt_scene = preload("res://gui/ArrowPrompt.tscn")
var character_scene = preload("res://characters/Player/Player.tscn")
var building_scene = preload("res://buildings/Building.tscn")

# NOTE: the below is a temporary variable to store what would be the response from the server
var inserts_on_complete = []

func display_card():
	# visual effects (used in card select animation)
	init_scale = get_scale()
	init_position = get_position()
	focus_position = init_position + Vector2(0, -100)
	
	description_label.set_text(description)
	if texture != null:
		sprite.set_texture(texture)

func get_play_target_from_jsonld(card_data):
	match card_data["mudcard:playTarget"]:
		Globals.MUD_CHAR.CHARACTER:
			return Globals.PLAY_TARGET.CHARACTER
		Globals.MUD_WORLD.TILE:
			return Globals.PLAY_TARGET.MAP
		
	return Globals.PLAY_TARGET.NONE

func extract_inserts_from_action(card_data):
	inserts_on_complete = []
	if "mudlogic:postsOnComplete" in card_data:
		inserts_on_complete += card_data["mudlogic:postsOnComplete"]["mudlogic:inserts"]
	if "mudlogic:patchesOnComplete" in card_data:
		inserts_on_complete += card_data["mudlogic:patchesOnComplete"]["mudlogic:inserts"]

func _card_depiction_http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	# TODO: handle other image file types
	var image_error = image.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	# Assign to the child TextureRect node
	# TODO: sprite is not re-rendered immediately after being set
	sprite.set_texture(texture)
	# TODO: scaling should be reactive to image size
	sprite.scale = Vector2(2, 2)

func get_remote_image(urlid):
	var http_error = get_node("HTTPRequest").request(urlid)
	if http_error != OK:
		print("An error occurred in the HTTP request.")

func load_card_from_jsonld(card_data):
	self.card_data = card_data

	if "foaf:depiction" in card_data:
		var depiction = game.rdf_manager.get_texture_from_jsonld(self, card_data["foaf:depiction"])
		if depiction != null:
			sprite.set_texture(depiction)

	if "n:hasNote" in card_data:
		description = card_data["n:hasNote"]
	# TODO: depreceated
	elif "mudcard:description" in card_data:
		description = card_data["mudcard:description"]

	# read the card behaviour from jsonld data
	if "mudcard:playTarget" in card_data:
		extract_inserts_from_action(card_data)

func resolve_game_object_in_binding(binding, actor, target):
	match binding["@type"]:
		# actor can be bound as the agent (character) who played the card
		Globals.MUD_LOGIC.ACTOR_BINDING:
			return actor
		# target is bound as the object(s) on which the card was played
		# TODO: when multiple objects will need more instruction (SPARQL?)
		Globals.MUD_LOGIC.TARGET_BINDING:
			return target
		# TODO: witnesses will need to be bound by validating them against a shape
		Globals.MUD_LOGIC.WITNESS_BINDING:
			pass
	
	return null

func action_completed_effect_changes(actor, target):
	# called when an action is completed
	for binding in inserts_on_complete:
		var bound_obj = resolve_game_object_in_binding(binding, actor, target)
		for key in binding.keys():
			if key in ["@id", "@type"]:
				continue
			bound_obj.set_rdf_property(key, binding[key])

func get_first_item_to_be_placed_on_tile():
	for insert in inserts_on_complete:
		if "mudworld:hasMapInhabitants" in insert and len(insert["mudworld:hasMapInhabitants"]) > 0:
			return insert["mudworld:hasMapInhabitants"][0]
	return null

# function for loading a Sprite representation of the prompt for making the card action
# in practice, a small sprite of what will be placed, an arrow indicating the action made, the card itself to be played
func load_representation():
	# the card isn't played on anything - so just show the card itself ready to be played
	if self.play_target == Globals.PLAY_TARGET.NONE:
		# copy the card shape/color
		var e = get_node("ColorRect")
		var n = e.duplicate()
		# for simplicity remove children
		for child in n.get_children():
			child.queue_free()
		n.rect_size = e.rect_size * 0.5
		n.set_position(n.get_position() - (n.rect_size * 0.5))
		return n
	
	# the card is going to be played on the map
	if self.play_target == Globals.PLAY_TARGET.MAP and len(self.inserts_on_complete) > 0:
		# render a small version of what will be placed on the map
		var item_data = game.rdf_manager.obj_through_urlid(self.get_first_item_to_be_placed_on_tile())
		if item_data != null:
			if item_data["@type"] == Globals.MUD_CHAR.CHARACTER:
				return character_scene.instance()
			if item_data["@type"] == Globals.MUD.BUILDING:
				var b = building_scene.instance()
				game.add_child(b)
				b.load(item_data)
				game.remove_child(b)
				return b
			if "foaf:depiction" in item_data:
				# TODO: better default (loading) instance other than arrow...
				var arrow = arrow_prompt_scene.instance()
				game.rdf_manager.get_texture_from_jsonld(arrow, item_data["foaf:depiction"])
				return arrow
		# at this stage default to the arrow prompt (TODO: alternative default, so that they're clearly distinguised)
	
	# the card is going to be played on something, return an arrow to indicate this
	var arrow = arrow_prompt_scene.instance()
	arrow.scale = Vector2(0.2, 0.2)
	var half_cell = game.grid.half_cell_size
	arrow.position += Vector2(half_cell.x, -(half_cell.y * 1.25))
	return arrow

func act_place(map_position: Vector2):
	# get the size of the object to place, default to 1x1
	var item = game.place_item_prompt.get_item()
	var size: Vector2 = item.size_cells if item.get('size_cells') else Vector2(1,1)
	
	# place it into the cell
	var success = game.grid.check_place_in_cell(map_position, size)
	
	if success:
		var spawned_item = game.place_item_prompt.extract_item()
		game.grid.place_in_cell(spawned_item, map_position, true)
		game.grid.add_child(spawned_item)
		game.clear_selected_card()

		# open a dialogue to set object properties or import it from a urlid
		if spawned_item.has_method("save"):
			game.hud.display_form_for_placed_node(spawned_item)

func get_play_target_rdf_type():
	match play_target:
		Globals.PLAY_TARGET.CHARACTER:
			return Globals.MUD_CHAR.CHARACTER
	return null

func act_on_object(map_position: Vector2):
	var inhabitant = game.grid.get_node_in_cell(map_position)
	if inhabitant != null:
		if inhabitant.has_method("get_rdf_property") and (
			inhabitant.get_rdf_property("@type") == get_play_target_rdf_type() or
			play_target == Globals.PLAY_TARGET.ANY_OBJECT
		):
			# TODO: at this point, we should make the action on the server, and then base the consequences on the response
			#  temporarily to mock the server response, we instead store the consequences on the card itself
			# TODO: extract actor who played the card
			action_completed_effect_changes(null, inhabitant)
			game.clear_selected_card()

func act(map_position: Vector2):
	match play_target:
		Globals.PLAY_TARGET.MAP:
			return act_place(map_position)
		Globals.PLAY_TARGET.ANY_OBJECT:
			return act_on_object(map_position)
		Globals.PLAY_TARGET.CHARACTER:
			return act_on_object(map_position)
	
	return null

func _on_Card_mouse_entered():
	game.mouse_hovering_over_card = self
	$BackgroundGlow.set_visible(true)
	$Tween.interpolate_property(self, "position", init_position, focus_position, .5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "scale", init_scale, init_scale * grow_factor, .5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Card_mouse_exited():
	game.mouse_hovering_over_card = null
	$BackgroundGlow.set_visible(false)
	$Tween.interpolate_property(self, "position", focus_position, init_position, .5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "scale", init_scale * grow_factor, init_scale, .5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
