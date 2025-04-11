extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pickup_weapon("shotgun", 50)  # Give shotgun with 50 ammo
		queue_free()
