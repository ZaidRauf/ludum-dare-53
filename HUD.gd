extends Control

func _ready():
	$DeathHUD.visible = false

func update_health_text(current_health, max_health):
	$HealthLabel.text = "Health: " + str(current_health) + " / " + str(max_health)

func update_delivery_text(delivery_count):
	$DeliveryLabel.text = "Deliveries: " + str(delivery_count)

func hide_alive_hud():
	$HealthLabel.visible = false
	$DeliveryLabel.visible = false
	$WrenchUISprite.visible = false
	$MilkUISprite.visible = false
	$QuitLabel.visible = false

func show_death_hud(final_score):
	$DeathHUD/FinalScoreLabel.text = "Final Score: " + str(final_score)
	$DeathHUD.visible = true
