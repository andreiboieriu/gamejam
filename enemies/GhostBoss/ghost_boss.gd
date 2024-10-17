extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var hitbox = $CollisionShape2D
@onready var right_collision = $weapon_collision/RightCollisionPolygon2D
@onready var left_collision = $weapon_collision/LeftCollisionPolygon2D

@onready var texture_rect = $"../ParallaxBackground/ParallaxLayer/TextureRect"
const TEX_TRANSITION = 2
var tex_transition = TEX_TRANSITION

var player = null
var hp = 320 * Global.enemy_hp_scaling 
var airborne_location
var ground_location

enum STATES{FLYING, LANDING, MELEE_ATTACK, SPAWNING, IDLE_ON_GROUND, DYING, TAKING_DAMAGE, IDLE_IN_AIR}

var state = STATES.IDLE_ON_GROUND

var IDLE_ON_GROUND_TIME = 2
var idle_on_ground_time = IDLE_ON_GROUND_TIME

var SPAWNING_TIMES = 5
var spawning_times = SPAWNING_TIMES

var SPAWNING_WAVES = Global.final_boss_wave_count
var spawning_waves = SPAWNING_WAVES

var IDLE_IN_AIR_TIME = 3
var idle_in_air_time = IDLE_IN_AIR_TIME

var player_in_weapon_range = false

var ghost = preload("res://enemies/GhostBoss/ghost.tscn")

func _ready():
	#airborne_location = get_parent().get_node("boss_airborne_spot").position
	print(airborne_location)

func _physics_process(delta):
	if player and position.x > player.position.x + 50:
		animated_sprite_2d.flip_h = true
		right_collision.set_deferred("disabled", true)
		left_collision.set_deferred("disabled", false)
		
	elif player and position.x < player.position.x - 50:
		right_collision.set_deferred("disabled", false)
		left_collision.set_deferred("disabled", true)
		
		animated_sprite_2d.flip_h = false
	
	match state:
		STATES.IDLE_ON_GROUND:
			animated_sprite_2d.play("idle2")
			velocity = Vector2(0.0, 0.0)
			
			idle_on_ground_time -= delta
			
			if idle_on_ground_time <= 0.0:
				idle_on_ground_time = IDLE_ON_GROUND_TIME
				airborne_location = player.position + Vector2(0.0, -300.0)
				state = STATES.FLYING
				
		STATES.FLYING:
			hitbox.set_deferred("disabled", true)
			
			if position.distance_to(airborne_location) < 20:
				state = STATES.SPAWNING
				hitbox.set_deferred("disabled", false)				
				velocity = Vector2(0.0, 0.0)
				return
			
			velocity += position.direction_to(airborne_location) * SPEED * delta
			
			move_and_slide()
			
		STATES.SPAWNING:
			if tex_transition >= 0:
				texture_rect.modulate = Color(1, tex_transition / TEX_TRANSITION, tex_transition / TEX_TRANSITION, 1)
				tex_transition -= delta
			animated_sprite_2d.play("summon")
			
		STATES.DYING:
			animated_sprite_2d.play("death")
			
		STATES.TAKING_DAMAGE:
			animated_sprite_2d.play("hit")
			
		STATES.LANDING:
			if tex_transition < TEX_TRANSITION:
				texture_rect.modulate = Color(1, tex_transition / TEX_TRANSITION, tex_transition / TEX_TRANSITION, 1)
				tex_transition += delta

			if position.distance_to(player.position) < 200:
				state = STATES.MELEE_ATTACK
				velocity = Vector2(0.0, 0.0)
				return
			
			velocity += position.direction_to(player.position) * SPEED * delta
			
			move_and_slide()
			
		STATES.MELEE_ATTACK:
			if tex_transition < TEX_TRANSITION:
				texture_rect.modulate = Color(1, tex_transition / TEX_TRANSITION, tex_transition / TEX_TRANSITION, 1)
				tex_transition += delta
			animated_sprite_2d.play("attack")
			
			if position.distance_to(player.position) > 200:
				velocity = position.direction_to(player.position) * SPEED / 3
			else:
				velocity = Vector2(0.0, 0.0)
			
			move_and_slide()
			
		STATES.IDLE_IN_AIR:
			animated_sprite_2d.play("idle2")
		
			idle_in_air_time -= delta
			
			if idle_in_air_time < 0.0:
				idle_in_air_time = IDLE_IN_AIR_TIME
				
				if spawning_waves > 0:
					airborne_location = player.position + Vector2(0.0, -300.0)					
					state = STATES.FLYING
				else:
					state = STATES.LANDING
					spawning_waves = SPAWNING_WAVES
				
		#STATES.
	#move_and_slide()


func damage(value):
	if state != STATES.IDLE_ON_GROUND:
		return
		
	hp -= value
	state = STATES.TAKING_DAMAGE
	if hp <= 0:
		$death.play()
	else:
		$boss_hurt.play()


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "death":
		Global.bossDeathCount += 1
		match PlayerVars.player_character:
			"samurai":
				Global.bossDeathCountMatrix[Global.difficulty][0] += 1
			"archer":
				Global.bossDeathCountMatrix[Global.difficulty][1] += 1
		Global.unlock_difficulty()
		print("Just defeated boss")
		print("samurai wins: ", Global.bossDeathCountMatrix[Global.difficulty][0])
		print("archer wins: ", Global.bossDeathCountMatrix[Global.difficulty][1])
		print("last difficulty: ", Global.difficulty_str[Global.last_difficulty])
		Global.next_scene = "res://scenes/oak_woods/oak_woods.tscn"
		queue_free()
		get_tree().change_scene_to_file("res://menus/menu.tscn")
	elif animated_sprite_2d.animation == "hit":
		if hp <= 0:
			state = STATES.DYING
		else:
			state = STATES.IDLE_ON_GROUND
			$boss_idle.play()
	elif animated_sprite_2d.animation == "summon":
		var ghost_instance = ghost.instantiate()
		ghost_instance.transform = transform
		ghost_instance.set_player(player)
		get_parent().get_node("Ghosts").add_child(ghost_instance)
		
		spawning_times -= 1
		
		if spawning_times <= 0:
			spawning_times = SPAWNING_TIMES
			spawning_waves -= 1
			state = STATES.IDLE_IN_AIR
			$summoning.stop()
		else:
			animated_sprite_2d.play("summon")
			if spawning_times == SPAWNING_TIMES - 1:
				$summoning.play()
			
	elif animated_sprite_2d.animation == "attack":
		state = STATES.IDLE_ON_GROUND

func _on_spell_collision_body_entered(body):
	if body.is_in_group("Player"):
		player = body


func _on_weapon_collision_body_entered(body):
	if body.is_in_group("Player"):
		player_in_weapon_range = true

func _on_weapon_collision_body_exited(body):
	if body.is_in_group("Player"):
		player_in_weapon_range = false


func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "attack" and\
	   (animated_sprite_2d.get_frame() == 2 or animated_sprite_2d.get_frame() == 9):
		if player_in_weapon_range:
			player.damage(50 * Global.enemy_damage_scaling)
			$hit.play()
		else:
			$miss.play()

