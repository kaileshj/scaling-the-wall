extends Node2D

func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if body.has_method("player"):
		pass#get_tree().change_scene("res://scenes/WallScenes/room2.tscn")


func _on_Area2D2_body_entered(body):
	if body.has_method("player"):
		get_tree().change_scene("res://scenes/MainScene/mainscene.tscn")
