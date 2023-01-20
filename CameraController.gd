extends Node2D


onready var game = get_tree().current_scene
onready var camera = get_node("Camera2D")
onready var centre_screen = get_viewport_rect().size * 0.5
# absolute limits - the camera cannot be moved past these co-ordinates
var limit_pos_left
var limit_pos_right
var limit_pos_top
var limit_pos_bottom
var speed = 400

func init():
	self.set_position(centre_screen)
	self.limit_bottom = game.grid.map_to_world(Vector2(0, game.grid.grid_height)).y
	self.limit_right = game.grid.map_to_world(Vector2(game.grid.grid_width, 0)).x
	
	self.limit_pos_left = self.limit_left + centre_screen.x
	self.limit_pos_right = self.limit_right - centre_screen.x
	self.limit_pos_top = self.limit_top + centre_screen.y
	self.limit_pos_bottom = self.limit_bottom - centre_screen.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	# Clamping a value means restricting it to a given range
	position += velocity * delta
	position.x = clamp(position.x, self.limit_pos_left, self.limit_pos_right)
	position.y = clamp(position.y, self.limit_pos_top, self.limit_pos_bottom)
