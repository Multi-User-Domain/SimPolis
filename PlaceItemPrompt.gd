extends Node2D


onready var item = get_node("Item")


func _ready():
	clear()

func _process(delta):
	set_position(get_global_mouse_position())

func clear():
	self.hide()
	set_process(false)

func set_new_item(indicator: Node):
	# remove pre-existing item
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	add_child(indicator)
	
	self.show()
	set_process(true)
