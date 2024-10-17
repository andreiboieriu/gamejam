extends Control

var res = null

func _ready():
	$VBoxContainer/Play.grab_focus()
	GlobalAudio.play_menu_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_play_pressed():
	$click.play()
	res = "res://menus/character_select.tscn"

func _on_quit_pressed():
	$click.play()
	res = "quit"

func _on_options_pressed():
	$click.play()
	res = "res://menus/Options.tscn"

func _on_click_finished():
	if res.contains("quit"):
		get_tree().quit()
	else:
		get_tree().change_scene_to_file(res)
