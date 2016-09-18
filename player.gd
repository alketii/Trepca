extends KinematicBody2D

var moving = false

var root

const DISTANCE = 128
var distance_left = 128
const STEP = 4
const FALL = 4

var direction = global.DOWN
var tool_direction = global.DOWN
var ctool = 0

var stamina_max = 500
var stamina = 500
var pick

var bag_items = 0
var bag_max_items = 10
var bag_value = 0
var coins = 0

func _ready():
	root = get_node("/root/world")
	pick = root.get_node("hud/pick_pb")
	get_node("check_down").add_exception(self)
	get_node("check_right").add_exception(self)
	get_node("check_left").add_exception(self)
	get_node("check_up").add_exception(self)
	get_node("check_current").add_exception(self)
	tool_direction(global.RIGHT)
	update_stamina()
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
			if Input.is_action_pressed("move_right") and stamina > 0:
				tool_direction(global.RIGHT)
				if not get_node("check_right").is_colliding():
					root.generate_parts(global.RIGHT,get_pos())
					prep_move(global.RIGHT)
				else:
					if not get_node("check_right").get_collider().is_in_group("block"):
						root.generate_parts(global.RIGHT,get_pos())
						prep_move(global.RIGHT)
			if Input.is_action_pressed("move_left") and stamina > 0:
				tool_direction(global.LEFT)
				if not get_node("check_left").is_colliding():
					root.generate_parts(global.LEFT,get_pos())
					prep_move(global.LEFT)
				else:
					if not get_node("check_left").get_collider().is_in_group("block"):
						root.generate_parts(global.LEFT,get_pos())
						prep_move(global.LEFT)
			if Input.is_action_pressed("move_up") and stamina > 0:
				tool_direction(global.UP)
				if not get_node("check_up").is_colliding():
					if get_node("check_current").is_colliding():
						if get_node("check_current").get_collider().is_in_group("ladder"):
							root.generate_parts(global.UP,get_pos())
							prep_move(global.UP)
				else:
					if get_node("check_up").is_colliding():
						if get_node("check_up").get_collider().is_in_group("ladder"):
							if get_node("check_current").is_colliding():
								if get_node("check_current").get_collider().is_in_group("ladder"):
									root.generate_parts(global.UP,get_pos())
									prep_move(global.UP)
			if Input.is_action_pressed("move_down") and stamina > 0:
				tool_direction(global.DOWN)
				if get_node("check_down").is_colliding():
					if get_node("check_down").get_collider().is_in_group("ladder"):
						root.generate_parts(global.DOWN,get_pos())
						prep_move(global.DOWN)
					
			if Input.is_action_just_pressed("use_tool") and stamina > 1:
				stamina_down(2)
				var opos = get_pos()
				var pos = opos/Vector2(128,128)
				if pick.get_value() > 0:
					pick.set_value(pick.get_value()-1)
					if ctool == 0:
						if tool_direction == global.DOWN:
							if get_node("check_down").is_colliding():
								if get_node("check_down").get_collider().is_in_group("block"):
									get_node("check_down").get_collider().hit()
						elif tool_direction == global.UP:
							if get_node("check_up").is_colliding():
								if get_node("check_up").get_collider().is_in_group("block"):
									get_node("check_up").get_collider().hit()
						elif tool_direction == global.RIGHT:
							if get_node("check_right").is_colliding():
								if get_node("check_right").get_collider().is_in_group("block"):
									get_node("check_right").get_collider().hit()
						elif tool_direction == global.LEFT:
							if get_node("check_left").is_colliding():
								if get_node("check_left").get_collider().is_in_group("block"):
									get_node("check_left").get_collider().hit()
				if ctool == 1:
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
					root.generate_parts(global.DOWN,get_pos())
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
				
	if get_node("check_current").is_colliding():
		if get_pos() == Vector2(-256,384):
			if get_node("check_current").get_collider().get_name() == "bazaar":
				stamina = stamina_max
				coins += bag_value
				bag_value = 0
				bag_items = 0
				update_bag()
				update_coins()
				root.get_node("hud/shop").show()
		else:
			root.get_node("hud/shop").hide()
				
	if Input.is_action_just_pressed("F2"):
		root.save_player_pos()
		get_tree().change_scene("res://menu.tscn")
		
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
		
func update_stamina():
	root.get_node("hud/stamina_pb").set_value(stamina)
	
func update_bag():
	root.get_node("hud/bag_label").set_text(str(bag_items)+"/"+str(bag_max_items))

func update_coins():
	root.get_node("hud/coin_label").set_text(str(coins))
	
func bag_add(value):
	bag_items += 1
	bag_value += value
	update_bag()
	
func stamina_down(amount):
	stamina -= amount
	update_stamina()