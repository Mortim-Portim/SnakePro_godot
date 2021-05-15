extends Control

# Signals when the player leaves the lobby
signal backToMenu()
# Signals when the game should be started
signal startGame(pls)
# Signals when the game should be loaded
signal initGame()

# Do not access any of these variables
var ipAddr = ""
var port = 0
var active = false
var players = []

func _ready():
	reset()

func host(port = 8080):
	reset()
	deactivate()
	$Lobby.create_server(port)

func join(ip = "127.0.0.1", p = 8080):
	reset()
	ipAddr = ip
	port = p
	activate()

func _on_Join_pressed():
	if active:
		$Lobby.join_server($Buttons/Name.get_text(), ipAddr, port)
		deactivate()

func _on_Lobby_backToMenu():
	emit_signal("backToMenu")

func spawn_player(id):
	print("spawn_player: ", id, ", netID: ", $Lobby.netID)
	var player = load("res://NetLobby/Player.tscn").instance()
	player.name = str(id)
	player.set_network_master(id)
	player.set_master(id == $Lobby.netID)
	players.append(player)

func despawn_player(id):
	print("despawn_player: ", id)
	for player in players:
		if player.name == str(id):
			player.queue_free()

func _on_Lobby_lobbyStarting(isServer):
	$Lobby.set_visible(true)

func _on_Lobby_allReady():
	emit_signal("startGame", players)

func _on_Lobby_initGame():
	emit_signal("initGame")

func activate():
	active = true
	$Buttons.set_visible(true)
	$Buttons/Name.set_text("Name")

func deactivate():
	active = false
	$Buttons.set_visible(false)
	ipAddr = ""
	port = 0

func reset_spawn():
	for pl in players:
		pl.queue_free()
	players = []

func reset():
	deactivate()
	reset_spawn()
	$Lobby.set_visible(false)
