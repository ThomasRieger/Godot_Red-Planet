extends Area2D

var damage = 40
var lifetime = 0.2
var damaged_bodies = []

func _ready():
	print("Explosion at: ", global_position)
	for area in get_overlapping_areas():
		if area.is_in_group("enemy") and not area in damaged_bodies:
			area.take_damage(damage)
			damaged_bodies.append(area)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy") and not area in damaged_bodies:
		area.take_damage(damage)
		damaged_bodies.append(area)
