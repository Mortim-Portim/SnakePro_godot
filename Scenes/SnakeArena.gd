extends Node2D

# Width of the tilemap
export var TilesX = 32.0
# Height of the tilemap
export var TilesY = 32.0
# Width of the game screen
export var ScreenW = 1920.0
# Size of the tiles relative to the screen width
export var RelativeTileWidth = 1.0/32.0

# Camera or parent node of camera, that is moved
export (NodePath) var camPos
# Name of the snake node that the camera should follow
export var followID = ""

# Resets the Tilemap to a scale determined by the parameters above
var CellSize_o = 150.0
var nil_cell = Vector2(-100, -100)
func reset():
	var cellS = (ScreenW * RelativeTileWidth) / CellSize_o
	$TileMap.set_scale(Vector2(cellS,cellS))
	$TileMap.clear()

# Returns the bounds of the tilemap
func get_bounds():
	return Vector2(TilesX, TilesY)

# Clears the tilemap and reassigns the tiles from the array the snakes contain, updates the position of camPos
func redraw(snakes):
	$TileMap.clear()
	for snake in snakes:
		set_snake(snake)
		if snake.name == followID:
			get_node(camPos).set_position(tile_to_world(snake.get_head()))
		#print($TileMap.get_used_cells())

# Converts the a position in the tilemap to a global position
func tile_to_world(pos):
	return $TileMap.map_to_world(pos)*$TileMap.get_scale()

# Converts the a global position to a position in the tilemap
func world_to_tile(pos):
	return $TileMap.world_to_map(pos/$TileMap.get_scale())

func put_in_bounds(pos):
	var vec = Vector2(clamp(pos.x, 0, TilesX-1), clamp(pos.y, 0, TilesY-1))
	return vec

# Assigns the tiles of one snake to the tilemap
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

# Assigns one tile to the tilemap based on the last and next tile
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
	
	if idx >= 0:
		tileName += str(idx)
	#print(tileName)
	$TileMap.set_cell(tile.x, tile.y, $TileMap.tile_set.find_tile_by_name(tileName), flipx, flipy, transposed, Vector2.ZERO)

# this is supposed to save the tilemap, but does not yet work
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
