extends Node

export var idx = 0
export var startLength = 3.0
export var startPos = Vector2.ZERO
export var startDir = Vector2.DOWN

var playerName = ""
var tiles = [Vector2.ZERO]
var fett = 0.0
var score = 1.0
var currentDir = Vector2.DOWN
var readyForNextTurn = true

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

func reset():
	fett = startLength-1
	tiles = [startPos]
	currentDir = startDir
	score = 1.0
	readyForNextTurn = true

func to_left():
	changeDir(currentDir.rotated(-PI/2.0).round())
func to_right():
	changeDir(currentDir.rotated(PI/2.0).round())
func changeDir(dir):
	if readyForNextTurn:
		currentDir = dir
		readyForNextTurn = false

func move():
	readyForNextTurn = true
	tiles.push_front(tiles.front()+currentDir)
	if fett > 0:
		fett -= 1
	else:
		tiles.pop_back()

func get_head():
	return tiles.front()

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
		"readyForNextTurn" :readyForNextTurn,
		"xVec" : 			xVec,
		"yVec" : 			yVec,
	}
	return save_dict
