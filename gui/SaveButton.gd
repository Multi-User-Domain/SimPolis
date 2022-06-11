extends TextureButton


onready var game = get_tree().current_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	rect_size = Vector2(32,32)


func _on_SaveButton_pressed():
	game.save_game()
