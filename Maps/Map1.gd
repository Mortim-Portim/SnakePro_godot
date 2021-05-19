extends Node2D


var TilesX = 32
var TilesY = 18

var spawn_areas = [[Vector2(1,1), Vector2(1,16)], [Vector2(30,1), Vector2(30,16)]]

func get_spawn_area(team_idx):
	return spawn_areas[team_idx]

func get_spawn_point(sp_area, player_percent):
	return (1.0-player_percent)*sp_area[0] + (player_percent)*sp_area[1]

func set_settings_from_snakeDrawer(sd):
	sd.transfer_tilemap_settings(get_node("TileMap"))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
