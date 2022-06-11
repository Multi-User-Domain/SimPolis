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

func request_move(actor, cell_target: Vector2):
	if !can_move_to_cell(cell_target):
		return false

	move_to_cell(actor, cell_target)

	return true

func request_move_direction(actor, direction: Vector2):
	#
	# :return: False if not possible to move, the new grid location if it is
	#
	var cell_start = world_to_map(actor.position)
	direction = direction.normalized()
	var cell_target = cell_start + direction
	
	return request_move(actor, cell_target)

func move_to_cell(node, world_target: Vector2):
	var node_cell = world_to_map(node.position)
	var cell_target = world_to_map(world_target)
	
	empty_cell(node_cell)
	place_in_cell(node, cell_target, false)
	
	return map_to_world(cell_target)

func empty_cell(cell: Vector2):
	if(!cell_within_bounds(cell)):
		return
	
	inhabitants[cell.x][cell.y] = null

func check_place_in_cell(cell: Vector2, node_size_cells: Vector2 = Vector2(1,1)):
	for i in range(node_size_cells.x):
		for j in range(node_size_cells.y):
			var check_cell = cell - Vector2(i, j)
			
			if(!can_move_to_cell(check_cell)):
				return false
	
	return true

func place_in_cell(node, cell: Vector2, set_physical_position: bool = true):
	#
	# 	place_in_cell is intended for placing objects are bigger than 1x1 cells and which don't move
	#	return false if unable to place in the cell, true if successful
	#
	var node_size_cells = node.size_cells if node.get('size_cells') else Vector2(1,1)
	
	if(!check_place_in_cell(cell, node_size_cells)):
		return false
	
	# store references to the node's position
	for i in range(node_size_cells.x):
		for j in range(node_size_cells.y):
			var check_cell = cell - Vector2(i, j)
			
			inhabitants[check_cell.x][check_cell.y] = node
	
	# set the node's physical position on screen
	if set_physical_position:
		node.set_position(map_to_world(cell))
	
	return true # indicate success

func get_node_in_cell(cell: Vector2):
	assert(cell_within_bounds(cell), "Cell index out of bounds!")
	
	return inhabitants[cell.x][cell.y]

func cell_within_bounds(cell: Vector2):
	return cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height

func can_move_to_coords(target_coords: Vector2):
	return can_move_to_cell(world_to_map(target_coords))

func can_move_to_cell(target_cell: Vector2):
	return cell_within_bounds(target_cell) and get_node_in_cell(target_cell) == null

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

# returns true if two cells are adjacent
func cells_are_adjacent(cell_a: Vector2, cell_b: Vector2):
	return abs(cell_a.x - cell_b.x) <= 1 and abs(cell_a.y - cell_b.y) <= 1

func clear_map():
	for x in range(inhabitants.size()):
		for y in range(inhabitants[x].size()):
			empty_cell(Vector2(x, y))
