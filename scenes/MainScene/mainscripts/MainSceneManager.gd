extends Node2D

func _on_AreaSwitch_body_entered(body):
	if body.has_method("player"):
		get_tree().change_scene("res://scenes/WallScenes/room1.tscn")
