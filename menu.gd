extends Node2D

onready var db = SQLite.new()

func _ready():
	randomize()
	var dir = Directory.new()
	if not dir.file_exists("user://data.sqlite"):
		get_node("resume").set_disabled(true)
	db.open("user://data.sqlite")

func _on_resume_pressed():
	get_tree().change_scene("res://world.tscn")


func _on_generate_pressed():
	get_node("generate").set_text("Please Wait...")
	get_node("generate").set_disabled(true)
	var chances = []
	var rand = 0
	var type = 0
	db.query(str("DROP TABLE IF EXISTS tiles;"))
	db.query(str("DROP TABLE IF EXISTS player;"))
	db.query(str("CREATE TABLE IF NOT EXISTS tiles (pos_x INTEGER, pos_y INTEGER, tile_type INTEGER);"))
	for y in range(100):
		for x in range(100):
			x = x - 50
			if y < 4:
				type = global.EMPTY
			elif y == 4:
				type = global.GRASS
			elif y > 4 and y < 8:
				type = global.DIRT
			else:
				chances = [0,0,0,0,0,0,0,0,1]
				rand = randi() % chances.size()
				if rand == 1:
					type = global.STONE
				else:
					type = global.DIRT
			db.query(str("INSERT INTO tiles (pos_x, pos_y, tile_type) VALUES('"+str(x)+"','"+str(y)+"','"+str(type)+"');"))
	db.query(str("CREATE TABLE IF NOT EXISTS player (pos_x INTEGER, pos_y INTEGER);"))
	db.query(str("INSERT INTO player (pos_x, pos_y) VALUES('0','2');"))
	get_node("generate").set_text("DONE!")
	get_node("resume").set_disabled(false)