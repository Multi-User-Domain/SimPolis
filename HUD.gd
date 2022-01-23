extends CanvasLayer

onready var deck_tray = get_node("DeckTray")
onready var show_deck_button = get_node("ShowDeckButton")


func _on_TextureButton_pressed():
	deck_tray.set_visible(show_deck_button.pressed)
