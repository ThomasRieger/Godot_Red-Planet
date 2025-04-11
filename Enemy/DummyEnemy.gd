extends Area2D

var health = 100

func _ready():
	add_to_group("enemy")  # Ensure the enemy is in the "enemy" group
	print("DummyEnemy added to group 'enemy' at position: ", global_position)

func take_damage(damage: int):
	health -= damage
	print("DummyEnemy took ", damage, " damage. Remaining health: ", health)
	if health <= 0:
		print("DummyEnemy destroyed!")
		queue_free()
