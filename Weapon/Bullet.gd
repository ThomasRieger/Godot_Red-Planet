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

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		area.take_damage(damage)
		queue_free()  # Disappear after hitting an enemy
