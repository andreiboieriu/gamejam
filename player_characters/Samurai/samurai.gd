extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var hp = 100
var is_dead = false

var isLeft = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var right_weapon_coll = $AnimatedSprite2D/WeaponCollision/RightWeaponColl
@onready var left_weapon_coll = $AnimatedSprite2D/WeaponCollision/LeftWeaponColl
@onready var hitbox = $CollisionPolygon2D

var can_attack = true
var attacking_cooldown = 0.5
var is_attacking = false
var is_taking_damage = false

var enemies = []

var attack_frame = 0

var run_sound_playing = true
var jump_sound_played = false

func _ready():
	left_weapon_coll.set_deferred("disabled", false)
	right_weapon_coll.set_deferred("disabled", false)

func _physics_process(delta):
	if is_on_floor():
		jump_sound_played = false
		
	if position.y > 2500:
		hitbox.set_deferred("disabled", true)
		right_weapon_coll.set_deferred("disabled", true)
		left_weapon_coll.set_deferred("disabled", true)		
		#animated_sprite_2d.play("death")
		$run_sound.stop()
		$hit_sound.stop()
		$miss_sound.stop()
		$damage_sound.stop()
		$death_sound.play()
		
		animated_sprite_2d.stop()
		is_dead = true
		get_tree().change_scene_to_file("res://menus/menu.tscn") 
		
		return
	
	if is_attacking or is_taking_damage or is_dead:
		return
		
	if Input.is_action_just_pressed("right_click") and is_on_floor() and can_attack:
		animated_sprite_2d.animation = "attacking"
		velocity = Vector2(0.0, 0.0)
		can_attack = false
		is_attacking = true
		attack_frame = 0
		
		print("now attacking")
		return
		
	if not can_attack:
		attacking_cooldown -= delta
		
		if attacking_cooldown <= 0.0:
			attacking_cooldown = 1.0
			can_attack = true
	
	if (velocity.x > 1 || velocity.x < -1):
		animated_sprite_2d.animation = "running"
		if not run_sound_playing and is_on_floor():
			$run_sound.play()
			run_sound_playing = true
	else:
		animated_sprite_2d.animation = "idle"
		$run_sound.stop()
		run_sound_playing = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		animated_sprite_2d.animation = "jumping"
		$run_sound.stop()
		run_sound_playing = false

	 #Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if not jump_sound_played:
			$jump_sound.play()
			jump_sound_played = true
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x = Input.get_axis("left", "right")
	
	if direction_x:
		velocity.x = direction_x * SPEED
		isLeft = velocity.x < 0
		
	else:
		velocity.x = move_toward(velocity.x, 0, 20)

	move_and_slide()
	
	animated_sprite_2d.flip_h = isLeft

func _on_animated_sprite_2d_animation_finished():
	if is_attacking:
		is_attacking = false
		animated_sprite_2d.play("idle")
				
		print("finished attacking")
	elif is_taking_damage:
		is_taking_damage = false
		animated_sprite_2d.play("idle")
	elif is_dead:
		get_tree().change_scene_to_file("res://menus/menu.tscn") 
		pass
	
func _on_weapon_collision_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies.append(body)
		
func _on_weapon_collision_body_exited(body):
	if body.is_in_group("Enemy"):
		enemies.erase(body)
		
func damage(value):
	if is_dead:
		return
		
	is_attacking = false
		
	hp -= value
	
	if hp <= 0:
		is_dead = true
		hitbox.set_deferred("disabled", true)
		right_weapon_coll.set_deferred("disabled", true)
		left_weapon_coll.set_deferred("disabled", true)		
		
		animated_sprite_2d.play("death")
		$run_sound.stop()
		$hit_sound.stop()
		$miss_sound.stop()
		$damage_sound.stop()
		$death_sound.play()
	else:
		velocity = Vector2(0.0, 0.0)
		is_taking_damage = true
		animated_sprite_2d.play("hit")
		$damage_sound.play()
	


func _on_animated_sprite_2d_frame_changed():
	if (is_attacking):
		attack_frame += 1
		
		if (attack_frame == 4):
			var count = 0
			for body in enemies:
				if (body.position.x < position.x) and isLeft:
					count +=1
					body.damage(40)
				elif (body.position.x > position.x) and not isLeft:
					body.damage(40)
					count +=1
				if count > 0:
					$hit_sound.play()
			if count == 0:
				$miss_sound.play()

func _on_run_sound_finished():
	if is_on_floor():
		$run_sound.play()
		run_sound_playing = true
	else:
		run_sound_playing = false
