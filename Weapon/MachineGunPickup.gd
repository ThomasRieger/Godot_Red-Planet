extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pickup_weapon("machine_gun", 100)  # Base ammo is 100
		queue_free()
