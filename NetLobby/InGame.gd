extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	set_to_menu()

func reset_spawn():
	for child in $GameView/Spawn.get_children():
		$GameView/Spawn.remove_child(child)
		child.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Lobby_backToMenu():
	#print("_on_Lobby_backToMenu")
	set_to_menu()
	reset_spawn()

func spawn_player(id):
	#print("spawn_player: ", id)
	var player = load("res://NetLobby/Player.tscn").instance()
	player.name = str(id)
	player.set_network_master(id)
	$GameView/Spawn.add_child(player)
	yield(get_tree(), "idle_frame")
	player.set_master(player.is_network_master())

func despawn_player(id):
	#print("despawn_player: ", id)
	var player = get_tree().get_root().find_node(str(id), true, false)
	if player != null:
		player.queue_free()


func _on_Lobby_lobbyStarting(isServer):
	#print("_on_Lobby_lobbyStarting")
	set_to_lobby()


func _on_Lobby_allReady():
	#print("_on_Lobby_allReady")
	set_to_game()

func _on_Lobby_initGame():
	#print("_on_Lobby_initGame")
	pass

func set_to_game():
	$Lobby.set_visible(false)
	$Menu.set_visible(false)
	$GameView.set_visible(true)

func set_to_lobby():
	$Lobby.set_visible(true)
	$Menu.set_visible(false)
	$GameView.set_visible(false)

func set_to_menu():
	$Lobby.set_visible(false)
	$Menu.set_visible(true)
	$GameView.set_visible(false)
