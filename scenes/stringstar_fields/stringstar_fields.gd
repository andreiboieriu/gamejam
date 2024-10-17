extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudio.stop()
	
	var player_vars = get_node("/root/PlayerVars")
	
	if player_vars.player_character == "archer":
		var player = preload("res://player_characters/ArcaneArcher/arcane_archer.tscn").instantiate()
		player.position = Vector2(20.0, 670.0)
		add_child(player)
	elif player_vars.player_character == "samurai":
		var player = preload("res://player_characters/Samurai/samurai.tscn").instantiate()
		player.position = Vector2(20.0, 670.0)
		add_child(player)

	$bg_music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_bg_music_finished():
	$bg_music.play()
