extends Area2D

var damage = 40
var lifetime = 0.2

func _ready():
	print("Explosion at: ", global_position)
	for body in get_overlapping_bodies():
		print("Explosion overlapping with: ", body.name)
		if body.is_in_group("enemy"):
			print("Explosion hit enemy, dealing ", damage, " damage")
			body.take_damage(damage)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	print("Explosion collided with: ", body.name)
	if body.is_in_group("enemy"):
		print("Explosion hit enemy, dealing ", damage, " damage")
		body.take_damage(damage)
