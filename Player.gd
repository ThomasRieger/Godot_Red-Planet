extends CharacterBody2D

@export var speed = 100
@onready var cannon = $Head
@onready var body = $Wheel
var health = 100
var weapons = [
	{"name": "cannon", "ammo": -1},
	{"name": "Empty", "ammo": 0},
	{"name": "Empty", "ammo": 0},
	{"name": "Empty", "ammo": 0},
	{"name": "Empty", "ammo": 0}
]
var current_weapon = 0
var bullet_scene = preload("res://Weapon/Bullet.tscn")
var can_shoot = true
var shoot_cooldown = 1.0

signal weapon_changed(slot, weapon_name, ammo)
signal health_changed(new_health)

func _ready():
	add_to_group("player")
	emit_signal("health_changed", health)
	emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
	body.play("wheels")

func _physics_process(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("a", "d")
	direction.y = Input.get_axis("w", "s")
	velocity = direction.normalized() * speed
	move_and_slide()

	# Rotate the cannon toward the mouse
	var mouse_pos = get_global_mouse_position()
	var cannon_direction = (mouse_pos - global_position).normalized()
	cannon.rotation = cannon_direction.angle()

	# Rotate the tank body to face the movement direction
	if direction != Vector2.ZERO:
		var target_angle = direction.angle()
		body.rotation = lerp_angle(body.rotation, target_angle, 10 * delta)
		body.flip_h = direction.x < 0
		if not body.is_playing():
			body.play("wheels")
	else:
		if body.is_playing():
			body.stop()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			current_weapon = (current_weapon - 1) % weapons.size()
			if current_weapon < 0:
				current_weapon = weapons.size() - 1
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			current_weapon = (current_weapon + 1) % weapons.size()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()

func shoot():
	if can_shoot and weapons[current_weapon]["name"] == "cannon":
		# Spawn a bullet
		var bullet = bullet_scene.instantiate()
		
		# Calculate the center of the Head sprite
		bullet.position = cannon.global_position
		
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		get_parent().add_child(bullet)
		
		# Start cooldown
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

func pickup_weapon(weapon_name: String, ammo: int):
	for i in range(1, weapons.size()):
		if weapons[i]["name"] == "Empty":
			weapons[i] = {"name": weapon_name, "ammo": ammo}
			current_weapon = i
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			return
	if current_weapon != 0:
		weapons[current_weapon] = {"name": weapon_name, "ammo": ammo}
		emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
