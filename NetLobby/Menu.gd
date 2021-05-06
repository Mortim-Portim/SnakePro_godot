extends Control

signal Host()
signal Join()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Host_pressed():
	emit_signal("Host")


func _on_Join_pressed():
	emit_signal("Join")
