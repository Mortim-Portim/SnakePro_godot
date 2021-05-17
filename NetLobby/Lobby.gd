extends Control

# Signals when the player joins the lobby
signal lobbyStarting(isServer)
# Signals when the player leaves the lobby
signal backToMenu()
# Singals when a new player of a certain id should be spawned
signal spawn_player(id)
# Singals when a new player of a certain id should be despawned
signal despawn_player(id)
# Signals when any player presses the start button
signal allReady()
# Signals when the game should be loaded
signal initGame()
# Signals when an error occurs
signal onError(err)

var isServer = false
# network ID, 1 = server, -1 = not assigned
var netID = -1
# determines if player can join the lobby
var accepting_new_player = true
# the name of the player
var playerName = ""

# connects the network signals
func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	get_tree().connect("connection_failed", self, "_on_server_disconnected")
	reset_net()

# resets the lobby
func reset_net():
	reset_labels()
	isServer = false
	netID = -1
	accepting_new_player = true
	playerName = ""

# resets the name labels
func reset_labels():
	for label in $Names.get_children():
		if label.name != "inLobby":
			$Names.remove_child(label)
			label.queue_free()

# hosts a server on the speciefied port
func create_server(port = "8080"):
	isServer = true
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(int(port), 32)
	if err != OK:
		print("error while creating server on port: ", port, " : ", err)
		close_peer(peer)
		reset_net()
		emit_signal("onError", err)
		return
	get_tree().set_network_peer(peer)
	accepting_new_player = true
	load_game()
	emit_signal("lobbyStarting", isServer)

# joins a server and sets the player name
func join_server(name, ip = "127.0.0.1", port = "8080"):
	#print("join_server: ", "ip: ", ip, ", port: ", str(int(port)))
	isServer = false
	playerName = name
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip, int(port))
	if err != OK:
		print("error while joining server: ", err)
		close_peer(peer)
		reset_net()
		emit_signal("onError", err)
		return
	get_tree().set_network_peer(peer)
	accepting_new_player = true
	emit_signal("lobbyStarting", isServer)

# called when a new connection is established
func _on_network_peer_connected(id):
	#print(netID, ": new connection: ", id)
	if !accepting_new_player:
		# disconnect the newly connected peer
		get_tree().network_peer.disconnect_peer(id)
	else:
		# if the new peer is not the server add a name label
		if id != 1:
			addName(id, str(id))
		# if this is a client and is already initialized the own playername is added or changed on each peer
		if netID > 1:
			rpc("setName", netID, playerName)

# called when a peer disconnects, despawns the player
func _on_network_peer_disconnected(id):
	if id != 1:
		remName(id)

# called once the connection tho the server is established, loads the game
func _on_connected_to_server():
	load_game()

# called once disconnected from the server, resets this node
func _on_server_disconnected():
	#print("_on_server_disconnected")
	reset_net()
	close_peer(get_tree().network_peer)
	emit_signal("backToMenu")

func close_peer(peer):
	if is_instance_valid(peer):
		peer.close_connection()
	get_tree().set_network_peer(null)

# loads the game
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

# starts the game on each client
func _on_Button_pressed():
	rpc("startGame")

# adds a name label
func addName(id, name):
	print("addName: ", id, ", name: ", name)
	emit_signal("spawn_player", id)
	var Name = $Names/inLobby.duplicate()
	Name.name = "Label_"+str(id)
	Name.text = name
	$Names.add_child(Name)
	sortNames()

# sets or adds a name label on each peer
remotesync func setName(id, name):
	print("setName: ", id, ", name: ", name)
	var found = false
	for n in $Names.get_children():
		if n.name == "Label_"+str(id):
			n.text = name
			found = true
			sortNames()
	if !found:
		addName(id, name)

# removes and despawns a player
func remName(id):
	print("remName: ", id)
	emit_signal("despawn_player", id)
	for n in $Names.get_children():
		if n.name == "Label_"+str(id):
			n.queue_free()

# sorts the name labels
func sortNames():
	var childs = $Names.get_children()
	var names = []
	for c in childs:
		names.append(c.name)
	names.sort()
	for n in names:
		$Names.move_child($Names.get_node(n), 0)
	$Names.move_child($Names/inLobby, 0)

# starts the game on each peer
remotesync func startGame():
	accepting_new_player = false
	emit_signal("allReady")
