extends Control

signal host(port)
signal join(ip, port)
signal hof
signal quit

func _on_HallOfFame_pressed():
	emit_signal("hof")
func _on_Quit_pressed():
	$ConfirmationDialog.set_visible(true)
func _on_Controller_pressed():
	pass # Replace with function body.


func _on_Host_pressed():
	emit_signal("host", $Port.get_text())
func _on_Play_pressed():
	emit_signal("join", $IpAddr.get_text(), $Port.get_text())


func _on_ConfirmationDialog_confirmed():
	emit_signal("quit")
