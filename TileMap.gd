extends TileMap

var moisture = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
var temperature = FastNoiseLite.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	moisture.seed = randi()
	altitude.seed = randi()
	temperature.seed = randi()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
