extends KinematicBody2D

class_name Character

onready var game = get_tree().current_scene
onready var sprite = get_node("Sprite")
onready var animation_player = get_node("AnimationPlayer")
onready var deck = get_node("DeckManager")
export var speed: = 400  # How fast the player will move (pixels/sec).
export var character_name: = ""
export var urlid := ""
export var species:String = Globals.SPECIES.HUMAN
var _target_coords # can be null or Vector2
var velocity: = Vector2.ZERO
var screen_size  # Size of the game window.
var jsonld_store = {}

signal destination_arrived # triggered when movement complete


func _ready():
	screen_size = get_viewport_rect().size
	
	# TODO: replace with individual cards
	deck.add_card_to_deck(
		game.get_card_scene_instance().init_card("Spawn a new Fox", load("res://assets/objects/card/birth.png"), Globals.PLAY_TARGET.MAP, Globals.PLACE_TARGET.CHARACTER)
	)
	deck.add_card_to_deck(
		game.get_card_scene_instance().init_card("Build a new house", load("res://assets/objects/buildings/house_1.png"), Globals.PLAY_TARGET.MAP, Globals.PLACE_TARGET.HOUSE)
	)
	deck.add_card_to_deck(
		game.get_card_scene_instance().init_card("(DEBUG) Download Card")
	)

func refresh_character_display():
	$NameLabel.text = character_name
	if urlid == null:
		# TODO: get a urlid from world server connection
		urlid = "_Player_" + character_name + str(randi())

func set_character_name(name: String):
	character_name = name
	refresh_character_display()

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

func load(obj):
	self.urlid = obj["@id"]

	if "http://www.w3.org/2006/vcard/ns#fn" in obj:
		self.character_name = obj["http://www.w3.org/2006/vcard/ns#fn"]
	
	if "mud:species" in obj:
		self.species = obj["mud:species"]
	
	self.jsonld_store = obj
	
	self.sprite.load_sprite_from_jsonld(obj)
	self.refresh_character_display()

func save(world_position=null):
	# serializes the character into JSON-LD for saving
	var save_data = {
		"@id": urlid,
		"@type": get_rdf_property("@type"),
		"http://www.w3.org/2006/vcard/ns#fn": character_name,
		"mud:species": species
	}

	if world_position != null:
		save_data[world_position] = {
			"@type": "https://w3id.org/mdo/structure/CoordinateVector",
			"x": world_position.x,
			"y": world_position.y,
			"z": 0
		}
	
	return save_data

# TODO: find a more DRY way to do this
func get_rdf_property(property):
	match property:
		"@type":
			return Globals.MUD_CHAR.CHARACTER
		"mud:species":
			return species
		"vcard:fn":
			return character_name
		"n:fn":
			return character_name
		# TODO: expanding/compacting - RDF library (C#) for this
		"http://www.w3.org/2006/vcard/ns#fn":
			return character_name
	
	if property in jsonld_store:
		return jsonld_store[property]
	
	return null

func set_rdf_property(property, value):
	match property:
		"mud:species":
			species = value
		"n:fn":
			self.set_character_name(value)
	jsonld_store[property] = value
