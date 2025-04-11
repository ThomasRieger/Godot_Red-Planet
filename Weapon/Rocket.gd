extends Area2D

var speed = 300
var direction = Vector2.ZERO
var damage = 40
@onready var sprite = $Sprite2D
var explosion_scene = preload("res://Weapon/Explosion.tscn")

func _ready():
	if direction != Vector2.ZERO:
		rotation = direction.angle() + deg_to_rad(90)  # Add 90 degrees to the rotation

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	print("Rocket collided with: ", body.name)
	if body.is_in_group("enemy"):
		print("Rocket hit enemy, dealing ", damage, " damage")
		body.take_damage(damage)
	var explosion = explosion_scene.instantiate()
	explosion.position = global_position
	explosion.damage = damage
	get_parent().add_child(explosion)
	queue_free()
