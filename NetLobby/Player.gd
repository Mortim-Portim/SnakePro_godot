extends KinematicBody2D


var direction = Vector2()

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")

func set_master(isMaster):
	print("set_master:", isMaster)
	set_physics_process(isMaster)
	$Status.visible = isMaster

func _physics_process(delta):
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.y = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")
	direction = direction.normalized()
	move_and_slide(direction * 500)
	
	if direction != Vector2(): # If we are moving the character sends rpc call
		rpc("transform_data", transform)
	
	if Input.is_action_just_pressed("ui_accept"):
		rpc("visibility", !visible)

remote func transform_data(data):
	transform = data

remotesync func visibility(data):
	visible = data

func _on_network_peer_connected(id):
	if is_network_master():
		rpc("transform_data", transform)
		rpc("visibility", visible)
