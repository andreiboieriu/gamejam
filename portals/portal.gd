extends Node2D

@onready var animated_sprite_2d = $CharacterBody2D/AnimatedSprite2D

var player = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		body.visible = false
		body.is_dead = true
		animated_sprite_2d.play("dissapear")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "dissapear":
		#var player = get_tree().get_current_scene().get
		#var scene = ResourceLoader.load("res://scenes/oak_woods/oak_woods.tscn")
		#current_scene = scene.instantiate()
		var next_scene = Global.next_scene
		
		if next_scene == "res://scenes/oak_woods/oak_woods.tscn":
			Global.next_scene = "res://scenes/dark_castle/castle_map.tscn"
		elif next_scene == "res://scenes/dark_castle/castle_map.tscn":
			Global.next_scene = "res://scenes/boss_arena/boss_arena.tscn"
		
		
		get_tree().change_scene_to_file(next_scene)
