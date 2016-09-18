extends Node2D

var block = preload("res://block.tscn")
var player_p = preload("res://player.tscn")
var ladder_p = preload("res://items/ladder/ladder.tscn")

onready var db = SQLite.new()
var player

const BLOCK_SIZE = 128

const VIEW_SIZE = [14,6]

var level = 0
var type = 0

func _ready():
	db.open("res://worlds/data.sqlite")
	get_tree().set_auto_accept_quit(false)
	generate_world()
	
func generate_parts(direction,pos):
	player.stamina_down(1)
	if direction == global.RIGHT:
		for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x = "+str(pos.x/BLOCK_SIZE+7)+" AND pos_y > "+str(pos.y/BLOCK_SIZE-5)+" and pos_y < "+str(pos.y/BLOCK_SIZE+5)):
			add_tile(tile)
	elif direction == global.LEFT:
		for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x = "+str(pos.x/BLOCK_SIZE-7)+" AND pos_y > "+str(pos.y/BLOCK_SIZE-5)+" and pos_y < "+str(pos.y/BLOCK_SIZE+5)):
			add_tile(tile)
	elif direction == global.UP:
		for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x > "+str(pos.x/BLOCK_SIZE-7)+" AND pos_x < "+str(pos.x/BLOCK_SIZE+7)+" and pos_y = "+str(pos.y/BLOCK_SIZE-5)):
			add_tile(tile)
	elif direction == global.DOWN:
		for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x > "+str(pos.x/BLOCK_SIZE-7)+" AND pos_x < "+str(pos.x/BLOCK_SIZE+7)+" and pos_y = "+str(pos.y/BLOCK_SIZE+5)):
			add_tile(tile)

func generate_world():
	var pos = db.fetch_array("SELECT * FROM player LIMIT 1;")
	pos = pos[0]
	for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x > "+str(int(pos["pos_x"])-7)+" AND pos_x < "+str(int(pos["pos_x"])+7)+" AND pos_y > "+str(int(pos["pos_y"])-6)+" and pos_y < "+str(int(pos["pos_y"])+6)):
		add_tile(tile)
	add_player()
			
func add_tile(tile):
	var type = tile["tile_type"]
	var item = tile["item_type"]
	var x = tile["pos_x"]
	var y = tile["pos_y"]
	#var breaked = tile["breaked"]
	if type != global.EMPTY:
		var block_new = block.instance()
		block_new.set_pos(Vector2(x*BLOCK_SIZE,y*BLOCK_SIZE))
		block_new.set_z(-1)
		block_new.get_node("tiles").set_frame(type)
		block_new.x = x
		block_new.y = y
		#block_new.breaked = breaked
		add_child(block_new)
	if item != 0:
		if item == 1:
			var block_new = ladder_p.instance()
			block_new.set_pos(Vector2((x+1)*BLOCK_SIZE,y*BLOCK_SIZE))
			block_new.set_z(-1)
			add_child(block_new)

func add_player():
	var playeri = player_p.instance()
	var pos = db.fetch_array("SELECT * FROM player LIMIT 1;")
	pos = pos[0]
	playeri.set_pos(Vector2(int(pos["pos_x"])*BLOCK_SIZE,int(pos["pos_y"])*BLOCK_SIZE-BLOCK_SIZE))
	player = playeri
	add_child(playeri)

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		save_player_pos()
		get_tree().quit()

func save_player_pos():
	var pos = player.get_pos() / Vector2(128,128)
	db.query("UPDATE player SET pos_x="+str(ceil(pos.x))+" , pos_y="+str(ceil(pos.y)))
	
	

func _on_tool_1_pick_pressed():
	get_node("hud/tool_1_pick").set_focus_mode(0)
	player.ctool = 0
	player.get_node("tools").set_frame(player.ctool)

func _on_tool_2_ladder_pressed():
	get_node("hud/tool_2_ladder").set_focus_mode(0)
	player.ctool = 1
	player.get_node("tools").set_frame(player.ctool)


func _on_teleport_pressed():
	player.set_pos(Vector2(-256,384))
	player.bag_value = 0
	save_player_pos()
	get_tree().reload_current_scene()


func _on_shop_pressed():
	get_node("hud/shop_items").show()


func _on_buy_ladder_pressed():
	if player.coins > 0:
		player.coins -=1
		player.ladders += 1
		player.update_coins()
		player.update_ladders()