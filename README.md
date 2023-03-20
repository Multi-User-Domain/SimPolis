# Synopsis

This is a very early development game. I'm intending to use it to learn Godot, so I'm not committed yet to finishing it. Nevertheless I'm including some documentation on design for reference and because it's good practice

It's a city builder like game which uses cards to perform actions. The idea is that using RDF these cards can become to some extent data-driven and allow for aspects of the game to be decentralised

For working with RDF, we use [dotNetRdf](https://dotnetrdf.org). One great feature of Godot is the ability to mix GDScript and C# in the same project

# RDF-Ready Nodes

In Godot all objects ultimately inherit from `Node`

Nodes which are RDF-ready should have the following attributes and functions:
* A string `urlid` (This is a URL that is globally unique. [More information on webid and graph data](https://inqlab.net/2019-11-19-a-primer-on-the-semantic-web-and-linked-data.html))
* Function `get_type` which should return a URL and indicate the RDF type of the node.
* Functions `load` and `save` for parsing and serializing JSON-LD data to and from the node. Common classes like agents and buildings already provide implementations of this. Not everything has to be JSON-LD, but anything that isn't won't be shared in the federation (it will be local to the game, and other games won't know about it at all)

# Agents

Agents are game actors, e.g. characters. They are expected to be able to perform tasks, by playing _cards_

# Objects

The recommended way to create a new object is to create a child scene inheriting from `res://objects/InteractiveObject.gd`

For an object to be interactive it needs to include the following functions signatures:
* `can_interact(agent: Node)`: returns `true` if the agent can interact with this object
* `interact(agent: Node)`: completes the interaction on behalf of the agent

For an example implementation, see the node `res://objects/Treasure.gd`
