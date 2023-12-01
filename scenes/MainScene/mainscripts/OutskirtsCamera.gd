extends Camera2D

var follow_player = false
var player_ref = null

func _on_Area2D2_body_entered(body):
	if body.name == "Player":
		follow_player = true
		player_ref = body
		self.make_current()
		print("Changed Camera")

func _process(delta):
	if follow_player and player_ref:
		global_position = player_ref.global_position

