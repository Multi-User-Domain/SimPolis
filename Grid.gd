extends TileMap


export var grid_width: int
export var grid_height: int

# 2D array of references used to access who is in each tile on the map (null means nobody)
var inhabitants = []
# whenever a character enters or exits the scene, their reference is stored for utility
# e.g. for cycling through them quickly
var agent_references = []
# dictionary of inhabitants references used for saving/loading
# each record is a mapping of urlid -> { coordinates, reference (memory address for access) }
# see function below set_inhabitant_for_saving
var inhabitants_for_saving = {}

var half_cell_size = cell_size * 0.5


func _ready():
	_init_inhabitants()

func _init_inhabitants():
	inhabitants = []
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
	
	clear_inhabitant_for_saving(cell)
	inhabitants[cell.x][cell.y] = null

func check_place_in_cell(cell: Vector2, node_size_cells: Vector2 = Vector2(1,1)):
	for i in range(node_size_cells.x):
		for j in range(node_size_cells.y):
			var check_cell = cell - Vector2(i, j)
			
			if(!can_move_to_cell(check_cell)):
				return false
	
	return true

func clear_inhabitant_for_saving(cell: Vector2):
	var inhabitant = inhabitants[cell.x][cell.y]
	if inhabitant.get('urlid'):
		inhabitants_for_saving[inhabitant.urlid] = null

func set_inhabitant_for_saving(node, cell: Vector2):
	if node.get('urlid'):
		inhabitants_for_saving[node.urlid] = {
			"coordinates": {
				"x": cell.x,
				"y": cell.y
			},
			"reference": node
		}

func get_inhabitant_for_saving(urlid):
	var inhabitant = inhabitants_for_saving[urlid]
	if inhabitant != null or not inhabitant.has_method("save"):
		return {
			"@id": urlid,
			"coordinates": {
				"x": inhabitant["coordinates"]["x"],
				"y": inhabitant["coordinates"]["y"],
				"z": 0
			},
			"object": inhabitants_for_saving[urlid]["reference"].save()
		}
	return null

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
	
	# log that the object exists (for saving/loading the map)
	set_inhabitant_for_saving(node, cell)

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

func get_map_save_data():
	# builds a JSON-LD representation of the whole map for saving
	var save_data = {}

	save_data["@context"] = {
		"mudworld": "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudworld.ttl#",
		"muditems": "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/muditems.ttl#",
		"coordinates": {
			"@id": "https://w3id.org/mdo/structure/hasCartesianCoordinates"
		},
		"object": {
			"@id": "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudworld.ttl#inhabitantData"
		},
		"x": {
			"@id": "https://w3id.org/mdo/structure/X_axisCoordinate"
		},
		"y": {
			"@id": "https://w3id.org/mdo/structure/Y_axisCoordinate"
		},
		"z": {
			"@id": "https://w3id.org/mdo/structure/Z_axisCoordinate"
		}
	}

	# save the tile map data
	save_data['mudworld:hasTileMap'] = []
	for x in range(grid_width):
		# init each row and column
		save_data['mudworld:hasTileMap'].append([])
		save_data['mudworld:hasTileMap'][x].resize(grid_height)

		# save the int value used for the map data
		# TODO: use something RDF-friendly
		for y in range(grid_height):
			save_data['mudworld:hasTileMap'][x][y] = get_cell(x, y)

	save_data["mudworld:hasSize"] = {
		"@type":"https://w3id.org/mdo/structure/CoordinateVector",
		"x": grid_width,
		"y": grid_height,
		"z":0
	}

	# save the inhabitant data
	save_data['mudworld:hasMapInhabitants'] = []
	for urlid in inhabitants_for_saving.keys():
		save_data['mudworld:hasMapInhabitants'].append(get_inhabitant_for_saving(urlid))

	return save_data

func load_tile_map_from_array(tile_map_data):
	grid_width = len(tile_map_data)
	grid_height = len(tile_map_data[0])
	_init_inhabitants()

	for x in range(len(tile_map_data)):
		for y in range(len(tile_map_data[x])):
			set_cellv(Vector2(x, y), tile_map_data[x][y])
