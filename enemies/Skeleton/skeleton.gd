extends CharacterBody2D


const SPEED = 125.0
const JUMP_VELOCITY = -400.0

const ATTACK_COOLDOWN = 2.2
var attack_cooldown = ATTACK_COOLDOWN

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D

var player = null

var player_in_sight = false
var player_in_damage_range = false

var can_attack = true
var is_attacking = false
var flip_cooldown = 0.5
var can_flip = true
var taking_damage = false
var is_alive = true
var hp = 100 * Global.enemy_hp_scaling 
var attack_frame = 0
var movingLeft = false

var is_shielding = false
	
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
		can_attack = false
		
		animated_sprite_2d.play("attack")
		is_shielding = false
		
		velocity = Vector2(0.0, 0.0)
		
		return
		
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
			animated_sprite_2d.flip_h = true
		elif (player.position.x > position.x + 50) and movingLeft:
			movingLeft = false
			animated_sprite_2d.flip_h = false
			
		can_flip = false			
	
	
	if player and not player.is_dead and not player_in_damage_range:
		velocity.x = position.direction_to(player.position).x * SPEED
		animated_sprite_2d.play("run")
		is_shielding = false
	elif player_in_damage_range:
		is_shielding = true
		velocity = Vector2(0.0, 0.0)
		animated_sprite_2d.play("shield")
		
		
	#elif not taking_damage and is_alive and can_damage:
		#_animation_player.play("idle")
	
	move_and_slide()
	#print(velocity)


func damage(damage_value):
	if not is_alive:
		return
		
	print("hit_enemy")
	if is_shielding:
		damage_value /= 2
		
	hp -= damage_value
	is_attacking = false
	
	#if hp <= 0:
		#taking_damage = false
		#is_alive = false
		#
		#hitbox.set_deferred("disabled", true)
		#
		#animated_sprite_2d.play("death")
		#return
		#
	#print("Enemy took damage " + str(damage_value))
	taking_damage = true
	animated_sprite_2d.play("hit")
	is_shielding = false
	#else:
		#_animation_player.play("damage")

func _on_animated_sprite_2d_animation_finished():
	if is_attacking:
		animated_sprite_2d.play("shield")
		
		#can_chase = true
		is_attacking = false
		is_shielding = true
		
		#print("enemy attack ended")
		
		#if player and player_in_damage_range:
			#print("player taking damage")
			#player.damage(40)
			
	if taking_damage:
		taking_damage = false
		if hp <= 0:
			is_alive = false
			hitbox.set_deferred("disabled", true)
			animated_sprite_2d.play("death")
			is_shielding = false
			return
			
		animated_sprite_2d.play("idle")
		is_shielding = false
		
	if animated_sprite_2d.animation == "death":
		self.queue_free()

func _on_animated_sprite_2d_frame_changed():
	if is_attacking and animated_sprite_2d.get_frame() == 5:
		if player and player_in_damage_range:
			player.damage(40 * Global.enemy_damage_scaling)

func _on_weapon_collision_body_entered(body):
	if body.is_in_group("Player"):
		print("player entered damage range")
		player_in_damage_range = true


func _on_chase_area_body_entered(body):
	if not is_alive:
		return
		
	if body != self and body.is_in_group("Player"):
		player = body


func _on_chase_area_body_exited(body):
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

