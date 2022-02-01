extends Node2D

onready var game = get_tree().current_scene
var init_scale
var init_position
var focus_position
export var grow_factor: float = 1.5

func _ready():
	init_scale = get_scale()
	init_position = get_position()
	focus_position = init_position + Vector2(0, -100)

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
