extends KinematicBody2D

var moving = true

onready var root = get_node("/root/world")

const DISTANCE = 128
var distance_left = 128
const STEP = 4
const FALL = 8

var direction = global.DOWN
var tool_direction = global.DOWN

func _ready():
	get_node("check_down").add_exception(self)
	get_node("check_right").add_exception(self)
	get_node("check_left").add_exception(self)
	tool_direction(global.RIGHT)
	set_fixed_process(true)
	
func _fixed_process(delta):
	if not moving:
		if get_node("check_down").is_colliding():
			if Input.is_action_pressed("move_right"):
				tool_direction(global.RIGHT)
				if not get_node("check_right").is_colliding():
					root.generate_parts(global.RIGHT,get_pos())
					prep_move(global.RIGHT)
			if Input.is_action_pressed("move_left"):
				tool_direction(global.LEFT)
				if not get_node("check_left").is_colliding():
					root.generate_parts(global.LEFT,get_pos())
					prep_move(global.LEFT)
			if Input.is_action_pressed("move_down"):
				tool_direction(global.DOWN)
			if Input.is_action_pressed("use_tool"):
				if tool_direction == global.DOWN:
					get_node("check_down").get_collider().queue_free()
				elif tool_direction == global.RIGHT:
					if get_node("check_right").is_colliding():
						get_node("check_right").get_collider().queue_free()
				elif tool_direction == global.LEFT:
					if get_node("check_left").is_colliding():
						get_node("check_left").get_collider().queue_free()
				moving = true
		else:
				root.generate_parts(global.DOWN,get_pos())
				prep_move(global.DOWN)
	else:
		if direction == global.DOWN:
			if distance_left != 0:
				move(Vector2(0,FALL))
				distance_left -= FALL
			else:
				if get_node("check_down").is_colliding():
					moving = false
				else:
					distance_left = DISTANCE
		elif direction == global.RIGHT:
			if distance_left != 0:
				move(Vector2(STEP,0))
				distance_left -= STEP
			else:
				moving = false
		elif direction == global.LEFT:
			if distance_left != 0:
				move(Vector2(-STEP,0))
				distance_left -= STEP
			else:
				moving = false

func prep_move(get_direction):
	direction = get_direction
	distance_left = DISTANCE
	moving = true
	
func tool_direction(direction):
	if direction == global.RIGHT:
		get_node("tools").set_rotd(0)
		get_node("tools").set_pos(Vector2(64,0))
		get_node("tools").set_flip_h(false)
		tool_direction = global.RIGHT
	elif direction == global.LEFT:
		get_node("tools").set_rotd(0)
		get_node("tools").set_pos(Vector2(-64,0))
		get_node("tools").set_flip_h(true)
		tool_direction = global.LEFT
	elif direction == global.DOWN:
		get_node("tools").set_pos(Vector2(0,64))
		get_node("tools").set_rotd(180)
		tool_direction = global.DOWN