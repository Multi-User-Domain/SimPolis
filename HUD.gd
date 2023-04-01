extends CanvasLayer

export var card_scale = Vector2(0.5, 0.5)
onready var deck_tray = get_node("DeckTray")
onready var show_deck_button = get_node("ShowDeckButton")
onready var card_width = 128 * card_scale.x

func count_cards_in_tray():
	return deck_tray.get_child_count()

func card_deck_map_to_world(target_cell: Vector2):
	# position from the start of the deck tray by the number of cards along and by their width
	var x_increase = target_cell.x * card_width
	# add margin if it's not the first
	if x_increase > 0:
		x_increase += (target_cell.x * 10)
	return Vector2(x_increase, 0)

func add_card_to_tray(card):
	deck_tray.add_child(card)
	
	# position the card on the tray and display it
	var card_deck_map_position = Vector2(count_cards_in_tray() - 1, 0)
	card.set_position(card_deck_map_to_world(card_deck_map_position))
	card.set_scale(card_scale)
	card.display_card()

func _on_TextureButton_pressed():
	deck_tray.set_visible(show_deck_button.pressed)
