extends Node2D

signal backToMenu()

export var ScreenW = 1920.0

var snakes = []
var players = []
var world_map

func _ready():
	stop_game()

func start_game():
	set_process(true)
	set_visible(true)

func stop_game():
	set_process(false)
	set_visible(false)

func reset(pls, map):
	world_map = map
	players = pls
	for old_sn in $SnakeContainer.get_children():
		$SnakeContainer.remove_child(old_sn)
	snakes = []
	for pl in pls:
		snakes.append(pl.get_node("Snake"))
	
	$SnakeDrawer.followID = "0"
	$SnakeDrawer.TilesX = world_map.TilesX
	$SnakeDrawer.TilesY = world_map.TilesY
	$SnakeDrawer.ScreenW = ScreenW
	$SnakeDrawer.reset()
	
	world_map.set_settings_from_snakeDrawer(get_node("SnakeDrawer"))
	
	var middle = $SnakeDrawer.get_bounds()*0.5
	var pl_num = players.size()
	for i in range(pl_num):
		players[i].reset_snake(world_map.get_spawn_point(world_map.get_spawn_area(players[i].team_id), players[i].get_pl_in_team_percent()), middle)
		players[i].snakeDrawer = get_node("SnakeDrawer")
		if players[i].is_net_master:
			$SnakeDrawer.followID = players[i].name
		$SnakeContainer.add_child(players[i])

func _process(delta):
	for pl in players:
		if pl.queued_for_deletion:
			players.remove(players.find(pl))
			pl.delete()
			if players.size() == 0:
				emit_signal("backToMenu")
		else:
			pl.manual_process(delta)
	#$SnakeDrawer.redraw(snakes)
