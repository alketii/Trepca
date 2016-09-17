extends Node2D

onready var db = SQLite.new()

func _ready():
	randomize()
	var dir = Directory.new()
	if not dir.file_exists("res://worlds/data.sqlite"):
		#get_node("resume").set_disabled(true)
		pass

func _on_resume_pressed():
	get_tree().change_scene("res://world.tscn")

func _on_generate_pressed():
	OS.shell_open("worlds/world_gen")