extends Node2D

onready var game = get_tree().current_scene
onready var description_label = get_node("ColorRect/MarginContainer/Description")
onready var sprite = get_node("ColorRect/MarginContainer2/Sprite")
var init_scale
var init_position
var focus_position
export(float) var grow_factor = 1.5
export(Globals.PLAY_TARGET) var play_target = Globals.PLAY_TARGET.MAP
export(Globals.PLACE_TARGET) var place_target = Globals.PLACE_TARGET.CHARACTER
export(String) var description = ""
export(Texture) var texture = null

var character_scene = preload("res://characters/Player/Player.tscn")
var house_scene = preload("res://buildings/House.tscn")

func _ready():
	init_scale = get_scale()
	init_position = get_position()
	focus_position = init_position + Vector2(0, -100)
	init_card()

func init_card():
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

func load_card_from_jsonld():
	# read card from file
	# TODO: fetch card from server
	var card_file = File.new()
	card_file.open("res://assets/cards/bite.json", File.READ)
	var card_data = parse_json(card_file.get_line())
	card_file.close()

	if "mudcard:description" in card_data:
		description = card_data["mudcard:description"]

	# read the card behaviour from jsonld data
	if "mudcard:playTarget" in card_data:
		play_target = get_play_target_from_jsonld(card_data)
		
		if play_target == Globals.PLAY_TARGET.MAP:
			place_target = get_place_target_from_jsonld(card_data)
		elif play_target == Globals.PLAY_TARGET.CHARACTER:
			pass

	init_card()

# function for returning a Sprite representation of the object which is going to be placed
func get_representation():
	match place_target:
		Globals.PLACE_TARGET.CHARACTER:
			return character_scene.instance()
		Globals.PLACE_TARGET.HOUSE:
			return house_scene.instance()
	
	return null

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

func act(map_position: Vector2):
	match play_target:
		Globals.PLAY_TARGET.MAP:
			return act_place(map_position)
		Globals.PLAY_TARGET.NONE:
			return load_card_from_jsonld()
	
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
