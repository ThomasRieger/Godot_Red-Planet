extends Area2D

var damage = 20
var lifetime = 0.5
@onready var sprite = $Sprite2D

func _ready():
	for body in get_overlapping_bodies():
		print("Lazer overlapping with: ", body.name)
		if body.is_in_group("enemy"):
			print("Lazer hit enemy, dealing ", damage, " damage")
			body.take_damage(damage)
	await get_tree().create_timer(lifetime).timeout
	queue_free()
