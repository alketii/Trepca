extends StaticBody2D

var breakable = true
var breaked = 0
var breaked_max = 2
var x = 0
var y = 0

func _ready():
	breaked_max = get_node("tiles").get_frame()
	
	if breaked_max == 2:
		breakable = false
	
	if breaked > 0:
			get_node("breaks").show()
	
func hit():
	get_node("/root/world/player").stamina_down(2)
	if breakable:
		breaked += 1
		if breaked >= breaked_max:
			get_node("/root/world").db.query("UPDATE tiles SET tile_type=-1 WHERE pos_x="+str(x)+" AND pos_y="+str(y))
			queue_free()
		else:
			#get_node("/root/world").db.query("UPDATE tiles SET breaked="+str(breaked)+" WHERE pos_x="+str(x)+" AND pos_y="+str(y))
			if breaked > 0:
				get_node("breaks").show()
			get_node("breaks").set_frame(breaked-1)

func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
