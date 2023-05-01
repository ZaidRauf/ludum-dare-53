extends Node2D

var hover_val = 0
signal picked_up

func _ready():
	pass # Replace with function body.

func _process(delta):
	$Sprite2D.position.y = sin(hover_val * 3) * 7
	hover_val += delta
	pass

func _on_area_2d_body_entered(body):
	var area_str = body.get_name()
	
	if "Ship" in area_str:
		$AudioStreamPlayer.play()
		emit_signal("picked_up")
