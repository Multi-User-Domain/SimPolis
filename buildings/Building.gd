extends Node2D

onready var game = get_tree().current_scene
onready var sprite = get_node("Sprite")
export(int) var building_width_cells = 2
export(int) var building_height_cells = 2


func _ready():
	# resize the sprite to the correct proportions
	var sprite_size = sprite.get_texture().get_size()
	if sprite_size.x > 0 and sprite_size.y > 0:
		var desired_size = Vector2(building_width_cells * game.grid.cell_size.x, building_height_cells * game.grid.cell_size.y)
		sprite.set_scale(Vector2((desired_size.x / sprite_size.x), (desired_size.y / sprite_size.y)))
