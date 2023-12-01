extends Node2D

func _on_Start_pressed():
	pass#get_tree().change_scene("res://scenes/MainScene/mainscene.tscn")


func _on_Quit_pressed():
	pass#get_tree().quit()


func _on_Start_button_down():
	get_tree().change_scene("res://scenes/MainScene/mainscene.tscn")


func _on_Quit_button_down():
	get_tree().quit()
