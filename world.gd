extends Node2D

var block = preload("res://block.tscn")
var player_p = preload("res://player.tscn")

onready var db = SQLite.new()

const BLOCK_SIZE = 128

const VIEW_SIZE = [14,6]

var level = 0
var type = 0

func _ready():
	db.open("user://data.sqlite")
	generate_world()
	
func generate_parts(direction,pos):
	if direction == global.RIGHT:
		for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x = "+str(pos.x/BLOCK_SIZE+7)+" AND pos_y > "+str(pos.y/BLOCK_SIZE-3)+" and pos_y < "+str(pos.y/BLOCK_SIZE+3)):
			add_block(tile["pos_x"],tile["pos_y"],tile["tile_type"])
	elif direction == global.LEFT:
		for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x = "+str(pos.x/BLOCK_SIZE-7)+" AND pos_y > "+str(pos.y/BLOCK_SIZE-3)+" and pos_y < "+str(pos.y/BLOCK_SIZE+3)):
			add_block(tile["pos_x"],tile["pos_y"],tile["tile_type"])
	elif direction == global.DOWN:
		for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x > "+str(pos.x/BLOCK_SIZE-7)+" AND pos_x < "+str(pos.x/BLOCK_SIZE+7)+" and pos_y = "+str(pos.y/BLOCK_SIZE+3)):
			add_block(tile["pos_x"],tile["pos_y"],tile["tile_type"])

func generate_world():
	for tile in db.fetch_array("SELECT * FROM tiles WHERE pos_x > -10 AND pos_x < 10 AND pos_y > -10 and pos_y < 10"):
		add_block(tile["pos_x"],tile["pos_y"],tile["tile_type"])
	add_player()
			
func add_block(x,y,type):
	if type != global.EMPTY:
		var block_new = block.instance()
		block_new.set_pos(Vector2(x*BLOCK_SIZE,y*BLOCK_SIZE))
		block_new.set_z(-1)
		block_new.get_node("tiles").set_frame(type)
		add_child(block_new)
		
func add_player():
	var player = player_p.instance()
	player.set_pos(Vector2(0,0))
	add_child(player)