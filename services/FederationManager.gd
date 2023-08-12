extends Node2D

#
#	Service for managing the interface to a federation of servers
#	(in practice one server for now)
#

# TODO: one day.. support for federations
const SERVER_ENDPOINT = "https://api.realm.games.coop/"

onready var game = get_tree().current_scene
onready var generate_problem_request = get_node("GenerateProblemRequest")

export(bool) var use_ssl = false


func generate_problem_for_agent(url_endpoint, data):
	var headers = [
		"Content-Type: application/ld+json"
	]
	
	generate_problem_request.request(url_endpoint, headers, use_ssl, HTTPClient.METHOD_POST, JSON.print(data))

func _on_GenerateProblemRequest_request_completed(result, response_code, headers, body):
	pass # Replace with function body.
