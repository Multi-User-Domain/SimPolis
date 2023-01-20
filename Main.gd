extends Node2D

onready var place_item_prompt = get_node("ItemPlacePrompt")
onready var grid = get_node("Grid")
onready var camera = get_node("Camera")
var selected_character: Character
var selected_card: Node2D

# will be set to the hovered card by child (for detecting if a card has been selected
var mouse_hovering_over_card: Node2D = null

# TODO: duplicated logic with CardDisplay. Use @types in each then write a Spawn script
var character_scene = preload("res://characters/Player/Player.tscn")
var house_scene = preload("res://buildings/House.tscn")
var treasure_scene = preload("res://objects/Treasure.tscn")

func _ready():
	camera.init()
	load_game()

func select_character(character):
	# deselect previously selected character
	if selected_character != null:
		selected_character.deselect()
	selected_character = character

func _physics_process(delta):
	# updating the tile highlight
	var mouse_cell: Vector2 = grid.world_to_map(get_global_mouse_position())
	var mouse_coords: Vector2 = grid.map_to_world(mouse_cell)
	$TileHighlight.set_position(mouse_coords)
	$TileHighlight.color = $TileHighlight.DEFAULT_COLOR if grid.can_move_to_coords(mouse_coords) else $TileHighlight.BLOCK_COLOR

func _handle_interaction(target_node, target_cell):
	# are there restrictions on use?
	if target_node.has_method("can_interact") and not target_node.can_interact(selected_character):
		return
	
	# if I'm next to the object already, I can interact with it right away
	if grid.cells_are_adjacent(grid.world_to_map(selected_character.get_position()), target_cell):
		complete_interaction(selected_character, target_node)
		return
	
	# no - so I need to move to it first
	target_cell = grid.get_adjacent_empty_cell(target_cell)

	if target_cell != null:
		selected_character.set_target_coords(grid.move_to_cell(selected_character, grid.map_to_world(target_cell)))
		selected_character.connect("destination_arrived", self, "complete_interaction", [selected_character, target_node])

func clear_selected_card():
	selected_card = null
	place_item_prompt.clear()

func _get_mouse_event_position(pos: Vector2):
	"""
	Mouse event positions are relative to the view and don't take into account that the map might have moved
	This function takes into account camera position
	"""
	return pos + (camera.position - camera.centre_screen)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		
		# we have received a select command (left click)
		if mouse_hovering_over_card != null and event.button_index == BUTTON_LEFT:
			selected_card = mouse_hovering_over_card
			
			# set the item prompt for placement
			var rep = selected_card.get_representation()
			if rep != null:
				place_item_prompt.set_new_item(rep)
		
		# we have received an action command (right click)
		elif event.button_index == BUTTON_RIGHT:
			var event_position = self._get_mouse_event_position(event.position)
			
			# a card is active
			if selected_card != null:
				# perform the action and deselect if successful
				selected_card.act(grid.world_to_map(event_position))
			
			# no card active, move the selected character
			elif selected_character != null:
				# if the cell is empty then move there
				var target_cell: Vector2 = grid.world_to_map(event_position)
				if grid.can_move_to_cell(target_cell):
					selected_character.set_target_coords(grid.move_to_cell(selected_character, event_position))
				# there is something in the cell
				else:
					# can I interact with it?
					var target_node = grid.get_node_in_cell(target_cell)
					if target_node.has_method("interact"):
						_handle_interaction(target_node, target_cell)

func complete_interaction(agent_node, target_node):
	target_node.interact(agent_node)
	agent_node.disconnect("destination_arrived", self, "complete_interaction")

func save_game():
	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	
	var map_save_data = grid.get_map_save_data()
	
	if !("@context" in map_save_data):
		map_save_data["@context"] = {}
	
	save_file.store_line(to_json(map_save_data))
	save_file.close()

func load_game():
	var save_file = File.new()

	# no save file to load in this case, init a new one
	if not save_file.file_exists("user://savegame.save"):
		return init_new_game()

	grid.clear()

	save_file.open("user://savegame.save", File.READ)

	# load the tile map
	var map_data = parse_json(save_file.get_line())
	grid.load_tile_map_from_array(map_data['hasTileMap'])

	# load the saved objects
	for urlid in map_data['hasMapInhabitants'].keys():
		# in the save file we saved objects as their map position + their data
		var obj = map_data['hasMapInhabitants'][urlid]["object"]
		var coordinates = map_data['hasMapInhabitants'][urlid]["coordinates"]

		# the @type key will dictate to us which scene to instance
		var instance = null
		match obj.get("@type"):
			Globals.MUD_BUILDING.HOUSE:
				instance = house_scene.instance()
			Globals.MUD_CHAR.CHARACTER:
				instance = character_scene.instance()
			Globals.MUD_ITEMS.TREASURE_CHEST:
				instance = treasure_scene.instance()
		
		if instance == null:
			print("received unkown instance type in save file " + str(obj.get("@type")))
			continue

		# serializes the properties contained in the obj into the instance (overridden in each class)
		instance.load(obj)
		
		# figure out the size of the object (the number of cells it takes up)
		var size: Vector2 = Vector2(obj['size'].x, obj['size'].y) if 'size' in obj else Vector2(1,1)
		var map_position: Vector2 = Vector2(coordinates.x, coordinates.y)
		
		# place it into the cell
		var success = grid.check_place_in_cell(map_position, size)
		
		if success:
			grid.add_child(instance)
			grid.place_in_cell(instance, map_position, true)

	save_file.close()

func init_new_game():
	var themistocles = character_scene.instance()
	themistocles.character_name = "Themistocles"
	grid.add_child(themistocles)
	grid.place_in_cell(themistocles, Vector2(4,4))

	var pericles = character_scene.instance()
	pericles.character_name = "Pericles"
	grid.add_child(pericles)
	grid.place_in_cell(pericles, Vector2(8,4))

	var treasure = treasure_scene.instance()
	grid.add_child(treasure)
	grid.place_in_cell(treasure, Vector2(12, 6))

	selected_character = themistocles
	selected_character.select()
