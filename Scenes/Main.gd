extends Node

func _ready():
	show_menu_only()

func _on_Menu_hof():
	print("_on_Menu_hof")

func _on_Menu_host(port):
	print("_on_Menu_host")
	$PreLobby.host(port)
	show_prelobby_only()

func _on_Menu_join(ip, port):
	print("_on_Menu_join: ", "ip: ", ip, ", port: ", port)
	$PreLobby.join(ip, port)
	show_prelobby_only()

func _on_Menu_quit():
	print("_on_Menu_quit")
	get_tree().quit()

func _on_PreLobby_backToMenu():
	print("_on_PreLobby_backToMenu")
	$InGame.stop_game()
	show_menu_only()

func _on_InGame_backToMenu():
	print("_on_InGame_backToMenu")
	$InGame.stop_game()
	show_menu_only()

func _on_PreLobby_initGame():
	print("_on_PreLobby_initGame")


func _on_PreLobby_startGame(pls):
	print("_on_PreLobby_startGame: ", pls)
	$InGame.reset(pls)
	$InGame.start_game()
	show_ingame_only()


func show_menu_only():
	$Menu.set_visible(true)
	$InGame.set_visible(false)
	$PreLobby.set_visible(false)

func show_ingame_only():
	$Menu.set_visible(false)
	$InGame.set_visible(true)
	$PreLobby.set_visible(false)

func show_prelobby_only():
	$Menu.set_visible(false)
	$InGame.set_visible(false)
	$PreLobby.set_visible(true)
