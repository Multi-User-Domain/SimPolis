# Synopsis

This is a very early development game. I'm intending to use it to learn Godot, so I'm not committed yet to finishing it. Nevertheless I'm including some documentation on design for reference and because it's good practice

# Objects

Godot does not have interfaces or abstract classes. Instead we use duck typing, i.e. we check if a function exists on a given object

For an object to be interactive it needs to include the following functions signatures:
* `can_interact(agent: Node)`: returns `true` if the agent can interact with this object
* `interact(agent: Node)`: completes the interaction on behalf of the agent

Extending the `InteractiveObject` class in the `objects` directory is recommended but since [Mixins are still a proposal in Godot](https://github.com/godotengine/godot-proposals/issues/758) if you need to inherit something else, then you can implement the functions specified above and it will still work

For an example implementation, see the node `objects/Treasure.gd`
