extends StaticBody2D

var ttype
var breakable = true
var breaked = 0
var breaked_max = 2
var x = 0
var y = 0
var player
var world

func _ready():
	world = get_node("/root/world")
	ttype = get_node("tiles").get_frame()
	breaked_max = ttype
	
	if breaked_max == 2:
		breakable = false
	
	if breaked > 0:
			get_node("breaks").show()
	
func hit():
	world.get_node("player").stamina_down(2)
	if breakable:
		breaked += 1
		if breaked >= breaked_max or breaked == 8:
			world.db.query("UPDATE tiles SET tile_type=-1 WHERE pos_x="+str(x)+" AND pos_y="+str(y))
			if world.get_node("player").bag_items < world.get_node("player").bag_max_items:
				if ttype > 2:
					if ttype <= (world.get_node("player").bag_value + ttype):
						world.get_node("player").bag_add(ttype)
			queue_free()
		else:
			#get_node("/root/world").db.query("UPDATE tiles SET breaked="+str(breaked)+" WHERE pos_x="+str(x)+" AND pos_y="+str(y))
			if breaked > 0:
				get_node("breaks").show()
			get_node("breaks").set_frame(breaked-1)

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
