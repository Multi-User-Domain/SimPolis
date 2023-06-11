extends Node2D

#
#	Service for managing the interface to a federation of servers
#	(in practice one server for now)
#

# TODO: one day.. support for federations
const SERVER_ENDPOINT = "https://api.realm.games.coop/"

onready var game = get_tree().current_scene

export(bool) var use_ssl = false
