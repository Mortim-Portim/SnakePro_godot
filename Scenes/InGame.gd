extends Node2D

signal backToMenu()

export var TilesX = 32.0
export var TilesY = 32.0
export var ScreenW = 1920.0

var snakes = []
var players = []

func _ready():
	pass

func start_game():
	set_process(true)
	set_visible(true)

func stop_game():
	set_process(false)
	set_visible(false)

func reset(pls):
	players = pls
	for old_sn in $SnakeContainer.get_children():
		$SnakeContainer.remove_child(old_sn)
	snakes = []
	for pl in pls:
		snakes.append(pl.get_node("Snake"))
	$SnakeDrawer.followID = "0"
	$SnakeDrawer.TilesX = TilesX
	$SnakeDrawer.TilesY = TilesY
	$SnakeDrawer.ScreenW = ScreenW
	$SnakeDrawer.reset()
	var middle = $SnakeDrawer.get_bounds()*0.5
	var pl_num = players.size()
	for i in range(pl_num):
		$ArenaOutline/Spawns.set_unit_offset(float(i)/float(pl_num))
		players[i].reset_snake($SnakeDrawer.put_in_bounds($SnakeDrawer.world_to_tile($ArenaOutline/Spawns.get_position())), middle)
		players[i].snakeDrawer = get_node("SnakeDrawer")
		$SnakeContainer.add_child(players[i])

func _process(delta):
	for pl in players:
		if pl == null:
			players.remove(players.find(pl))
			if players.size() == 0:
				emit_signal("backToMenu")
		else:
			pl.manual_process(delta)
	#$SnakeDrawer.redraw(snakes)
