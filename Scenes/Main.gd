extends Node

export (PackedScene) var Snake

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Menu_hof():
	print("hof")


func _on_Menu_play(ip, port):
	print("play")


func _on_Menu_quit():
	print("quit")
