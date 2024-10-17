extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var rng = RandomNumberGenerator.new()

var initial_velocity = Vector2(0, -500)
var initial_mult = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox = $Area2D/CollisionShape2D

var player = null

var LIFETIME = 3
var lifetime = LIFETIME

	
enum STATES{SPAWNING, FLYING, DYING}
var state = STATES.SPAWNING

func set_player(player_ref):
	player = player_ref
	
func _ready():
	initial_velocity = Vector2(rng.randf_range(-1500, 1500), rng.randf_range(-200, -700))

func _physics_process(delta):
	match state:
		STATES.SPAWNING:
			animated_sprite_2d.play("spawn")
		STATES.FLYING:
			animated_sprite_2d.play("idle")
			
			lifetime -= delta
			
			if lifetime <= 0.0:
				state = STATES.DYING
				return
			
			var follow_direction = (player.position - position).normalized()
			position += follow_direction * SPEED * delta + initial_mult * initial_velocity * delta
			#velocity += position.direction_to(player.position) * SPEED * delta
			
			initial_mult -= delta
			
			if initial_mult < 0.0:
				initial_mult = 0.0
			
			#move_and_slide()
			
		STATES.DYING:
			hitbox.set_deferred("disabled", true)
			animated_sprite_2d.play("death")

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "spawn":
		state = STATES.FLYING
		print("ghost finished spawning")
	elif animated_sprite_2d.animation == "death":
		queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy"):
		return
		
	if body.is_in_group("Player"):
		body.damage(20)
		
	state = STATES.DYING
	
		
