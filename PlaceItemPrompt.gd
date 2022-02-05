extends Node2D


var current_prompt_item = null


func _ready():
	clear()

func _process(delta):
	set_position(get_global_mouse_position())

func clear():
	self.hide()
	set_process(false)

func extract_item():
	var result = current_prompt_item
	remove_child(current_prompt_item)
	current_prompt_item = null
	return result

func set_new_item(indicator: Node):
	# remove pre-existing item
	if current_prompt_item != null:
		remove_child(current_prompt_item)
		current_prompt_item.queue_free()
		current_prompt_item = null
	
	current_prompt_item = indicator
	add_child(indicator)
	
	self.show()
	set_process(true)
