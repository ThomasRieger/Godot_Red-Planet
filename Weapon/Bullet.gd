extends Area2D

var speed = 400
var direction = Vector2.ZERO
var damage = 10
var lifetime = 5.0
@onready var sprite = $Sprite2D

func _ready():
	if direction != Vector2.ZERO:
		sprite.rotation = direction.angle()
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	print("Bullet collided with: ", body.name)
	if body.is_in_group("enemy"):
		print("Bullet hit enemy, dealing ", damage, " damage")
		body.take_damage(damage)
	queue_free()
