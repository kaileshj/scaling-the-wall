extends Area2D

var spikesup = false
var player_in_range = false 

func _ready():
	spikeup()

func _on_Area2D_body_entered(body):
	if body.name == 'Player':
		player_in_range = true
		if spikesup == true:
			print('take damage')
			Global.playerhealth -=10

func spikeup():
	$AnimationPlayer.play("up")
	spikesup = true
	if player_in_range == true:
		Global.playerhealth -=10
	$Timer.start()

func _on_Area2D_body_exited(body):
	player_in_range = false

func _on_Timer_timeout():
	$AnimationPlayer.play("down")
	spikesup = false
	$Timer2.start()


func _on_Timer2_timeout():
	spikeup()
