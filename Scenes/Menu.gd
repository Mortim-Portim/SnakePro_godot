extends Control

signal host(port)
signal join(ip, port)
signal hof
signal quit

#var snakes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#for i in range(8):
	#	var nSnake = Snake.instance()
	#	nSnake.idx = i%4
	#	snakes.append(nSnake)
	#draw_snakes_from_score()
	

#func draw_snakes_from_score():
	#var scores = []
	#for snake in snakes:
	#	scores.append(snake.score)
	#var maxScore = scores.max()
	#if maxScore == 0:
	#	maxScore = 1
	#for i in range(snakes.size()):
	#	snakes[i].startLength = 10.0*(float(scores[i])/float(maxScore))
	#	snakes[i].startPos = Vector2(0,i)
	#	snakes[i].startDir = Vector2.LEFT
	#	snakes[i].reset()
	#	for x in range(9):
	#		snakes[i].move()
	#$SnakeArena.redraw(snakes)

func _process(delta):
	pass

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
