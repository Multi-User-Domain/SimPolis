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

# behaviour record
var seeking_goal = false # lock on request
var active_goal = null
var active_task = null
var task_queue = []

signal destination_arrived # triggered when movement complete


func _ready():
	screen_size = get_viewport_rect().size

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

func load_deck():
	# TODO: actually load the deck from character data
	deck.add_card_to_deck(
		deck.load_card_from_file(Globals.ACTION_CACHE["https://raw.githubusercontent.com/calummackervoy/SimPolis/master/assets/rdf/cards/spawn_fox.json"])
	)
	deck.add_card_to_deck(
		deck.load_card_from_file(Globals.ACTION_CACHE["https://raw.githubusercontent.com/calummackervoy/SimPolis/master/assets/rdf/cards/spawn_house.json"])
	)

	# TODO: new card discovery?
	#deck.add_card_to_deck(
	#	game.get_card_scene_instance().init_card("(DEBUG) Download Card")
	#)

func load(obj):
	self.urlid = obj["@id"]

	if "http://www.w3.org/2006/vcard/ns#fn" in obj:
		self.character_name = obj["http://www.w3.org/2006/vcard/ns#fn"]
	
	if "mud:species" in obj:
		self.species = obj["mud:species"]
	
	self.jsonld_store = obj
	self.load_deck()
	
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

func seek_new_goal():
	# TODO: make request to server for new problem
	if seeking_goal:
		return
	
	seeking_goal = true
	
	active_goal = {
		"@type": Globals.MUD.QUEST,
		"n:fn": "Satisfy Hunger",
		"n:hasNote": "The Agent has become hungry, and wishes to satisfy their hunger"
	}
	
	seeking_goal = false

func seek_tasks_for_goal():
	if not len(task_queue):
		if is_active_goal_complete():
			goal_completed()
			return
		# TODO: perform goal-oriented action planning
		task_queue.push({
			"@type": Globals.MUD.QUEST_OBJECTIVE,
			"n:fn": "Satisfy Hunger",
			"n:hasNote": "The Agent has become hungry, and wishes to satisfy their hunger",
			# a shape which describes hunger being in the "needs met" of the character
			"mud:objectiveCompletedConformShape": [  {    "@id": "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/shapes/games/simpolis/needs/hungerSatisfied.ttl#HungerSatisfied",    "@type": [      "http://www.w3.org/ns/shacl#NodeShape"    ],    "http://www.w3.org/ns/shacl#property": [      {        "@id": "_:ub2bL16C17"      }    ],    "http://www.w3.org/ns/shacl#targetClass": [      {        "@id": "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudchar.ttl#Character"      }    ]  },  {    "@id": "_:ub2bL16C17",    "http://www.w3.org/ns/shacl#description": [      {        "@value": "A Character has hunger in their met needs"      }    ],    "http://www.w3.org/ns/shacl#hasValue": [      {        "@id": "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/games/simpolis.ttl#Hunger"      }    ],    "http://www.w3.org/ns/shacl#minCount": [      {        "@value": 1      }    ],    "http://www.w3.org/ns/shacl#name": [      {        "@value": "Hunger met"      }    ],    "http://www.w3.org/ns/shacl#path": [      {        "@id": "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/games/simpolis.ttl#hasMetNeeds"      }    ]  }]
		})
	
	active_task = task_queue.pop_front()

func is_active_task_complete():
	return false

func is_active_goal_complete():
	return false

func pursue_active_task():
	# TODO: read the instructions from the task and carry out the behaviour
	pass

func goal_completed():
	# TODO: notify the player?
	active_goal = null
	seek_new_goal()

func process_behaviour():
	if active_goal == null:
		seek_new_goal()
		return
	
	# assign a new active task if necessary
	if active_task == null:
		if not len(task_queue):
			seek_tasks_for_goal()
			return
		
		active_task = task_queue.pop_front()
	# check if previous task and goal is complete
	elif is_active_task_complete():
		active_task = null
		seek_tasks_for_goal()
		return
	
	# have task, not complete. Pursue the task
	pursue_active_task()
