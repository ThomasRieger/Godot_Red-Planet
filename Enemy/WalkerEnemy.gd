extends Area2D

var speed = 50
var health = 50
var damage_per_second = 10
var player = null
@onready var damage_timer = $DamageTimer

func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	print("WalkerEnemy initialized at position: ", global_position, " in group 'enemy'")

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * speed * delta
		rotation = direction.angle() + deg_to_rad(90)

func _on_body_entered(body):
	print("WalkerEnemy collided with body: ", body.name)
	if body.is_in_group("player"):
		damage_timer.start()

func _on_body_exited(body):
	if body.is_in_group("player"):
		damage_timer.stop()

func _on_damage_timer_timeout():
	if player and is_instance_valid(player):
		player.take_damage(damage_per_second)

func take_damage(damage: int):
	health -= damage
	print("WalkerEnemy took ", damage, " damage. Remaining health: ", health)
	if health <= 0:
		print("WalkerEnemy destroyed!")
		queue_free()
