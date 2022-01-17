extends Node2D

var selected_player

func _ready():
	$PlayerOne.position = Vector2(63, 84)
	$PlayerTwo.position = Vector2(263, 84)
	_connect_character($PlayerOne)
	_connect_character($PlayerTwo)

func _connect_character(character):
	character.connect("player_selected", self, "select_player", [character])

func select_player(player):
	selected_player = player

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if selected_player != null and event.button_index == BUTTON_RIGHT:
			selected_player.target_coords = event.position
