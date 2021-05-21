extends Node2D

export var shrinking_speed = 1.0
export var syncPeriod = 1.0
export var updatePeriod = 0.25
export (PackedScene) var snakeDrawer

var time_since_last_sync = 0.0
var time_since_last_update = 0.0
var time_since_last_shrinking = 0.0
var is_net_master = false
var queued_for_deletion = false

var team_id = 0
var pl_in_team_idx = 0.0
var num_of_pl_in_team = 1.0

var sync_only_changing_on_next_update = false
var shrinking_period = 0.0

func get_pl_in_team_percent():
	return (pl_in_team_idx+0.5)/num_of_pl_in_team

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	time_since_last_sync = 0.0

func update_all(delta, map):
	if !map.collides($Snake.get_next_tile()):
		set_shrinking_speed(0.0)
		make_move()
	else:
		set_shrinking_speed(shrinking_speed)
	redraw_if_possible()

func manual_process(delta, map):
	if is_net_master:
		process_input()
	
	time_since_last_update += delta
	if time_since_last_update >= updatePeriod:
		time_since_last_update = 0.0
		update_all(delta, map)
	
	if shrinking_period > 0.0001:
		time_since_last_shrinking += delta
		if time_since_last_shrinking >= shrinking_period:
			time_since_last_shrinking = 0.0
			$Snake.shrink_by_one()
	
	if is_net_master:
		time_since_last_sync += delta
		if time_since_last_sync >= syncPeriod:
			time_since_last_sync = 0.0
			sync_self()
		elif sync_only_changing_on_next_update:
			sync_only_changing_on_next_update = false
			sync_only_changing()

func process_input():
	var changes = false
	if Input.is_action_just_pressed("ui_left"):
		changes = $Snake.to_left()
	if Input.is_action_just_pressed("ui_right"):
		changes = $Snake.to_right()
	if changes:
		sync_only_changing_on_next_update = true

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
	rpc("set_time_since_last_update", time_since_last_update)
remote func full_sync(data):
	#print("full_sync: ", get_name())
	$Snake.set_data(data)
	redraw_if_possible()
remotesync func make_move():
	#print("make_move: ", get_name())
	$Snake.move()
remotesync func set_speed(tps):
	updatePeriod = 1.0/tps
remote func set_time_since_last_update(val):
	time_since_last_update = val

func sync_only_changing():
	rpc("only_changing_sync", $Snake.get_only_changing())
remote func only_changing_sync(data):
	$Snake.set_only_changing(data)
	redraw_if_possible()

remote func sync_shrinking_period(sp):
	shrinking_period = sp
	time_since_last_shrinking = 0.0

func set_shrinking_speed(speed):
	var sp = 0.0
	if speed != 0.0:
		sp = 1.0/speed
	if abs(sp-shrinking_period) > 0.00001:
		shrinking_period = sp
		if is_net_master:
			rpc("sync_shrinking_period", sp)

func set_master(isMaster):
	#print("set_master: ", isMaster)
	is_net_master = isMaster

func redraw_if_possible():
	if is_instance_valid(snakeDrawer):
		snakeDrawer.redraw(get_node("Snake"), get_name())
