extends Node2D

onready var game = get_tree().current_scene
onready var description_label = get_node("ColorRect/MarginContainer/Description")
onready var sprite = get_node("ColorRect/MarginContainer2/Sprite")
onready var card_depiction_http_request = get_node("HTTPRequest")
var init_scale
var init_position
var focus_position
export(float) var grow_factor = 1.5
export(Globals.PLAY_TARGET) var play_target = Globals.PLAY_TARGET.MAP
export(Globals.PLACE_TARGET) var place_target = Globals.PLACE_TARGET.NONE
export(String) var description = ""
export(Texture) var texture = null

var arrow_prompt_scene = preload("res://gui/ArrowPrompt.tscn")
var character_scene = preload("res://characters/Player/Player.tscn")
var house_scene = preload("res://buildings/House.tscn")

# NOTE: the below is a temporary variable to store what would be the response from the server
var inserts_on_complete = []

func _ready():
	pass

func init_card(desc, tex=null, play=Globals.PLAY_TARGET.NONE, place=Globals.PLACE_TARGET.NONE):
	description = desc
	texture = tex
	play_target = play
	place_target = place
	return self

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

func get_place_target_from_jsonld(card_data):
	match card_data["@type"]:
		Globals.MUD_CHAR.CHARACTER:
			return Globals.PLACE_TARGET.CHARACTER
		Globals.MUD_BUILDING.HOUSE:
			return Globals.PLACE_TARGET.HOUSE

	return null

func extract_inserts_from_action(card_data):
	if !("mudlogic:patchesOnComplete" in card_data):
		return
	
	# extract the bindings from the card_data
	inserts_on_complete = card_data["mudlogic:patchesOnComplete"]["mudlogic:inserts"]

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

func load_depiction_from_card_data(card_data):
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var http_error = card_depiction_http_request.request(card_data["foaf:depiction"])
	if http_error != OK:
		print("An error occurred in the HTTP request.")

func get_card_data_from_file(filename):
	var card_file = File.new()
	card_file.open(filename, File.READ)
	var card_data = parse_json(card_file.get_line())
	card_file.close()
	return card_data

func load_card_from_jsonld(card_data):
	if "foaf:depiction" in card_data:
		load_depiction_from_card_data(card_data)

	if "mudcard:description" in card_data:
		description = card_data["mudcard:description"]

	# read the card behaviour from jsonld data
	if "mudcard:playTarget" in card_data:
		play_target = get_play_target_from_jsonld(card_data)
		
		if play_target == Globals.PLAY_TARGET.MAP:
			place_target = get_place_target_from_jsonld(card_data)
		elif play_target == Globals.PLAY_TARGET.CHARACTER:
			extract_inserts_from_action(card_data)

func load_card_from_file(filename):
	var card_data = get_card_data_from_file(filename)
	load_card_from_jsonld(card_data)

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

# function for returning a Sprite representation of the object which is going to be placed
func get_representation():
	match place_target:
		Globals.PLACE_TARGET.CHARACTER:
			return character_scene.instance()
		Globals.PLACE_TARGET.HOUSE:
			return house_scene.instance()
		Globals.PLACE_TARGET.NONE:
			if play_target == Globals.PLAY_TARGET.NONE:
				# copy the card shape/color
				var e = get_node("ColorRect")
				var n = e.duplicate()
				# for simplicity remove children
				for child in n.get_children():
					child.queue_free()
				n.rect_size = e.rect_size * 0.5
				n.set_position(n.get_position() - (n.rect_size * 0.5))
				return n
			else:
				var arrow = arrow_prompt_scene.instance()
				arrow.scale = Vector2(0.2, 0.2)
				var half_cell = game.grid.half_cell_size
				arrow.position += Vector2(half_cell.x, -(half_cell.y * 1.25))
				return arrow
	
	return null

func get_title_from_item(item: Node):
	if not item.has_method("get_rdf_property"):
		return item.get_type()
	var title = item.get_rdf_property("n:fn")
	if title == null or title == "":
		title = item.get_rdf_property("@id")
	if title == null or title == "":
		return item.get_rdf_property("@type")
	return title

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
			var item_rdf = spawned_item.save()
			print(str(item_rdf))
			var wd = WindowDialog.new()
			wd.set_title(get_title_from_item(spawned_item))
			# TODO: bound this by the screen size & overflow with scroll bar
			wd.set_size(Vector2(300, 300))
			wd.set_resizable(true)
			game.hud.add_child(wd)
			wd.popup_centered()

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
			print(str(inhabitant.get_rdf_property("mud:species")))

func act(map_position: Vector2):
	match play_target:
		Globals.PLAY_TARGET.MAP:
			return act_place(map_position)
		Globals.PLAY_TARGET.ANY_OBJECT:
			return act_on_object(map_position)
		Globals.PLAY_TARGET.CHARACTER:
			return act_on_object(map_position)
		Globals.PLAY_TARGET.NONE:
			game.clear_selected_card()
			load_card_from_file("res://assets/cards/bite.json")
			display_card()
			return
	
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
