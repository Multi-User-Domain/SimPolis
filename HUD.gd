extends CanvasLayer

onready var deck_tray = get_node("DeckTray")
onready var show_deck_button = get_node("ShowDeckButton")

var card_scene = preload("res://objects/cards/Card.tscn")

func count_cards_in_tray():
	return deck_tray.get_child_count()

func card_deck_map_to_world(target_cell: Vector2):
	# TODO: replace this with position logic that doesn't depend on this existing
	var first_card = deck_tray.get_child(0)
	var zero_pos = first_card.position
	# for each card move the size of the card at its' scale
	var card_width = first_card.get_node("ColorRect").get_size().x * first_card.init_scale
	
	# the +10 is for adding some margin
	return zero_pos + Vector2(target_cell.x * card_width.x + 20, 0)

func add_card_to_tray():
	var card = card_scene.instance()
	card.description = "(DEBUG) Download Card"
	card.play_target = Globals.PLAY_TARGET.NONE
	card.place_target = Globals.PLACE_TARGET.NONE
	card.set_scale(Vector2(0.5, 0.5))
	deck_tray.add_child(card)
	
	var card_deck_map_position = Vector2(count_cards_in_tray() - 1, 0)
	card.set_position(card_deck_map_to_world(card_deck_map_position))
	card.init_card()

func _on_TextureButton_pressed():
	deck_tray.set_visible(show_deck_button.pressed)
