extends Node2D

export var TilesX = 32.0
export var ScreenW = 1920.0
export var ScreenH = 1080.0
export (NodePath) var camPos
export var followID = ""

var TilesY = -1.0
var CellBounds = Vector2(150.0,150.0)

var CellSize_o = 150.0
var nil_cell = Vector2(-100, -100)

func reset():
	var cellS = ScreenW / TilesX
	var w = cellS/CellSize_o
	TilesY = floor(ScreenH/cellS)
	var h = (ScreenH/TilesY)/CellSize_o
	CellBounds = Vector2(cellS, ScreenH/TilesY)
	$TileMap.set_scale(Vector2(w,h))
	$TileMap.clear()

func get_bounds():
	return Vector2(TilesX, TilesY)

func redraw(snakes):
	$TileMap.clear()
	for snake in snakes:
		set_snake(snake)
		if snake.name == followID:
			get_node(camPos).set_position(tile_to_world(snake.get_head()))
		#print($TileMap.get_used_cells())

func tile_to_world(pos):
	return $TileMap.map_to_world(pos)*$TileMap.get_scale()

func world_to_tile(pos):
	return $TileMap.world_to_map(pos/$TileMap.get_scale())

func put_in_bounds(pos):
	var vec = Vector2(clamp(pos.x, 0, TilesX-1), clamp(pos.y, 0, TilesY-1))
	return vec

func set_snake(snake):
	var lastTile = nil_cell
	var tile = nil_cell
	var nextTile = nil_cell
	for i in range(snake.tiles.size()):
		tile = snake.tiles[i]
		if i != 0:
			nextTile = snake.tiles[i-1]
		if i != snake.tiles.size()-1:
			lastTile = snake.tiles[i+1]
		set_tile(snake.idx, lastTile, tile, nextTile)

func set_tile(idx, lastTile, tile, nextTile):
	var in_dir = Vector2.ZERO
	var out_dir = Vector2.ZERO
	var tileName = "Snk"
	var flipx = false
	var flipy = false
	var transposed = false
	if lastTile != nil_cell:
		in_dir = tile-lastTile
	if nextTile != nil_cell:
		out_dir = nextTile-tile
	if in_dir == Vector2.ZERO:
		tileName += "T"
		if out_dir.x < 0:
			flipx = true
			flipy = true
		elif out_dir.y < 0:
			flipy = true
			transposed = true
		elif out_dir.y > 0:
			flipx = true
			transposed = true
	elif out_dir == Vector2.ZERO:
		tileName += "H"
		if in_dir.y > 0:
			flipx = true
			flipy = true
		elif in_dir.x > 0:
			transposed = true
			flipx = true
		elif in_dir.x < 0:
			transposed = true
			flipy = true
	elif in_dir.is_equal_approx(out_dir):
		tileName += "B"
		if out_dir.x < 0:
			flipx = true
			flipy = true
		elif out_dir.y < 0:
			flipy = true
			transposed = true
		elif out_dir.y > 0:
			flipx = true
			transposed = true
	else:
		if in_dir.is_equal_approx(-out_dir.tangent()):
			tileName += "L"
			if out_dir.x > 0:
				transposed = true
				flipy = true
			elif out_dir.y < 0:
				flipx = true
				flipy = true
			elif out_dir.x < 0:
				transposed = true
				flipx = true
		else:
			tileName += "R"
			if out_dir.y > 0:
				flipx = true
				flipy = true
			elif out_dir.x > 0:
				transposed = true
				flipx = true
			elif out_dir.x < 0:
				transposed = true
				flipy = true
	
	if idx > 0:
		tileName += str(idx+1)
	#print(tileName)
	$TileMap.set_cell(tile.x, tile.y, $TileMap.tile_set.find_tile_by_name(tileName), flipx, flipy, transposed, Vector2.ZERO)

func save():
	var save_dict = {
		"filename" : 		get_filename(),
		"TilesX" : 			TilesX,
		"TilesY" : 			TilesY,
		"ScreenW" : 		ScreenW,
		"ScreenH" : 		ScreenH,
		"followID" : 		followID,
		"CellBounds.x" : 	CellBounds.x,
		"CellBounds.y" : 	CellBounds.y,
	}
	return save_dict
