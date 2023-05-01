extends CharacterBody2D

@export var forward_speed = 300
@export var backward_speed = 150

@export var left_turn_speed = -3 # Must always be negative
@export var right_turn_speed = 3 # Must always be positive

@export var max_speed = 275
@export var max_reverse_speed = 100
@export var deceleration_percent = -0.01 # Must always be negative

@export var collision_damage_multiplier = 1.5

@export var chaser_type_lefty = true

@export var chaser_active = true

var forward_speed_percent = 0.0;
var backward_speed_percent = 0.0;
var current_velocity = Vector2.ZERO
var wheel_rotation = 0.0
const MAX_WHEEL_ROTATION = PI/2.5

var max_storage_capcity = 100
var max_fuel_capacity = 100
var max_car_health = 100

var current_storage = 0
var current_fuel = 100
var current_car_health = 100

var recently_collided = false;
var recently_collided_reverse_count = 0;

var chase_target = (PackedScene)

var pause_collision_signal = false

signal character_hit

func move(delta):
	if(recently_collided) and recently_collided_reverse_count < 150:
		if(forward_speed_percent >= 0.1):
			forward_speed_percent -= 0.1
		if backward_speed_percent < 1.0:
					backward_speed_percent += 0.05
		current_velocity += -Vector2.UP.rotated(rotation) * delta * backward_speed * backward_speed_percent
		
		recently_collided_reverse_count += 1;
	else:
		pause_collision_signal = false
		recently_collided = false;
		recently_collided_reverse_count = 0
	
		var direction_to_target = position.direction_to(chase_target.position)
		var target_alignment = direction_to_target.dot(Vector2.UP.rotated(rotation))

		if forward_speed_percent >= 0.01:
			forward_speed_percent -= 0.01;

		if backward_speed_percent >= 0.01:
			backward_speed_percent -= 0.01;
			
		if current_velocity.length() < max_speed:
			if(backward_speed_percent >= 0.1):
				backward_speed_percent -= 0.1
			if forward_speed_percent < 1.0:
				forward_speed_percent += 0.04
			current_velocity += Vector2.UP.rotated(rotation) * delta * forward_speed * forward_speed_percent
			350
		if(chaser_type_lefty):
			if target_alignment < 0.8 and wheel_rotation > -MAX_WHEEL_ROTATION:
				wheel_rotation += left_turn_speed * delta
			elif target_alignment > 0.8 and wheel_rotation < MAX_WHEEL_ROTATION:
				wheel_rotation += right_turn_speed * delta
		else:
			if target_alignment < 0.8 and wheel_rotation < MAX_WHEEL_ROTATION:
				wheel_rotation += right_turn_speed * delta
			elif target_alignment > 0.8 and wheel_rotation > -MAX_WHEEL_ROTATION:
				wheel_rotation += left_turn_speed * delta
	# Model Deceleration
	if(current_velocity.length() > 0):
		current_velocity += current_velocity * deceleration_percent
	
	var rotated_forward_vec = Vector2.UP.rotated(rotation)
	current_velocity = current_velocity * 0.45 + rotated_forward_vec * current_velocity.dot(rotated_forward_vec) * 0.55
	
	wheel_rotation += -sign(wheel_rotation) * 1 * delta
	
	if(current_velocity.normalized().dot(Vector2.UP.rotated(rotation)) > 0.8):
		rotation += wheel_rotation * delta * current_velocity.length() * 0.01
	
	if(current_velocity.normalized().dot(-Vector2.UP.rotated(rotation)) > 0.8):
		rotation -= wheel_rotation * delta * current_velocity.length() * 0.01
	
	velocity = current_velocity
	
	var collision = move_and_collide(velocity * delta)
	
	if(collision):
		var hit_object = collision.get_collider().name
		
		if !pause_collision_signal and "Ship" in hit_object:
			pause_collision_signal = true
			emit_signal("character_hit")
		
		current_velocity *= 0.01
		
		if not recently_collided:
			recently_collided = true
			recently_collided_reverse_count = 0
		else:
			recently_collided = false
			recently_collided_reverse_count = 0

func _ready():
	pass
	
func set_chase_target(scene):
	chase_target = scene

func _physics_process(delta):
	if !chaser_active: return
	move(delta)
	
func _process(delta):
	var wheel_view_rotaiton = wheel_rotation / MAX_WHEEL_ROTATION * PI/4
	$FrontRightWheel.rotation = wheel_view_rotaiton
	$FrontLeftWheel.rotation = wheel_view_rotaiton
