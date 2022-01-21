extends TileMap


# an array with references to objects inhabiting a tile
var objects = []


func _get_node_cell_type(node):
	return node.get_cell_type() if node.has_method("get_cell_type") else 1

func _ready():
	# TODO: I would prefer to store a reference to the child directly in the cellv
	for child in get_children():
		var cell_type: int = _get_node_cell_type(child)
		print(str(child) + " is obstacle? " + str(cell_type))
		set_cellv(world_to_map(child.position), cell_type)

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
			return move_to_tile(actor, cell_start, cell_target)
		1:
			return false

func move_to_tile(node, cell_start: Vector2, cell_target: Vector2):
	set_cellv(cell_target, _get_node_cell_type(node))
	set_cellv(cell_start, -1)
	return map_to_world(cell_target) + (cell_size * 0.5)
