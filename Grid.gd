extends TileMap


# an array with references to objects inhabiting a tile
var objects = []
var half_cell_size = cell_size * 0.5


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
	var cell_target = world_to_map(world_target)
	set_cellv(cell_target, _get_node_cell_type(node))
	set_cellv(world_to_map(node.position), -1)
	return map_to_cell_centre(cell_target)

func place_in_cell(node, cell: Vector2):
	set_cellv(cell, _get_node_cell_type(node))
	node.set_position(map_to_cell_centre(cell))

func can_move_to_cell(target_cell: Vector2):
	return get_cellv(world_to_map(target_cell)) <= 0

func world_to_cell_centre(vector_target: Vector2):
	return map_to_cell_centre(world_to_map(vector_target))

func map_to_cell_centre(cell_target: Vector2):
	return map_to_world(cell_target) + half_cell_size
