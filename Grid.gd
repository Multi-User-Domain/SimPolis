extends TileMap


export var grid_width: int
export var grid_height: int
# an array with references to objects inhabiting a tile
var inhabitants = []
var half_cell_size = cell_size * 0.5


func _ready():
	# initialise the inhabitants map
	for x in range(grid_width):
		inhabitants.append([])
		inhabitants[x].resize(grid_height)

func _get_node_cell_type(node):
	return node.get_cell_type() if node.has_method("get_cell_type") else 1

func request_move_direction(actor, direction: Vector2):
	#
	# :return: False if not possible to move, the new grid location if it is
	#
	var cell_start = world_to_map(actor.position)
	direction = direction.normalized()
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		-1:
			return move_to_cell(actor, cell_target)
		1:
			return false

func move_to_cell(node, world_target: Vector2):
	var node_cell = world_to_map(node.position)
	var cell_target = world_to_map(world_target)
	
	empty_cell(node_cell)
	place_in_cell(node, cell_target, false)
	
	return map_to_cell_centre(cell_target)

func empty_cell(cell: Vector2):
	assert(cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height, "Cell index out of bounds!")
	
	set_cellv(cell, -1)
	inhabitants[cell.x][cell.y] = null

func place_in_cell(node, cell: Vector2, set_physical_position: bool = true):
	assert(cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height, "Cell index out of bounds!")
	
	# store references to the node's position
	set_cellv(cell, _get_node_cell_type(node))
	inhabitants[cell.x][cell.y] = node
	
	# set the node's physical position on screen
	if set_physical_position:
		node.set_position(map_to_cell_centre(cell))

func get_node_in_cell(cell: Vector2):
	assert(cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height, "Cell index out of bounds!")
	
	return inhabitants[cell.x][cell.y]

func can_move_to_coords(target_coords: Vector2):
	return can_move_to_cell(world_to_map(target_coords))

func can_move_to_cell(target_cell: Vector2):
	return get_cellv(target_cell) <= 0

func world_to_cell_centre(vector_target: Vector2):
	return map_to_cell_centre(world_to_map(vector_target))

func map_to_cell_centre(cell_target: Vector2):
	return map_to_world(cell_target) + half_cell_size

# will attempt to find an adjacent cell which is empty for movement
# will return the cell co-ordinates or null
func get_adjacent_empty_cell(cell_target: Vector2):
	var transformations = [0, -1, 1]
	
	# investigates each adjacent cell in turn and checks against can_move_to_cell
	for i in range(3):
		for j in range(3):
			# we do not investigate 0,0 - the current cell
			if j == 0 and j == i:
				continue
			
			var possible_result = cell_target + Vector2(transformations[i], transformations[j])
			
			if can_move_to_cell(possible_result):
				return possible_result
	
	return null
