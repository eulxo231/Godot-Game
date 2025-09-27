extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = 500

var motion = Vector2()
var is_attacking = false
var attack_timer = 0.0
var attack_duration = 0.3
var game_start_timer = 1.0  # Prevent immediate death

func _physics_process(delta):
	# Handle game start timer
	if game_start_timer > 0:
		game_start_timer -= delta
	
	# Handle attack timer
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
	
	# Apply gravity
	motion.y += GRAVITY

	# Movement (can't move while attacking)
	if not is_attacking:
		if Input.is_action_pressed("ui_right"):
			motion.x = SPEED
			$AnimatedSprite.flip_h = false
			$AnimatedSprite.play("Run")
		elif Input.is_action_pressed("ui_left"):
			motion.x = -SPEED
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.play("Run")
		else:
			motion.x = 0
			$AnimatedSprite.play("Idle")

		# Jump
		if is_on_floor():
			if Input.is_action_pressed("ui_up"):
				motion.y = -JUMP_HEIGHT
				$AnimatedSprite.play("jump")
	
	# Attack
	if Input.is_action_just_pressed("ui_accept") and not is_attacking:
		attack()

	# Move character
	motion = move_and_slide(motion, UP)

func attack():
	is_attacking = true
	attack_timer = attack_duration
	motion.x = 0  # Stop movement during attack
	$AnimatedSprite.play("Attack")
	print("Player attacked!")
	
	# Check for enemies in attack range
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) < 60:
			if enemy.has_method("take_damage"):
				enemy.take_damage(25)
				print("Hit enemy for 25 damage!")

func _on_enemy_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	# Add a small delay and check if we're actually touching an enemy
	print("Enemy collision detected!")
	if game_start_timer <= 0 and not is_attacking:  # Only die after game start timer and if not attacking
		get_tree().change_scene("res://GameOver.tscn")
