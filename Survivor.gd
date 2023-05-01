extends CharacterBody2D

var move_target = position
var speed = 1000
var move_target_list = []

enum {WANT_MILK, WALKING, IDLE}

var current_state = WANT_MILK

var move_timeout_length = 2
var want_milk_timeout_length = 60

signal milk_received

func _ready():
	move_target = position
	scale = Vector2(0.75, 0.75)
	$AnimatedSprite2D.play("want_milk")
	current_state = WANT_MILK
	
func add_move_target(target):
	move_target_list.append(target)
	# move_target = target

func move(delta):
	velocity = Vector2.ZERO
	
	if(position.distance_to(move_target) > 50):
		$AnimatedSprite2D.play("walking")
		velocity = position.direction_to(move_target) * speed * delta
		move_and_slide()
	else:
		move_target = position
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if(current_state == WALKING):
		move(delta)

func _process(delta):
	if current_state == IDLE and $MoveTimeout.is_stopped():
		$MoveTimeout.start(move_timeout_length)
		move_target = move_target_list.pick_random()
		
func _on_save_radius_area_entered(area):
	var area_str = area.get_parent().get_name()

	if current_state == WANT_MILK and "MilkProjectile" in area_str:
		current_state = IDLE
		$AnimatedSprite2D.play("idle")
		emit_signal("milk_received")

func _on_move_timeout_timeout():
	current_state = WALKING
	$AnimatedSprite2D.play("walking")
	$WantMilkTimeout.start(want_milk_timeout_length)

func _on_want_milk_timeout_timeout():
	move_target = position
	current_state = WANT_MILK
	$AnimatedSprite2D.play("want_milk")
