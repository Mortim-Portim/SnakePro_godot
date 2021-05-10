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

func _on_Join_pressed():
	if active:
		$Lobby.join_server($Buttons/Name.get_text(), ipAddr, port)
		deactivate()

func host(port = 8080):
	$Lobby.create_server(port)
	deactivate()

func join(ip = "127.0.0.1", p = 8080):
	ipAddr = ip
	port = p
	activate()

func _on_Lobby_backToMenu():
	emit_signal("backToMenu")
	reset()

func spawn_player(id):
	pass
#	var player = load("res://NetLobby/Player.tscn").instance()
#	player.name = str(id)
#	player.set_network_master(id)
#	$GameView/Spawn.add_child(player)
#	yield(get_tree(), "idle_frame")
#	player.set_master(player.is_network_master())

func despawn_player(id):
	pass
#	var player = get_tree().get_root().find_node(str(id), true, false)
#	if player != null:
#		player.queue_free()


func _on_Lobby_lobbyStarting(isServer):
	$Lobby.set_visible(true)

func _on_Lobby_allReady():
	emit_signal("startGame", players)
	reset()

func _on_Lobby_initGame():
	emit_signal("initGame")

func activate():
	active = true
	set_visible(true)
	$Buttons/Name.set_text("Name")

func deactivate():
	active = false
	set_visible(false)
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
