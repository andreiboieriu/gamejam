extends CharacterBody2D

var speed = 250
var player = null

var follow_time = 1.2
var follow_direction

var initial_velocity = Vector2(0, -500)
var initial_mult = 0.5

var is_exploding = false
var is_flying = true

@onready var animated_sprite_2d = $Area2D/AnimatedSprite2D

func set_player(player_arg):
	player = player_arg

func _physics_process(delta):
	if not is_flying:
		return
	
	if follow_time > 0:
		follow_direction = (player.position - position).normalized()
		follow_time -= delta
	position += follow_direction * speed * delta + initial_mult * initial_velocity * delta
	if initial_mult > 0:
		initial_mult -= delta

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.play("flying")

func _on_animated_sprite_2d_animation_finished():
	if is_exploding:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy"):
		return

	if not is_flying:
		return
		
	animated_sprite_2d.play("exploding")
	is_exploding = true
	$fire_explosion.play()
	
	is_flying = false
	
	if body.is_in_group("Player"):
		body.damage(40 * Global.enemy_damage_scaling)
