extends Area2D

var damage = 20  # Damage per hit
var lifetime = 0.5  # Appears for 0.5w seconds
@onready var sprite = $Sprite2D

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()
