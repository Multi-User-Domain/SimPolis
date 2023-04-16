extends Node2D


onready var wd = get_node("WindowDialog")


func _ready():
	pass

func get_title_from_item(item: Node):
	if not item.has_method("get_rdf_property"):
		return item.get_type()
	var title = item.get_rdf_property("n:fn")
	if title == null or title == "":
		title = item.get_rdf_property("@id")
	if title == null or title == "":
		return item.get_rdf_property("@type")
	return title

func configure(node: Node):
	var item_rdf = node.save()
	print(str(item_rdf))
	wd.set_title(get_title_from_item(node))
	wd.popup_centered()
