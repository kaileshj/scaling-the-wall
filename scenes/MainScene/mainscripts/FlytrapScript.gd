extends KinematicBody2D

onready var anim = $AnimationPlayer
onready var sprite = $AnimatedSprite
onready var attack_timer = $AttackTimer
onready var damage_timer = $DamageTimer
var can_attack = true
var player_in_range = false
var health = 40  # Instance-level health variable
var is_dead = false  # Instance-level death status

func _ready():
	play_idle_animation()

func _process(delta):
	check_player_status()

func check_health():
	if health <= 0 and not is_dead:
		anim.play("Death")
		is_dead = true
		Global.taking_damage = false
		player_in_range = false  # Ensure the player_in_range is reset

func play_idle_animation():
	if not is_dead:
		anim.play("Idle")

func play_attack_animation():
	if not can_attack:
		return

	anim.play("Attack")
	can_attack = false
	if damage_timer.is_stopped():
		damage_timer.start()  # Start damage timer
	attack_timer.start()  # Start attack cooldown timer

func _on_flytrapdetection_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		flip_sprite(body.global_position.x < global_position.x)
		play_attack_animation()

func _on_flytrapdetection_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		if not can_attack:
			play_idle_animation()

func flip_sprite(flip: bool):
	sprite.flip_h = flip

func _on_AttackTimer_timeout():
	can_attack = true
	if not player_in_range:
		play_idle_animation()
	elif player_in_range:
		play_attack_animation()

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Attack":
		play_idle_animation()
	if anim_name == "Death":
		is_dead = true
		queue_free()

func enemy():
	pass

func _on_DamageTimer_timeout():
	if player_in_range:
		Global.playerhealth -= 20  # Assuming you have a global player health variable

func check_player_status():
	if is_dead:
		return
	if health <= 0:
		check_health()
