extends Node

var next_scene = "res://scenes/oak_woods/oak_woods.tscn"
var bossDeathCount = 0

enum DIFFICULTY { EASY = 0, MEDIUM, HARD, INSANE, HEROIC }
var  difficulty = DIFFICULTY.EASY
var  last_difficulty = DIFFICULTY.EASY
var  difficulty_str = ["Easy", "Medium", "Hard", "Insane", "Heroic"]

var bossDeathCountMatrix = []

var enemy_hp_scaling = 0.5
var enemy_damage_scaling = 0.5
var final_boss_wave_count = 1

func unlock_difficulty_condition(diff, wins):
	return bossDeathCountMatrix[diff][0] >= wins and\
		bossDeathCountMatrix[diff][1] >= wins and\
		diff == last_difficulty + 1

func unlock_difficulty():
	if unlock_difficulty_condition(DIFFICULTY.HEROIC, 5):
		last_difficulty = DIFFICULTY.HEROIC
	elif unlock_difficulty_condition(DIFFICULTY.INSANE, 3):
		last_difficulty = DIFFICULTY.INSANE
	elif unlock_difficulty_condition(DIFFICULTY.HARD, 2):
		last_difficulty = DIFFICULTY.HARD
	elif unlock_difficulty_condition(DIFFICULTY.MEDIUM, 1):
		last_difficulty = DIFFICULTY.MEDIUM	

func change_difficulty(new_value):
	difficulty = new_value
	match new_value:
		DIFFICULTY.EASY:
			enemy_hp_scaling = 0.5
			enemy_damage_scaling = 0.5
			final_boss_wave_count = 1
		DIFFICULTY.MEDIUM:
			enemy_hp_scaling = 1.0
			enemy_damage_scaling = 1.0
			final_boss_wave_count = 2
		DIFFICULTY.HARD:
			enemy_hp_scaling = 1.5
			enemy_damage_scaling = 1.5
			final_boss_wave_count = 2
		DIFFICULTY.INSANE:
			enemy_hp_scaling = 2.0
			enemy_damage_scaling = 2.0
			final_boss_wave_count = 3
		DIFFICULTY.HEROIC:
			enemy_hp_scaling = 2.0
			enemy_damage_scaling = 10.0
			final_boss_wave_count = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	bossDeathCountMatrix.resize(DIFFICULTY.HEROIC + 1)
	bossDeathCountMatrix.fill([])
	for row in bossDeathCountMatrix:
		row.resize(3)
		row.fill(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
