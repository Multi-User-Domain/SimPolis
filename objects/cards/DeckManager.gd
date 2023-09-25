extends Node

# the purpose of this node is to manage the card deck, e.g. the number of cards active in a hand,
# and to change between active deck

onready var game = get_tree().current_scene

var deck = []
var hand = []
var discard_pile = []

func add_card_to_deck(card):
	deck.append(card)

func shuffle_discard_pile_into_deck():
	deck += discard_pile
	discard_pile = []

func shuffle_hand_into_discard_pile():
	discard_pile += hand
	hand = []

func new_hand():
	shuffle_hand_into_discard_pile()
	for i in range(game.hud.hand_size):
		var card = deck.pop_back()
		# card is null if the deck is empty,
		# try shuffling discard pile into the deck
		if card == null:
			shuffle_discard_pile_into_deck()
			card = deck.pop_back()
		# if the card is still null here we've ran out of cards
		if card == null:
			break
		hand.append(card)

func set_active_deck():
	if len(hand) == 0:
		new_hand()
	game.hud.set_new_hand(hand)

func load_card_from_file(filename):
	var card_file = File.new()
	card_file.open(filename, File.READ)
	var card_data = parse_json(card_file.get_as_text())
	card_file.close()
	return card_data
