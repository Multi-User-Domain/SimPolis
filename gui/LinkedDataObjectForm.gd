extends Node2D


onready var wd = get_node("WindowDialog")
onready var input_urlid = wd.get_node("InputUrlid")


func _ready():
	pass

func get_title_from_item(node: Node):
	if not node.has_method("get_rdf_property"):
		return node.get_type()
	var title = node.get_rdf_property("n:fn")
	if title == null or title == "":
		title = node.get_rdf_property("@id")
	if title == null or title == "":
		return node.get_rdf_property("@type")
	return title

func configure(node: Node):
	var item_rdf = node.save()
	print(str(item_rdf))
	wd.set_title(get_title_from_item(node))
	var urlid = node.get_rdf_property("@id")
	input_urlid.set_text(urlid if urlid != null else "")
	wd.popup_centered()
