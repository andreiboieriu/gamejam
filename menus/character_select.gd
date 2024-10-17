extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudio.play_menu_music()

@onready var archer = $HBoxContainer/Archer/MarginContainer/AnimatedSprite2D
@onready var samurai = $HBoxContainer/Samurai/MarginContainer/AnimatedSprite2D
@onready var unknown_char = $HBoxContainer/UnknownChar/MarginContainer/AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match Global.bossDeathCount:
		0:
			archer.modulate = Color(0, 0, 0)
			unknown_char.modulate = Color(0, 0, 0)
		1:
			archer.modulate = Color(1, 1, 1)
			unknown_char.modulate = Color(0, 0, 0)
		2:
			unknown_char.modulate = Color(1, 1, 1)

var res = null

func _on_archer_pressed():
	if Global.bossDeathCount == 0:
		return

	var player_vars = get_node("/root/PlayerVars")
	player_vars.player_character = "archer"
	res = "res://scenes/stringstar_fields/stringstar_fields.tscn"
	$click.play()

func _on_archer_mouse_entered():
	archer.apply_scale(Vector2(1.3333, 1.3333))
	archer.play("idle")

func _on_archer_mouse_exited():
	archer.apply_scale(Vector2(0.75, 0.75))
	archer.stop()

func _on_samurai_pressed():
	var player_vars = get_node("/root/PlayerVars")
	player_vars.player_character = "samurai"
	res = "res://scenes/stringstar_fields/stringstar_fields.tscn"
	$click.play()

func _on_samurai_mouse_entered():
	samurai.apply_scale(Vector2(1.3333, 1.3333))
	samurai.play("idle")

func _on_samurai_mouse_exited():
	samurai.apply_scale(Vector2(0.75, 0.75))
	samurai.stop()

func _on_click_finished():
	get_tree().change_scene_to_file(res)

func _on_back_pressed():
	$click.play()		
	res = "res://menus/menu.tscn"


func _on_unknown_char_mouse_entered():
	unknown_char.apply_scale(Vector2(1.3333, 1.3333))
	unknown_char.play("idle")


func _on_unknown_char_mouse_exited():
	unknown_char.apply_scale(Vector2(0.75, 0.75))
	unknown_char.stop()
