extends Node2D

export var syncPeriod = 1.0
export var updatePeriod = 0.5
export (PackedScene) var snakeDrawer

var time_since_last_sync = 0.0
var time_since_last_update = 0.0
var is_net_master = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	time_since_last_sync = 0.0

func update():
	rpc("make_move")

func set_master(isMaster):
	print("set_master: ", isMaster)
	is_net_master = isMaster

func _process(delta):
	if !is_net_master:
		return
	process_input()
	
	time_since_last_update += delta
	if time_since_last_update >= updatePeriod:
		time_since_last_update = 0.0
		update()
	
	time_since_last_sync += delta
	if time_since_last_sync >= syncPeriod:
		time_since_last_sync = 0.0
		sync_self()

func process_input():
	if Input.is_action_just_pressed("ui_left"):
		$Snake.to_left()
	if Input.is_action_just_pressed("ui_right"):
		$Snake.to_right()

func set_speed(tps):
	updatePeriod = 1.0/tps

func _on_network_peer_connected(id):
	if is_network_master():
		# sync everything here
		sync_self()

func reset_snake(pos, middle):
	$Snake.startPos = pos
	$Snake.startDir = $Snake.dir_to_point($Snake.startPos, middle)
	$Snake.reset()

func sync_self():
	rpc("full_sync", $Snake.get_data())
remote func full_sync(data):
	$Snake.set_data(data)
	redraw_if_possible()
remotesync func make_move():
	$Snake.move()
	redraw_if_possible()

func redraw_if_possible():
	if snakeDrawer != null:
		snakeDrawer.redraw([get_node("Snake")])
