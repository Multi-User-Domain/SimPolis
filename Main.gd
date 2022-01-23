extends Node2D

var selected_character: Character

func _ready():
	$Grid.place_in_cell($Themistocles, Vector2(4,4))
	$Grid.place_in_cell($Pericles, Vector2(8,4))
	$Grid.place_in_cell($Treasure, Vector2(12, 6))
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
	var mouse_cell: Vector2 = $Grid.world_to_map(get_global_mouse_position())
	var mouse_coords: Vector2 = $Grid.map_to_world(mouse_cell)
	$TileHighlight.set_position(mouse_coords)
	$TileHighlight.color = $TileHighlight.DEFAULT_COLOR if $Grid.can_move_to_coords(mouse_coords) else $TileHighlight.BLOCK_COLOR

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		# we have received an action command (right click)
		if selected_character != null and event.button_index == BUTTON_RIGHT:
			
			# if the cell is empty then move there
			var target_cell: Vector2 = $Grid.world_to_map(event.position)
			if $Grid.can_move_to_cell(target_cell):
				selected_character.set_target_coords($Grid.move_to_cell(selected_character, event.position))
			# there is something in the cell
			else:
				# can I interact with it?
				var target_node = $Grid.get_node_in_cell(target_cell)
				
				# TODO: am I next to it?
				
				# no - so I need to move to it first
				if target_node.has_method("interact"):
					# is it accessible?
					target_cell = $Grid.get_adjacent_empty_cell(target_cell)
					
					if target_cell != null:
						selected_character.set_target_coords($Grid.move_to_cell(selected_character, $Grid.map_to_world(target_cell)))
						selected_character.connect("destination_arrived", self, "complete_interaction", [selected_character, target_node])

func complete_interaction(agent_node, target_node):
	target_node.interact()
	agent_node.disconnect("destination_arrived", self, "complete_interaction")
