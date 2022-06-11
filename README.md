# Synopsis

This is a very early development game. I'm intending to use it to learn Godot, so I'm not committed yet to finishing it. Nevertheless I'm including some documentation on design for reference and because it's good practice

It's a city builder like game which uses cards to perform actions. The idea is that using RDF these cards can become to some extent data-driven and allow for aspects of the game to be decentralised

For working with RDF, we use [dotNetRdf](https://dotnetrdf.org). One great feature of Godot is the ability to mix GDScript and C# in the same project

# Agents

Agents are game actors, e.g. characters. They are expected to be able to perform tasks, by playing _cards_

# Objects

The recommended way to create a new object is to create a child scene inheriting from `res://objects/InteractiveObject.gd`

For an object to be interactive it needs to include the following functions signatures:
* `can_interact(agent: Node)`: returns `true` if the agent can interact with this object
* `interact(agent: Node)`: completes the interaction on behalf of the agent

For an example implementation, see the node `res://objects/Treasure.gd`
