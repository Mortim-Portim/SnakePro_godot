extends Node2D

export var syncPeriod = 1.0
export var updatePeriod = 0.5
export (PackedScene) var snakeDrawer

var time_since_last_sync = 0.0
var time_since_last_update = 0.0
var is_net_master = false
var queued_for_deletion = false

var team_id = 0
var pl_in_team_idx = 0.0
var num_of_pl_in_team = 1.0

func get_pl_in_team_percent():
	return (pl_in_team_idx+0.5)/num_of_pl_in_team

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	time_since_last_sync = 0.0

func update():
	rpc("make_move")

func manual_process(delta):
	if is_net_master:
		process_input()
	
	if is_net_master:
		time_since_last_update += delta
		if time_since_last_update >= updatePeriod:
			time_since_last_update = 0.0
			update()
	
	if is_net_master:
		time_since_last_sync += delta
		if time_since_last_sync >= syncPeriod:
			time_since_last_sync = 0.0
			sync_self()

func process_input():
	if Input.is_action_just_pressed("ui_left"):
		$Snake.to_left()
	if Input.is_action_just_pressed("ui_right"):
		$Snake.to_right()

func queue_for_deletion():
	queued_for_deletion = true

func delete():
	self.queue_free()

func _on_network_peer_connected(id):
	if is_network_master():
		# sync everything here
		sync_self()

func reset_snake(pos, middle):
	$Snake.startPos = Vector2(pos.x, pos.y)
	$Snake.startDir = $Snake.dir_to_point($Snake.startPos, middle)
	$Snake.reset()
	print("reset_snake: ", get_name(), ", middle: ", middle, ", dir: ", $Snake.startDir)

func sync_self():
	rpc("full_sync", $Snake.get_data())
remote func full_sync(data):
	print("full_sync: ", get_name())
	$Snake.set_data(data)
	redraw_if_possible()
remotesync func make_move():
	print("make_move: ", get_name())
	$Snake.move()
	redraw_if_possible()

func set_master(isMaster):
	#print("set_master: ", isMaster)
	is_net_master = isMaster

func redraw_if_possible():
	if is_instance_valid(snakeDrawer):
		snakeDrawer.redraw(get_node("Snake"), get_name())

func set_speed(tps):
	updatePeriod = 1.0/tps
