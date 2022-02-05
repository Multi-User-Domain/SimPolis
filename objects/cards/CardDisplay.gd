extends Node2D

onready var game = get_tree().current_scene
var init_scale
var init_position
var focus_position
export(float) var grow_factor = 1.5
export(Globals.CARD_TYPE) var card_type = Globals.CARD_TYPE.PLACE

func _ready():
	init_scale = get_scale()
	init_position = get_position()
	focus_position = init_position + Vector2(0, -100)

func act(map_position: Vector2):
	# for now the card just places its object in the cell
	var success = game.grid.place_in_cell(game.place_item_prompt, map_position, false)
	
	if success:
		var spawned_item = game.place_item_prompt.extract_item()
		spawned_item.set_position(game.grid.map_to_cell_centre(map_position))
		game.grid.add_child(spawned_item)
		game.clear_selected_card()

func _on_Card_mouse_entered():
	game.mouse_hovering_over_card = self
	$BackgroundGlow.set_visible(true)
	$Tween.interpolate_property(self, "position", init_position, focus_position, .5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "scale", init_scale, init_scale * grow_factor, .5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Card_mouse_exited():
	game.mouse_hovering_over_card = null
	$BackgroundGlow.set_visible(false)
	$Tween.interpolate_property(self, "position", focus_position, init_position, .5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "scale", init_scale * grow_factor, init_scale, .5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
