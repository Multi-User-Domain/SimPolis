extends Node2D

var selected_character

func _ready():
	$Themistocles.position = Vector2(63, 84)
	$Pericles.position = Vector2(263, 84)
	_connect_character($Themistocles)
	_connect_character($Pericles)

func _connect_character(character):
	character.connect("player_selected", self, "select_character", [character])

func select_character(character):
	selected_character = character

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if selected_character != null and event.button_index == BUTTON_RIGHT:
			selected_character.target_coords = event.position
