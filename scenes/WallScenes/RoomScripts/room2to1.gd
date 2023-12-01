extends Node2D


func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if body.has_method("player"):
		get_tree().change_scene("res://scenes/WallScenes/room1.tscn")
		position = Vector2(105, 13)

func _on_Area2D2_body_entered(body):
	if body.has_method("player"):
		get_tree().change_scene("res://scenes/WallScenes/room9.tscn")

func _on_Area2D3_body_entered(body):
	if body.has_method("player"):
		get_tree().change_scene("res://scenes/WallScenes/room12.tscn")

func _on_Area2D4_body_entered(body):
	if body.has_method("player"):
		get_tree().change_scene("res://scenes/WallScenes/room3.tscn")
