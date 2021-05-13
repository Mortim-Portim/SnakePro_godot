extends Node2D

export var updatePeriod = 0.5
export var TilesX = 32.0
export var TilesY = 32.0
export var ScreenW = 1920.0

var snakes = []
var players = []
var timePassed = 0.0

func _ready():
	pass

func start_game():
	set_process(true)
	set_visible(true)

func stop_game():
	set_process(false)
	set_visible(false)

func reset(pls):
	timePassed = 0.0
	players = pls
	snakes = []
	for old_sn in $SnakeContainer.get_children():
		$SnakeContainer.remove_child(old_sn)
	for player in pls:
		snakes.append(player.Snake)
	$SnakeDrawer.followID = "0"
	$SnakeDrawer.TilesX = TilesX
	$SnakeDrawer.TilesY = TilesY
	$SnakeDrawer.ScreenW = ScreenW
	$SnakeDrawer.reset()
	var middle = $SnakeDrawer.get_bounds()*0.5
	var pl_num = players.size()
	for i in range(pl_num):
		$ArenaOutline/Spawns.set_unit_offset(float(i)/float(pl_num))
		snakes[i].startPos = $SnakeDrawer.put_in_bounds($SnakeDrawer.world_to_tile($ArenaOutline/Spawns.get_position()))
		snakes[i].startDir = snakes[i].dir_to_point(snakes[i].startPos, middle)
		snakes[i].reset()
		$SnakeContainer.add_child(snakes[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timePassed += delta
	
	if Input.is_action_just_pressed("ui_left"):
		snakes[int($SnakeDrawer.followID)].to_left()
	if Input.is_action_just_pressed("ui_right"):
		snakes[int($SnakeDrawer.followID)].to_right()
	
	if timePassed > updatePeriod:
		timePassed = 0
		for snake in snakes:
			snake.move()
		$SnakeDrawer.redraw(snakes)
