extends Area2D

var speed = 75
var health = 10
var damage_per_second = 5
var player = null
@onready var damage_timer = $DamageTimer
@onready var alien = $AnimatedSprite2D
@onready var death_effect = $DeathEffect  # Added

func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	var despawn_timer = Timer.new()
	despawn_timer.wait_time = 60 # 1 minutes
	despawn_timer.one_shot = true
	despawn_timer.connect("timeout", _on_despawn_timeout)
	add_child(despawn_timer)
	despawn_timer.start()


func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * speed * delta
		if player.position.x < position.x:
			alien.flip_h = true
		else:
			alien.flip_h = false
		# rotation = direction.angle() + deg_to_rad(90)
		alien.play("walk")

func _on_body_entered(body):
	# print("WalkerEnemy collided with body: ", body.name)
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
	# print("WalkerEnemy took ", damage, " damage. Remaining health: ", health)
	if health <= 0:
		AudioController.play_explode()
		print("WalkerEnemy destroyed!")
		death_effect.emitting = true  # Trigger particles
		alien.hide()  # Hide sprite
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		await get_tree().create_timer(death_effect.lifetime).timeout
		queue_free()

func _on_despawn_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
