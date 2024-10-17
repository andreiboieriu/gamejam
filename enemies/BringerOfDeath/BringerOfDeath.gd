extends CharacterBody2D


const speed = 100.0
const JUMP_VELOCITY = -400.0

var hp = 100 * Global.enemy_hp_scaling
var taking_damage = false
var is_alive = true

var player = null
var can_chase = true

var can_attack = true
var attack_cooldown = 2
var player_in_damage_range = false

@onready var hitbox_left = $CollisionFlipHFalse
@onready var hitbox_right = $CollisionFlipHTrue

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var left_weapon_collision = $WeaponCollisionLeft/CollisionPolygon2D
@onready var right_weapon_collision = $WeaponCollisionRight/CollisionPolygon2D



var leftBoundary = Vector2(0.0, 0.0)
var rightBoundary = Vector2(0.0, 0.0)

var movingLeft = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var _animation_player = $AnimatedSprite2D

func _ready():
	leftBoundary = position - Vector2(100.0, 0.0)
	rightBoundary = position + Vector2(100.0, 0.0)
	
var flip_cooldown = 0.5
var can_flip = true
var is_attacking = false

var attack_frame = 0

func _physics_process(_delta):
	if not is_alive:
		return
		
	if is_attacking or taking_damage:
		return
	
	if not can_attack:
		attack_cooldown -= _delta
		
		if attack_cooldown <= 0.0:
			can_attack = true
			attack_cooldown = 2
			
	if player and player_in_damage_range and can_attack and is_on_floor():
		is_attacking = true
		attack_frame = 0
		can_attack = false
		
		_animation_player.play("attack")
		velocity = Vector2(0.0, 0.0)
		
		return
		
	#if movingLeft:
		#_animation_player.flip_h = false
	#else:
		#_animation_player.flip_h = true
		
	if movingLeft:
		hitbox_left.set_deferred("disabled", false)
		hitbox_right.set_deferred("disabled", true)
		left_weapon_collision.set_deferred("disabled", false)
		right_weapon_collision.set_deferred("disabled", true)		
	else:
		hitbox_left.set_deferred("disabled", true)
		hitbox_right.set_deferred("disabled", false)
		left_weapon_collision.set_deferred("disabled", true)
		right_weapon_collision.set_deferred("disabled", false)	
		
	if not is_on_floor():
		velocity.y += gravity * _delta
		
	if not can_flip:
		flip_cooldown -= _delta
		
		if flip_cooldown <= 0:
			can_flip = true
			flip_cooldown = 0.5
		
	if player and can_flip and not player.is_dead:
		if (player.position.x < position.x - 50) and not movingLeft:
			movingLeft = true
			_animation_player.flip_h = false
			position.x -= 120
		elif (player.position.x > position.x + 50) and movingLeft:
			movingLeft = false
			_animation_player.flip_h = true
			position.x += 120
			
		can_flip = false			
	
	
	if player and not player.is_dead:
		velocity.x = position.direction_to(player.position).x * speed
		_animation_player.play("run")
	elif player:
		_animation_player.play("idle")
		
		
	#elif not taking_damage and is_alive and can_damage:
		#_animation_player.play("idle")
	
	move_and_slide()
	#print(velocity)


func damage(damage_value):
	if not is_alive:
		return
		
	print("hit_enemy")
	hp -=damage_value
	is_attacking = false
	
	if hp <= 0:
		taking_damage = false
		is_alive = false
		
		hitbox_left.set_deferred("disabled", true)
		hitbox_right.set_deferred("disabled", true)
		
		_animation_player.play("death")
		$death_sound.play()
		return
		
	print("Enemy took damage " + str(damage_value))
	taking_damage = true
	_animation_player.play("fast_damage")
	$damage_sound.play()
	#else:
		#_animation_player.play("damage")

func _on_animated_sprite_2d_animation_finished():
	if is_attacking:
		_animation_player.play("idle")
		
		can_chase = true
		is_attacking = false
		
		#print("enemy attack ended")
		
		#if player and player_in_damage_range:
			#print("player taking damage")
			#player.damage(40)
			
	if taking_damage:
		taking_damage = false
		if hp <= 0:
			is_alive = false
			_animation_player.play("death")
			return
		_animation_player.play("idle")
	if _animation_player.animation == "death":
		self.queue_free()


func _on_weapon_collision_body_entered(body):
	if body.is_in_group("Player"):
		print("player entered damage range")
		player_in_damage_range = true


func _on_chase_area_body_entered(body):
	if not is_alive:
		return
		
	if body != self and body.is_in_group("Player"):
		player = body


func _on_chase_area_body_exited(_body):
	pass
	#if not is_alive:
		#return
		#
	#if body.is_in_group("Player"):
		#player = null


func _on_weapon_collision_body_exited(body):
	if body.is_in_group("Player"):
		print("player exited damage range")		
		player_in_damage_range = false

func _on_animated_sprite_2d_frame_changed():
	if (is_attacking):
		attack_frame += 1
		
		if (attack_frame == 4):
			if player and player_in_damage_range:
				$hit_sound.play()
				player.damage(40 * Global.enemy_damage_scaling)
			else:
				$miss_sound.play()

