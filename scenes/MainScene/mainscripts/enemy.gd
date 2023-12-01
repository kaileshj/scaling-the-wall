extends KinematicBody2D

const GRAVITY = 30
const SPEED = 100
var velocity = Vector2()
var player_chase = false
var player = null
var health = 100
var player_in_zone = false
var can_take_damage = true
var go_back = false

var walk_direction = 1

onready var anim = $AnimationPlayer
onready var damage = $take_damage_cooldown
onready var sprite = $AnimatedSprite

func _physics_process(delta):
	deal_damage()

	if player_chase and player != null:
		var direction = (player.position - position).normalized()
		if go_back == true:
			velocity.x = -10
		elif go_back == false:
			velocity.x = direction.x * SPEED
		animate_character(direction.x)
	elif can_take_damage == true:
		if is_on_wall() :#or !is_on_floor():
			walk_direction *= -1
		velocity.x = walk_direction * SPEED
		animate_character(walk_direction)
	
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP)

func animate_character(direction_x):
	if direction_x > 0 and can_take_damage == true:
		sprite.flip_h = true
		anim.play("Walk")
	elif direction_x < 0 and can_take_damage == true:
		sprite.flip_h = false
		anim.play("Walk")
	elif can_take_damage == true:
		anim.play("Idle")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	walk_direction = 0
	print("Player detected")

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	#walk_direction = 1

func _on_enemy_hitbox_body_entered(body):
	if body.name == 'Player':
		player_in_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.name == 'Player':
		player_in_zone = false

func deal_damage():
	if player_in_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			velocity.y = -200
			health -= 20
			go_back = true
			can_take_damage = false
			anim.play("Damage")
			damage.start()
			print("Lizard Health: ", health)
			if health <= 0:
				self.queue_free()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true
	go_back = false

func enemy():
	pass
