extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pickup_weapon("rocket_cannon", 25)  # Give rocket cannon with 25 ammo
		queue_free()
