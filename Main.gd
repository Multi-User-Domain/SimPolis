extends Node2D

var selected_character: Character

func _ready():
	$Grid.place_in_cell($Themistocles, Vector2(4,4))
	$Grid.place_in_cell($Pericles, Vector2(8,4))
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
	var mouse_pos = $Grid.world_to_map(get_global_mouse_position())
	mouse_pos = $Grid.map_to_world(mouse_pos)
	$TileHighlight.set_position(mouse_pos)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if selected_character != null and event.button_index == BUTTON_RIGHT:
			selected_character.target_coords = $Grid.world_to_cell_centre(event.position)
