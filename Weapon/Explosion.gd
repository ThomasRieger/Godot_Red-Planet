extends Area2D

var damage = 40
var lifetime = 0.5  # Extended to match particle lifetime
var damaged_bodies = []
@onready var visual_effect = $VisualEffect  # Added

func _ready():
	print("Explosion at: ", global_position)
	visual_effect.emitting = true  # Start particles
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
