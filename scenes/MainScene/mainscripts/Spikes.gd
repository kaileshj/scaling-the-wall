extends Area2D

func _on_Area2D_body_entered(body):
	if body.has_method("player"):
		print("Player has entered")
		Global.playerhealth = 0

func spikes():
	pass
