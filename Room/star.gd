extends Node2D

var rng = RandomNumberGenerator.new()
var speed = 100
var speed_speed = 10
var rotation_speed = 2

func _ready() -> void:
	speed = rng.randf_range(0.2, 0.8)
	rotation_speed = rng.randf_range(-0.2, 0.2)
	
func _physics_process(delta: float) -> void:
	self.rotation_degrees += rotation_speed * speed_speed
	self.position.x -= speed * speed_speed
	
