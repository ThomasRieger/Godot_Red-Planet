extends Area2D

var health = 9999

func _ready():
	add_to_group("enemy")
	print("DummyEnemy initialized at position: ", global_position, " in group 'enemy'")

func take_damage(damage: int):
	health -= damage
	print("DummyEnemy took ", damage, " damage. Remaining health: ", health)
	if health <= 0:
		print("DummyEnemy destroyed!")
		queue_free()

func _on_area_entered(area):
	print("DummyEnemy collided with area: ", area.name)
