extends Area2D

var damage = 20
var lifetime = 0.5
@onready var sprite = $Sprite2D
var damaged_bodies = []

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	for area in get_overlapping_areas():
		if area.is_in_group("enemy") and not area in damaged_bodies:
			area.take_damage(damage)
			damaged_bodies.append(area)
