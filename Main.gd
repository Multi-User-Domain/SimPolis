extends Node2D

onready var place_item_prompt = get_node("ItemPlacePrompt")
onready var grid = get_node("Grid")
var selected_character: Character
var selected_card: Node2D

# will be set to the hovered card by child (for detecting if a card has been selected
var mouse_hovering_over_card: Node2D = null

var character_scene = preload("res://characters/Player/Player.tscn")

func _ready():
	grid.place_in_cell($Themistocles, Vector2(4,4))
	grid.place_in_cell($Pericles, Vector2(8,4))
	grid.place_in_cell($Treasure, Vector2(12, 6))
	selected_character = $Themistocles
	selected_character.select()
	_connect_character($Themistocles)
	_connect_character($Pericles)

func _connect_character(character):
	character.connect("player_selected", self, "select_character", [character])

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

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		
		# we have received a select command (left click)
		if mouse_hovering_over_card != null and event.button_index == BUTTON_LEFT:
			var new_fox = character_scene.instance()
			selected_card = mouse_hovering_over_card
			place_item_prompt.set_new_item(new_fox)
		
		# we have received an action command (right click)
		elif event.button_index == BUTTON_RIGHT:
			
			# a card is active
			if selected_card != null:
				# perform the action and deselect if successful
				selected_card.act(grid.world_to_map(event.position))
			
			# no card active, move the selected character
			elif selected_character != null:
				# if the cell is empty then move there
				var target_cell: Vector2 = grid.world_to_map(event.position)
				if grid.can_move_to_cell(target_cell):
					selected_character.set_target_coords(grid.move_to_cell(selected_character, event.position))
				# there is something in the cell
				else:
					# can I interact with it?
					var target_node = grid.get_node_in_cell(target_cell)
					if target_node.has_method("interact"):
						_handle_interaction(target_node, target_cell)

func complete_interaction(agent_node, target_node):
	target_node.interact(agent_node)
	agent_node.disconnect("destination_arrived", self, "complete_interaction")
