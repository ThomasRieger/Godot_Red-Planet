extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pickup_weapon("lazer_cannon", 10)  # Give lazer cannon with 20 ammo
		queue_free()
