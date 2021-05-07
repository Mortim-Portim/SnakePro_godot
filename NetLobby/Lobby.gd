extends Control

signal lobbyStarting(isServer)
signal backToMenu()
signal spawn_player(id)
signal despawn_player(id)
signal allReady()
signal initGame()

var isServer = false
var netID = -1
var accepting_new_player = true
var playerName = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	get_tree().connect("connection_failed", self, "_on_server_disconnected")

func reset_net():
	reset_labels()
	isServer = false
	netID = -1
	accepting_new_player = true
	playerName = ""

func reset_labels():
	for label in $Names.get_children():
		if label.name != "inLobby":
			$Names.remove_child(label)
			label.queue_free()

func create_server(port = 8080):
	isServer = true
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(port, 32)
	if err != OK:
		print(err)
		return
	get_tree().set_network_peer(peer)
	accepting_new_player = true
	emit_signal("lobbyStarting", isServer)
	load_game()

func join_server(name, ip = "127.0.0.1", port = 8080):
	isServer = false
	playerName = name
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip, port)
	if err != OK:
		print(err)
		return
	get_tree().set_network_peer(peer)
	accepting_new_player = true
	emit_signal("lobbyStarting", isServer)

func _on_network_peer_connected(id):
	print(netID, ": new connection: ", id)
	if !accepting_new_player:
		get_tree().network_peer.disconnect_peer(id)
	else:
		if id != 1:
			addName(id, str(id))
		if netID > 1:
			rpc("setName", netID, playerName)

func _on_network_peer_disconnected(id):
	if id != 1:
		remName(id)

func _on_connected_to_server():
	load_game()

func _on_server_disconnected():
	emit_signal("backToMenu")
	print("disconnecting")
	reset_net()
	if get_tree().network_peer != null:
		get_tree().network_peer.close_connection()
		get_tree().set_network_peer(null)

func load_game():
	emit_signal("initGame")
	if not get_tree().is_network_server():
		netID = get_tree().get_network_unique_id()
		if playerName == "":
			playerName = str(netID)
		addName(netID, playerName)
		rpc("setName", netID, playerName)
	else:
		netID = 1

func _on_Button_pressed():
	rpc("startGame")

func addName(id, name):
	print("adding: ", id, ", name: ", name)
	emit_signal("spawn_player", id)
	var Name = $Names/inLobby.duplicate()
	Name.name = "Label_"+str(id)
	Name.text = name
	$Names.add_child(Name)
	sortNames()

remotesync func setName(id, name):
	print("setting: ", id, ", name: ", name)
	var found = false
	for n in $Names.get_children():
		if n.name == "Label_"+str(id):
			n.text = name
			found = true
			sortNames()
	if !found:
		addName(id, name)

func remName(id):
	emit_signal("despawn_player", id)
	for n in $Names.get_children():
		if n.name == "Label_"+str(id):
			n.queue_free()

func sortNames():
	var childs = $Names.get_children()
	var names = []
	for c in childs:
		names.append(c.name)
	names.sort()
	for n in names:
		$Names.move_child($Names.get_node(n), 0)
	$Names.move_child($Names/inLobby, 0)

remotesync func startGame():
	emit_signal("allReady")
	accepting_new_player = false
