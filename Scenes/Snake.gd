extends Node

# Index of the character/hero and the index of the tiles to be used
export var idx = 0
# Start length of the snake in tiles
export var startLength = 3.0
# Start position of the snake
export var startPos = Vector2.ZERO
# Start direction of the snake
export var startDir = Vector2.DOWN

# Name of the Player
var playerName = ""
# Array of tiles belonging to the snakes body
var tiles = [Vector2.ZERO]
# Amount of tiles to be appended to the snake, each time the snake moves this is reduced by 1 but therefore the last snake tile is not removed, increasing the length of the snake 
var fett = 0.0
# Score to be set (e.g. the length or kills)
var score = 1.0
# Current direction of the Snake
var currentDir = Vector2.DOWN
# Set by changeDir, is applied before the next movement
var nextDir = currentDir

func get_data():
	return [idx, startLength, startPos, startDir, playerName, tiles, fett, score, currentDir, nextDir]

func set_data(data):
	idx = 			data[0]
	startLength = 	data[1]
	startPos = 		data[2]
	startDir = 		data[3]
	playerName = 	data[4]
	tiles = 		data[5]
	fett = 			data[6]
	score = 		data[7]
	currentDir = 	data[8]
	nextDir = 		data[9]

# Resets the snake at the beginning
func _ready():
	reset()

# Resets the snake based on startLength, startPos, startDir
func reset():
	fett = startLength-1
	tiles = [startPos]
	currentDir = startDir
	score = 1.0
	nextDir = currentDir

# Changes the direction of the snake before the next movement
func changeDir(dir):
	if !nextDir.is_equal_approx(dir):
		rpc("setNextDir", dir)

remotesync func setNextDir(dir):
	nextDir = dir

# Changes the direction to the left of currentDir
func to_left():
	changeDir(currentDir.rotated(-PI/2.0).round())
# Changes the direction to the right of currentDir
func to_right():
	changeDir(currentDir.rotated(PI/2.0).round())

# Applies nextDir and Moves the snake one tile in that direction
func move():
	# Set new direction
	currentDir = nextDir
	# Add the new head in front of the old head
	tiles.push_front(get_head()+currentDir)
	if fett > 0:
		# Grows the snake by one tile, but reduces fett by one
		fett -= 1
	else:
		# remove the last tile so that the length of the snake stays the same
		tiles.pop_back()

# Returns the tile representing the head of the snake
func get_head():
	return tiles.front()

# Returns the direction from p1 to p2
func dir_to_point(p1, p2):
	var dif = p2-p1
	if abs(dif.x) > abs(dif.y):
		if dif.x > 0:
			return Vector2.RIGHT
		else:
			return Vector2.LEFT
	else:
		if dif.y > 0:
			return Vector2.DOWN
		else:
			return Vector2.UP

# Returns a dictionary containing all necassary information to completely recreate the snake
func save():
	var xVec = []
	var yVec = []
	for vec in tiles:
		xVec.append(vec.x)
		yVec.append(vec.y)
	
	var save_dict = {
		"filename" : 		get_filename(),
		"id" : 				get_name(),
		"idx" : 			idx,
		"startLength" : 	startLength,
		"startPos.x" : 		startPos.x,
		"startPos.y" : 		startPos.y,
		"startDir.x" : 		startDir.x,
		"startDir.y" : 		startDir.y,
		"playerName" : 		playerName,
		"fett" : 			fett,
		"score" : 			score,
		"currentDir.x" : 	currentDir.x,
		"currentDir.y" : 	currentDir.y,
		"nextDir.x" :		nextDir.x,
		"nextDir.y" :		nextDir.y,
		"xVec" : 			xVec,
		"yVec" : 			yVec,
	}
	return save_dict
