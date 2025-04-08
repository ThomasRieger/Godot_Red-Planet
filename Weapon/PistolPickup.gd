extends Area2D

func _on_body_entered(body):
	print("Body entered: ", body)
	if body.is_in_group("player"):
		print("Player detected, picking up pistol")
		body.pickup_weapon("Pistol", 10)
		queue_free()
