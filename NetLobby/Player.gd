extends Node2D

var Snake = load("res://Scenes/Snake.tscn").instance()

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

remotesync func full_sync(snake):
	Snake = snake

func set_master(isMaster):
	#print("set_master:", isMaster)
	set_process(isMaster)
	$Status.visible = isMaster

func _process(delta):
	# process here
	pass

func _on_network_peer_connected(id):
	if is_network_master():
		# sync everything here
		full_sync(Snake)
