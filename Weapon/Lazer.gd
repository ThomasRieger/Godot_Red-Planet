extends Area2D

var damage = 20
var lifetime = 0.5
@onready var sprite = $Sprite2D
var player
var damaged_bodies = []

func _ready():
	player = get_parent().get_child(0)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(_delta):
	#print(player)
	#position = player.position
	self.position = player.position
	for area in get_overlapping_areas():
		if area.is_in_group("enemy") and not area in damaged_bodies:
			area.take_damage(damage)
			damaged_bodies.append(area)
