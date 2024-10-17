extends Control

@onready var difficulty_button = $Panel/VBoxContainer/Resolution/OptionButton

@export var settings = {
	"fullscreen": false,
	"vsync": false
}

var res = null
var toggle = false

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudio.play_menu_music()
	for i in range(0, Global.last_difficulty + 1):
		difficulty_button.add_item(Global.difficulty_str[i], i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_back_pressed():
	$click.play()		
	res = "res://menus/menu.tscn"

func _on_option_button_item_selected(index):
	Global.change_difficulty(index)
	print(Global.difficulty_str[Global.difficulty])
	$click.play()
	res = "difficulty"

func _on_fullscreen_toggled(toggled_on):
	toggle= toggled_on
	$click.play()
	res = "fullscreen"

func _on_vsync_toggled(toggled_on):
	$click.play()
	toggle =  toggled_on
	res = "vsync"

func _on_click_finished():
	if res.contains("vsync"):
		settings["vsync"] = toggle
		if toggle:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if res.contains("fullscreen"):
		settings["fullscreen"] = toggle
		if toggle:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	
	if res.contains("menu"):
		get_tree().change_scene_to_file(res)
