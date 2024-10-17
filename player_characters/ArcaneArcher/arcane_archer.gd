extends CharacterBody2D

@export var arrow : PackedScene

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var isLeft = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite_2d = $Sprite2D
@onready var arrow_origin_right = $ArrowOriginRight
@onready var arrow_origin_left = $ArrowOriginLeft
@onready var hitbox = $CollisionShape2D

var can_shoot = true
var is_shooting = false
var shooting_cooldown = 0.35

var is_dead = false
var taking_damage = false
var hp = 100

var run_sound_playing = false
var jump_sound_played = false

func _physics_process(delta):
	if is_dead:
		return
		
	if position.y > 2500:
		hitbox.set_deferred("disabled", true)
		#animated_sprite_2d.play("death")
		$run_sound.stop()
		$bow_sound.stop()
		$damage_sound.stop()
		$death_sound.play()
		
		sprite_2d.stop()
		is_dead = true
		get_tree().change_scene_to_file("res://menus/menu.tscn") 
		return
		
	if taking_damage or is_shooting:
		return
	
	if Input.is_action_pressed("right_click") and is_on_floor() and can_shoot:
		sprite_2d.animation = "shooting"
		velocity = Vector2(0.0, 0.0)
		is_shooting = true
		can_shoot = false
		$bow_sound.play()
		return
		
	if not can_shoot:
		shooting_cooldown -= delta
		
		if (shooting_cooldown <= 0.0):
			shooting_cooldown = 1.0
			can_shoot = true
		
	
	
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
		if not run_sound_playing and is_on_floor():
			$run_sound.play()
			run_sound_playing = true
	else:
		sprite_2d.animation = "default"
		$run_sound.stop()
		run_sound_playing = false
		
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		sprite_2d.animation = "jumping"
		$run_sound.stop()
		run_sound_playing = false

	 #Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
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
	
	sprite_2d.flip_h = isLeft
	
func damage(value):
	if is_dead:
		return
		
		
	is_shooting = false
		
	hp -= value
	
	if hp <= 0:
		is_dead = true
		is_shooting = false
		taking_damage = false
		hitbox.set_deferred("disabled", true)
		
		sprite_2d.play("death")
		$run_sound.stop()
		$damage_sound.stop()
		$death_sound.play()
		
	else:
		velocity = Vector2(0.0, 0.0)			
		taking_damage = true
		sprite_2d.play("hit")
		$damage_sound.play()

func _on_sprite_2d_animation_finished():
	if is_shooting:
		is_shooting = false
		
		$arrow_release_sound.play()
		
		var arr = arrow.instantiate()
		if isLeft:
			arr.transform = arrow_origin_left.get_global_transform()
			arr.direction = -1
		else:
			arr.transform = arrow_origin_right.get_global_transform()
			arr.direction = 1

		get_parent().get_node("Projectiles").add_child(arr)
		
		sprite_2d.play("default")
	elif taking_damage:
		sprite_2d.play("default")
		taking_damage = false
	elif is_dead:
		get_tree().change_scene_to_file("res://menus/menu.tscn") 
		pass

func _on_run_sound_finished():
	if is_on_floor():
		$run_sound.play()
		run_sound_playing = true
	else:
		run_sound_playing = false
