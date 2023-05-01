extends CharacterBody2D

@export var forward_speed = 300
@export var backward_speed = 150

@export var left_turn_speed = -3 # Must always be negative
@export var right_turn_speed = 3 # Must always be positive

@export var max_speed = 350
@export var max_reverse_speed = 100
@export var deceleration_percent = -0.01 # Must always be negative

@export var collision_damage_multiplier = 1.5

@export var milk_throw_cooldown_length = 0.6

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

var number_of_hits = 0;

var milk_projectile_generator = preload("res://MilkProjectile.tscn")

var milk_throw_cooldown = false

var player_alive = true

signal player_dead

func move(delta):
	if forward_speed_percent >= 0.01:
		forward_speed_percent -= 0.01;
	
	if backward_speed_percent >= 0.01:
		backward_speed_percent -= 0.01;
	
#	if Input.is_action_just_pressed("boost"):
#		forward_speed_percent += 20
		
	if Input.is_action_pressed("forward") and current_velocity.length() < max_speed:
		if(backward_speed_percent >= 0.1):
			backward_speed_percent -= 0.1
		if forward_speed_percent < 1.0:
			forward_speed_percent += 0.05
		current_velocity += Vector2.UP.rotated(rotation) * delta * forward_speed * forward_speed_percent
	
	if Input.is_action_pressed("left") and wheel_rotation > -MAX_WHEEL_ROTATION:
		wheel_rotation += left_turn_speed * delta
	
	if Input.is_action_pressed("right") and wheel_rotation < MAX_WHEEL_ROTATION:
		wheel_rotation += right_turn_speed * delta
		
	if Input.is_action_pressed("backward") and current_velocity.length() < max_speed:
		if(forward_speed_percent >= 0.1):
			forward_speed_percent -= 0.1
		if backward_speed_percent < 1.0:
			backward_speed_percent += 0.05
		current_velocity += -Vector2.UP.rotated(rotation) * delta * backward_speed * backward_speed_percent
		
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
		if(collision.get_collider() is CharacterBody2D):
			current_car_health -= collision_damage_multiplier * collision.get_remainder().length()
		current_velocity *= 0.01

func _ready():
	pass
	
func _physics_process(delta):
	if !player_alive: return
	move(delta)

func throw_milk():
	$MilkThrowPlayer.play()
	var milk_projectile = milk_projectile_generator.instantiate()
	milk_projectile.position = position
	milk_projectile.scale = Vector2(0.7, 0.7)
	milk_projectile.current_velocity += current_velocity
	
	var throw_direction = Vector2.UP.rotated(rotation).rotated(-PI/2) # TODO: See if this needs to be pi/2
	milk_projectile.current_velocity += throw_direction * 100
	
	milk_projectile.current_rotation_speed = PI/3 + randfn(0, 2)
	
	self.add_sibling(milk_projectile)
	get_parent().move_child(milk_projectile, self.get_index())
	
func _process(delta):
	if !player_alive: return
	var wheel_view_rotaiton = wheel_rotation / MAX_WHEEL_ROTATION * PI/4
	$FrontRightWheel.rotation = wheel_view_rotaiton
	$FrontLeftWheel.rotation = wheel_view_rotaiton
	
	if Input.is_action_just_pressed("shoot"):
		if not milk_throw_cooldown:
			throw_milk()
			milk_throw_cooldown = true
			$MilkThrowTimer.start(milk_throw_cooldown_length)


func _on_milk_throw_timeout_timeout():
	milk_throw_cooldown = false

func kill():
	player_alive = false
	emit_signal("player_dead")
