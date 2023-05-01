extends Node2D

var milk_delivered_count = 0
var player_hit_count = 0

@export var max_hit_count = 10

func init_survivor_patrol(survivor_patrol):
	survivor_patrol.get_node("Survivor").add_move_target(survivor_patrol.get_node("MoveGoal1").position)
	survivor_patrol.get_node("Survivor").add_move_target(survivor_patrol.get_node("MoveGoal2").position)
	survivor_patrol.get_node("Survivor").milk_received.connect(func(): milk_delivered_count += 1; $CanvasHUDLayer/HUD.update_delivery_text(milk_delivered_count))
func _ready():
	$Camera2D.zoom = Vector2(1.400001, 1.400001)
	randomize()
	
	for child in $SurvivorPatrols.get_children():
		init_survivor_patrol(child)
	$Chaser_Left.set_chase_target($Ship)
	$Chaser_Right.set_chase_target($Ship)

func _process(_delta):

	if(Input.is_action_just_released("zoom_out") and $Camera2D.zoom.length() > 2) and $Ship.player_alive:
		$Camera2D.zoom -= Vector2(0.1, 0.1);
	if(Input.is_action_just_released("zoom_in") and $Camera2D.zoom.length() < 7) and $Ship.player_alive:
		$Camera2D.zoom += Vector2(0.1, 0.1);
		
	if !$Ship.player_alive and Input.is_action_just_pressed("shoot"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func _physics_process(_delta):
	# Camera tracks ship
	$Camera2D.position = round($Ship.position)

func chaser_hit():
	player_hit_count += 1
	
	$HitPlayer.play()
	
	if(max_hit_count - player_hit_count >= 0):
		$CanvasHUDLayer/HUD.update_health_text(max_hit_count - player_hit_count, max_hit_count)
	
	if player_hit_count >= max_hit_count:
		$Ship.kill()
		$CanvasHUDLayer/HUD.hide_alive_hud()
		$CanvasHUDLayer/HUD.show_death_hud(milk_delivered_count)

func _on_chaser_right_character_hit():
	chaser_hit()

func _on_chaser_left_character_hit():
	chaser_hit()

func _on_wrench_pickup_picked_up():
	player_hit_count = 0
	$CanvasHUDLayer/HUD.update_health_text(max_hit_count - player_hit_count, max_hit_count)
	
	var wrench_locations = []
	
	for child in $WrenchSpawnLocations.get_children():
		wrench_locations.append(child.position)
		
	$WrenchPickup.position = wrench_locations.pick_random()
