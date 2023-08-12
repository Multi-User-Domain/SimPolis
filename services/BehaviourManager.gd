extends Node2D


onready var game = get_tree().current_scene


func process_behaviour():
	for character in game.grid.agent_references:
		character.process_behaviour()


func _on_ProcessBehaviourTimer_timeout():
	process_behaviour()
