extends Area2D

var speed = 800
var direction = 1
var time_to_live = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered_arrow)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += transform.x * speed * delta * direction
	
	time_to_live -= delta
	if time_to_live <= 0:
		queue_free()

func _on_body_entered_arrow(body):
	if body.is_in_group("Player"):
		return
		
	if body.is_in_group("Enemy"):
		body.damage(25)
		
	queue_free()
