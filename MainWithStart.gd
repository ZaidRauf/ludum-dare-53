extends Node2D


var game_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Main/CanvasHUDLayer.visible = false
	$Main/Chaser_Left.chaser_active = false
	$Main/Chaser_Right.chaser_active = false
	$Main/Ship.player_alive = false
	$Main.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(!game_started):
		if Input.is_action_just_pressed("shoot"):
			game_started = true
			$CanvasLayer.visible = false
			$CanvasLayer/StartMenu.visible = false
			
			$Main/CanvasHUDLayer.visible = true
			$Main/Chaser_Left.chaser_active = true
			$Main/Chaser_Right.chaser_active = true
			$Main/Ship.player_alive = true
			$Main.visible = true

