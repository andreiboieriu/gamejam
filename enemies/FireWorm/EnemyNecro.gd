extends CharacterBody2D


const SPEED = 125.0
const JUMP_VELOCITY = -400.0

const ATTACK_COOLDOWN = 3.0
var attack_cooldown = ATTACK_COOLDOWN

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite_2d = $AnimatedSprite2D
@onready var marker_2d = $Marker2D
@onready var animated_sprite_2d = $AnimatedSprite2D

# Player
@onready var player = $"../CharacterBody2D"

var player_in_sight = false
var player_too_close = false

@export var orb : PackedScene

func _physics_process(delta):
	attack_cooldown -= delta

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if player_in_sight:
		var target_position = player.position
		target_position.y = position.y

		if player_too_close:
			position = position.move_toward(target_position, -delta * SPEED)
		else:
			position = position.move_toward(target_position, delta * SPEED)
		if attack_cooldown <= 0:
			sprite_2d.play("attack_1")

	move_and_slide()

	sprite_2d.flip_h = velocity.x < 0


func _on_animated_sprite_2d_animation_finished():
	attack_cooldown = ATTACK_COOLDOWN

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.get_animation() == &"attack_1" and animated_sprite_2d.get_frame() == 8:
		var orb_instance = orb.instantiate()
		orb_instance.set_player(player)
		orb_instance.transform = marker_2d.global_transform
		get_parent().get_node("Projectiles").add_child(orb_instance)

func sight_condition(body):
	if body.is_in_group("Player"):
		return true
	return false

func _on_sight_body_entered(body):
	if sight_condition(body):
		player_in_sight = true

func _on_sight_body_exited(body):
	if sight_condition(body):
		player_in_sight = false

func _on_inner_sight_body_entered(body):
	if sight_condition(body):
		player_too_close = true

func _on_inner_sight_body_exited(body):
	if sight_condition(body):
		player_too_close = false
		player_in_sight = true
