extends KinematicBody2D

# Enemy states
enum States {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	DAMAGE,
	DEATH
}

# Constants
const GRAVITY = 500  # Adjust the gravity as needed for your game

# Enemy properties
var health = 100
var speed = 50
var damage = 10
var attack_range = 50.0  # Adjust as necessary
var patrol_points = [Vector2(-430, -1091.25), Vector2(-370, -1091.25)]  # Example patrol points
var current_patrol_point = 0
var can_attack = true
var vertical_velocity = Vector2()  # Vertical velocity for gravity
var is_dead = false  # Add is_dead to track if the enemy is dead
var amount = 20
var oldhealth = health
var taking_damage = false
# State management
var state = States.PATROL
var player = null  # Reference to the player node

# Nodes
onready var anim_player = $AnimationPlayer
onready var detection_area = $detection_area
onready var hitbox = $hitbox
onready var timer = $attack_timer  # Make sure to have a Timer node named attack_timer as a child of the enemy

# Signals
signal enemy_damaged(damage_amount, enemy_instance)

func _ready():
	# Make sure the node paths are correct, and the nodes exist in the scene
	detection_area.connect("body_entered", self, "_on_detection_area_body_entered")
	detection_area.connect("body_exited", self, "_on_detection_area_body_exited")
	hitbox.connect("body_entered", self, "_on_hitbox_body_entered")
	timer.connect("timeout", self, "_on_attack_timer_timeout")
	anim_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func _physics_process(delta):
	#print(health)
	if is_dead == true:  # Skip physics processing if the enemy is dead
		return
	else:
		vertical_velocity.y += GRAVITY * delta
		var motion = vertical_velocity
		if state == States.DEATH:  # Ensure no further actions if in DEATH state
			motion = Vector2.ZERO  # Stop any movement
		else:
			motion = move_and_slide(motion, Vector2.UP)
		match state:
			States.IDLE:
				idle_behavior()
			States.PATROL:
				patrol_behavior(delta)
			States.CHASE:
				chase_behavior(delta)
			States.ATTACK:
				attack_behavior()
			States.DAMAGE:
				pass
			States.DEATH:
				pass
		if is_on_floor():
			vertical_velocity.y = 0

func idle_behavior():
	if taking_damage == false:
		anim_player.play("Idle")

func flip_sprite(direction_x):
	if direction_x < 0:
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true

func patrol_behavior(delta):
	var direction = (patrol_points[current_patrol_point] - global_position).normalized()
	move_and_slide(direction * speed)
	if taking_damage == false:
		anim_player.play("Walk")
	flip_sprite(direction.x)
	#print(direction.x)
	if global_position.distance_to(patrol_points[current_patrol_point]) < 10:
		current_patrol_point = (current_patrol_point + 1) % patrol_points.size()

func chase_behavior(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		move_and_slide(direction * speed)
		if taking_damage == false:
			anim_player.play("Walk")
		flip_sprite(direction.x)
		#print(direction.x)
		if global_position.distance_to(player.global_position)  <= attack_range and can_attack == true:
			state = States.ATTACK

func attack_behavior():
	if player:
		var direction = (player.global_position - global_position).x
		flip_sprite(direction)
		#print(direction)
	if taking_damage == false:
		anim_player.play("Attack")
	yield(get_tree().create_timer(0.5), "timeout")  # Wait for half a second for the animation to play
	if player and global_position.distance_to(player.global_position) < attack_range and can_attack == true:
		Global.playerhealth -= 20 
		timer.start()
		can_attack = false
	state = States.CHASE  # Go back to chasing after a delay


func take_damage(amount):
	if is_dead == true:  # Do not take damage if already dead
		return
	else:
		health -= amount
		#print(health)
		emit_signal("enemy_damaged", amount, self)
		check_health() 

func check_health():
	if health <= 0 and is_dead == false:
		die()
	elif oldhealth != health and taking_damage == false:
		state = States.DAMAGE
		anim_player.play("Damage")
		oldhealth = health
		taking_damage = true
		$damage_timer.start()


func die():
	is_dead = true
	state = States.DEATH
	anim_player.play("Death")
	#ueue_free()
	#print("dead2")
	$death_timer.start()
	# Here you can add any additional logic needed for the death state,
	# such as disabling collision or movement.

func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player = body
		state = States.CHASE

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		state = States.IDLE  # Go back to IDLE or PATROL if you want it to patrol after losing sight of the player

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack" or anim_name == "Damage":
		if state == States.ATTACK:
			state = States.CHASE  # Transition to CHASE after the attack animation
		elif state == States.DAMAGE:
			state = States.IDLE  # Transition to IDLE or previous state after damage animation
	elif anim_name == "Death":
		queue_free()
		Global.taking_damage == false  # Ensure the enemy is removed after the death animation

		
func _on_hitbox_body_entered(area):
	if area.is_in_group("player_attack"):
		take_damage(area.get_damage_amount())  

func _on_attack_timer_timeout():
	can_attack = true  # Fix the assignment operator here

func enemy():
	pass


func _on_death_timer_timeout():
	queue_free()
	Global.taking_damage == false
