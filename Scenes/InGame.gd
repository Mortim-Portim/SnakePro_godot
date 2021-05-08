extends Node2D

export var updatePeriod = 0.5
export var TilesX = 32.0
export var ScreenW = 1920.0
export var ScreenH = 1080.0
export (PackedScene) var Snake

var snakes = []
var timePassed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$SnakeDrawer.followID = "0"
	$SnakeDrawer.TilesX = TilesX
	$SnakeDrawer.ScreenW = ScreenW
	$SnakeDrawer.ScreenH = ScreenH
	$SnakeDrawer.reset()
	var middle = $SnakeDrawer.get_bounds()*0.5
	for i in range(8):
		$ArenaOutline/Spawns.set_unit_offset(float(i)/8.0)
		var nSnake = Snake.instance()
		nSnake.idx = i%4
		nSnake.set_name(str(i+2))
		nSnake.startPos = $SnakeDrawer.put_in_bounds($SnakeDrawer.world_to_tile($ArenaOutline/Spawns.get_position()))
		nSnake.startDir = nSnake.dir_to_point(nSnake.startPos, middle)
		nSnake.reset()
		snakes.append(nSnake)
		add_child(nSnake)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timePassed += delta
	
	if Input.is_action_just_pressed("ui_left"):
		snakes[0].to_left()
	
	
	if timePassed > updatePeriod:
		timePassed = 0
		for snake in snakes:
			snake.move()
		$SnakeDrawer.redraw(snakes)
