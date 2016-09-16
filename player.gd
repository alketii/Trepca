extends KinematicBody2D

var moving = false

onready var root = get_node("/root/world")

const DISTANCE = 128
var distance_left = 128
const STEP = 4
const FALL = 8

var direction = global.DOWN
var tool_direction = global.DOWN
var ctool = 0

func _ready():
	get_node("check_down").add_exception(self)
	get_node("check_right").add_exception(self)
	get_node("check_left").add_exception(self)
	tool_direction(global.RIGHT)
	set_fixed_process(true)
	
func _fixed_process(delta):
	if Input.is_action_pressed("tool_1"):
		ctool = 0
		get_node("tools").set_frame(ctool)
	elif Input.is_action_pressed("tool_2"):
		ctool = 1
		get_node("tools").set_frame(ctool)
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
			if Input.is_action_pressed("move_up"):
				tool_direction(global.UP)
				if not get_node("check_up").is_colliding():
					root.generate_parts(global.UP,get_pos())
					prep_move(global.UP)
			if Input.is_action_pressed("move_down"):
				tool_direction(global.DOWN)
			if Input.is_action_just_pressed("use_tool"):
				var opos = get_pos()
				var pos = opos/Vector2(128,128)
				if ctool == 0:
					if tool_direction == global.DOWN:
						root.db.query("UPDATE tiles SET tile_type=-1 WHERE pos_x="+str(pos.x)+" AND pos_y="+str(pos.y+1))
						get_node("check_down").get_collider().queue_free()
					elif tool_direction == global.RIGHT:
						if get_node("check_right").is_colliding():
							root.db.query("UPDATE tiles SET tile_type=-1 WHERE pos_x="+str(pos.x+1)+" AND pos_y="+str(pos.y))
							get_node("check_right").get_collider().queue_free()
					elif tool_direction == global.LEFT:
						if get_node("check_left").is_colliding():
							root.db.query("UPDATE tiles SET tile_type=-1 WHERE pos_x="+str(pos.x-1)+" AND pos_y="+str(pos.y))
							get_node("check_left").get_collider().queue_free()
				elif ctool == 1:
					root.db.query("UPDATE tiles SET item_type=1 WHERE pos_x="+str(pos.x-1)+" AND pos_y="+str(pos.y))
					var ladder = root.ladder_p.instance()
					ladder.set_pos(opos)
					ladder.set_z(-1)
					root.add_child(ladder)
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
		elif direction == global.UP:
			if distance_left != 0:
				move(Vector2(0,-STEP))
				distance_left -= STEP
			else:
				moving = false
				
	if Input.is_action_just_pressed("F2"):
		root.save_player_pos()
		get_tree().reload_current_scene()
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
	elif direction == global.UP:
		get_node("tools").set_pos(Vector2(0,-64))
		get_node("tools").set_rotd(0)
		tool_direction = global.UP
	elif direction == global.DOWN:
		get_node("tools").set_pos(Vector2(0,64))
		get_node("tools").set_rotd(180)
		tool_direction = global.DOWN