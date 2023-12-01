extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 30
const SPEED = 150
const JUMP_HEIGHT = -430
const SLIDE_SPEED = 100
const SLIDE_GRAVITY = 100
const MAX_WALL_JUMPS = 1

onready var anim = $AnimationPlayer
onready var sprite = $AnimatedSprite
onready var attack_timer = $attack_cooldown
onready var regen_timer = $regen_timer
onready var health_bar = $health_bar
onready var interactable_detection = $InteractableDetection

var enemy_in_range = false
var enemies_in_range = []
var in_spikes = false
var enemy_attack_cooldown = true
var previous_health = Global.playerhealth
var motion = Vector2()
var is_attacking = false
var wall_jump_count_right = 0
var wall_jump_count_left = 0
var double_jump_count = 0

func _physics_process(delta):
	#print(Global.playerhealth)
	check_player_status()
	update_health()
	apply_gravity()
	detect_interactables()
	handle_movement()
	handle_wall_sliding(delta)
	handle_jumps(delta)
	motion = move_and_slide(motion, UP)

func apply_gravity():
	motion.y += GRAVITY

func handle_movement():
	interactable_detection.cast_to = Vector2(-100.0 if sprite.flip_h else 100.0, 0.0)
	var direction = 0
	if Input.is_action_pressed('right'):
		direction = 1
		sprite.flip_h = false
	elif Input.is_action_pressed('left'):
		direction = -1
		sprite.flip_h = true

	motion.x = direction * SPEED

	if is_on_floor() and not is_attacking and Global.taking_damage == false:
		if direction != 0:
			anim.play("Run")
		else:#ifenemy_attack_cooldown:
			anim.play("Idle")

func handle_wall_sliding(delta):
	if is_on_wall() and not is_on_floor():
		motion.y = min(motion.y + SLIDE_GRAVITY * delta, SLIDE_SPEED)
		if anim.current_animation != "WallSlide":
			anim.play("WallSlide")

	if Input.is_action_just_pressed("lmb"):
		start_attack()
		attack_timer.start()

func start_attack():
	Global.player_current_attack = true
	is_attacking = true
	anim.play("Attack")
	process_enemy_attack()

func handle_jumps(delta):
	if is_on_floor():
		reset_jump_count()
		if Input.is_action_just_pressed("ui_accept"):
			motion.y = JUMP_HEIGHT
			if not is_attacking:
				anim.play("Jump")

	elif is_on_wall() and not is_on_floor():
		handle_wall_jump()

	elif not is_on_floor() and not is_on_wall():
		if Input.is_action_just_pressed("ui_accept") and double_jump_count < 1:
			double_jump_count += 1  # Corrected variable name
			motion.y = JUMP_HEIGHT
			if not is_attacking:
				anim.play("Jump")

	if not is_on_wall() and anim.current_animation == "WallSlide":
		anim.play("Fall2")

func handle_wall_jump():
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_wall() and Input.is_action_pressed("left") and wall_jump_count_left < MAX_WALL_JUMPS:
			wall_jump_count_left += 1
			wall_jump_count_right = 0
			motion.x = -SPEED
			motion.y = JUMP_HEIGHT
		elif is_on_wall() and Input.is_action_pressed("right") and wall_jump_count_right < MAX_WALL_JUMPS:
			wall_jump_count_right += 1
			wall_jump_count_left = 0
			motion.x = SPEED
			motion.y = JUMP_HEIGHT

func reset_jump_count():
	double_jump_count = 0
	wall_jump_count_right = 0
	wall_jump_count_left = 0

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemies_in_range.append(body)
		if body.is_dead:  # Directly checking the is_dead property of the enemy instance
			body.queue_free()
	elif body.has_method("spikes"):
		in_spikes = true

func _on_player_hitbox_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)
	elif body.has_method("spikes"):
		in_spikes = false

func process_enemy_attack():
	for enemy in enemies_in_range:
		enemy.health -= 20  # Deduct health from each enemy in range
		is_attacking = false
		if enemy.health <= 0:
			enemy.check_health()  # Immediately check and update the enemy's state

func _on_attack_timer_timeout():
	Global.player_current_attack = false
	is_attacking = false

func player():
	pass  # Placeholder for player-specific logic

func update_health():
	health_bar.value = Global.playerhealth

func detect_interactables():
	if Input.is_action_just_pressed("r") and interactable_detection.is_colliding():
		var collider = interactable_detection.get_collider()
		if collider and collider.has_method("_on_interact"):
			collider._on_interact()

func check_player_status():
	if Global.playerhealth <= 0:
		restart_player()
	elif previous_health != Global.playerhealth:
		Global.taking_damage = true
		anim.play("Damage")
		previous_health = Global.playerhealth

func restart_player():
	print("Player has been killed")
	position = Vector2(336, 340)
	Global.playerhealth = 100
	Global.taking_damage = false

func _on_AnimationPlayer_animation_finished(animation_name):
	if Global.taking_damage and animation_name == "Damage":
		Global.taking_damage = false
	if animation_name == "Attack":
		is_attacking = false
	if animation_name == "Fall2" and is_on_floor():
		anim.play("Idle")
		
