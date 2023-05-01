extends Node2D

var current_velocity = Vector2.ZERO
var current_rotation_speed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if($Sprite2D.modulate.a > 0.05):
		$Sprite2D.modulate.a -= 0.05 * delta
	else:
		queue_free()

func _physics_process(delta):
	position += current_velocity * delta
	rotation += current_rotation_speed * delta
	
	current_velocity -= current_velocity * delta * 2
	current_rotation_speed -= current_rotation_speed * delta * 2
	
