extends ColorRect


func _ready():
	set_visible(false)

func _on_Card_mouse_entered():
	set_visible(true)

func _on_Card_mouse_exited():
	set_visible(false)
