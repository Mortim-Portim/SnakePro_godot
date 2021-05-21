extends Node2D


var TilesX = 32
var TilesY = 18

var spawn_areas = [[Vector2(2,2), Vector2(2,17)], [Vector2(31,2), Vector2(31,17)]]

func get_spawn_area(team_idx):
	return spawn_areas[team_idx]

func get_spawn_point(sp_area, player_percent):
	return (1.0-player_percent)*sp_area[0] + (player_percent)*sp_area[1]

func set_settings_from_snakeDrawer(sd):
	sd.transfer_tilemap_settings(get_node("TileMap"))

func collides(point):
	return $TileMap.get_cell(point.x, point.y) != TileMap.INVALID_CELL

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
