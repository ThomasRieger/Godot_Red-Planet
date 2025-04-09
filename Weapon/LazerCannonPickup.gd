extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pickup_weapon("lazer_cannon", 20)  # Give lazer cannon with 20 ammo
		queue_free()
