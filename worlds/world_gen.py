import sqlite3
import random

ttype = 0
tiles = []

width = 100
height = 1000

width_offet = width / 2

con = sqlite3.connect('data.sqlite')
con.execute("DROP TABLE IF EXISTS tiles")
con.execute("DROP TABLE IF EXISTS player")
con.execute("CREATE TABLE IF NOT EXISTS player (pos_x INTEGER, pos_y INTEGER)")
con.execute("INSERT INTO player (pos_x, pos_y) VALUES('0','2')")
con.execute("CREATE TABLE IF NOT EXISTS tiles (pos_x INTEGER, pos_y INTEGER, tile_type INTEGER, breaked INTEGER DEFAULT 0, item_type INTEGER DEFAULT 0)")

for y in range(height):
	for x in range(width):
		x = x - width_offet
		if y < 4:
			ttype = -1
		elif y == 4:
			ttype = 0
		elif y > 4 and y <= 8:
			ttype = 1
		elif y > 8 and y <= 20:
			chances = [1,1,1,1,2,2]
			ttype = chances[random.randint(0,len(chances))-1]

		elif y > 20 and y <= 50:
			chances = [1,1,1,1,2,2,3,3]
			ttype = chances[random.randint(0,len(chances))-1]
		elif y > 50 and y <= 100:
			chances = [1,1,1,1,2,2,2,3,3,3,4,4]
			ttype = chances[random.randint(0,len(chances))-1]
		else:
			ttype = 2
			
				
		tiles.append((x,y,ttype))
		
con.executemany("INSERT INTO tiles (pos_x, pos_y, tile_type) values (?,?,?)", tiles)
con.commit()
