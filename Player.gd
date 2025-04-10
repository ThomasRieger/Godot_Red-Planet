extends CharacterBody2D

@export var speed = 100
@onready var cannon = $Head
@onready var body = $Wheel
@onready var cannon_sprite = $Head/CannonSprite
@onready var machine_gun_sprite = $Head/MachineGunSprite
@onready var shotgun_sprite = $Head/ShotgunSprite
@onready var lazer_cannon_sprite = $Head/LazerSprite
@onready var rocket_cannon_sprite = $Head/RocketCannonSprite  # New rocket cannon sprite
@onready var bullet_spawn_point = $Head/BulletSpawnPoint
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
var lazer_scene = preload("res://Weapon/Lazer.tscn")
var rocket_scene = preload("res://Weapon/Rocket.tscn")  # New rocket scene
var can_shoot = true
var shoot_cooldown = 1.0  # Cooldown for cannon and shotgun
var machine_gun_cooldown = 0.1  # Faster cooldown for machine gun
var lazer_cannon_cooldown = 1.5  # Cooldown for lazer cannon
var rocket_cannon_cooldown = 2.0  # Slower cooldown for rocket cannon
var is_shooting = false

signal weapon_changed(slot, weapon_name, ammo)
signal health_changed(new_health)

func _ready():
	add_to_group("player")
	update_weapon_sprite()
	emit_signal("health_changed", health)
	emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
	body.play("wheels")

func _physics_process(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("a", "d")
	direction.y = Input.get_axis("w", "s")
	velocity = direction.normalized() * speed
	move_and_slide()

	# Rotate the cannon (Head node) toward the mouse
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

	# Handle rapid-fire shooting for machine gun
	if is_shooting and weapons[current_weapon]["name"] == "machine_gun":
		shoot()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			var new_slot = current_weapon
			for i in range(weapons.size()):
				new_slot = (new_slot - 1) % weapons.size()
				if new_slot < 0:
					new_slot = weapons.size() - 1
				if weapons[new_slot]["name"] != "Empty":
					current_weapon = new_slot
					break
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			var new_slot = current_weapon
			for i in range(weapons.size()):
				new_slot = (new_slot + 1) % weapons.size()
				if weapons[new_slot]["name"] != "Empty":
					current_weapon = new_slot
					break
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_shooting = true
				if weapons[current_weapon]["name"] != "machine_gun":
					shoot()
			else:
				is_shooting = false

func shoot():
	if not can_shoot:
		return

	if weapons[current_weapon]["name"] == "cannon":
		var bullet = bullet_scene.instantiate()
		bullet.position = bullet_spawn_point.global_position
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		bullet.damage = 10
		get_parent().add_child(bullet)
		
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

	elif weapons[current_weapon]["name"] == "machine_gun" and weapons[current_weapon]["ammo"] > 0:
		var bullet = bullet_scene.instantiate()
		bullet.position = bullet_spawn_point.global_position
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		bullet.damage = 5
		get_parent().add_child(bullet)
		
		weapons[current_weapon]["ammo"] -= 1
		emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		
		if weapons[current_weapon]["ammo"] <= 0:
			weapons[current_weapon] = {"name": "Empty", "ammo": 0}
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			current_weapon = 0
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			return
		
		can_shoot = false
		await get_tree().create_timer(machine_gun_cooldown).timeout
		can_shoot = true

	elif weapons[current_weapon]["name"] == "shotgun" and weapons[current_weapon]["ammo"] > 0:
		var base_direction = (get_global_mouse_position() - global_position).normalized()
		var spread_angle = deg_to_rad(30)
		var pellet_count = 5
		var angle_step = spread_angle / (pellet_count - 1) if pellet_count > 1 else 0
		
		for i in range(pellet_count):
			var angle_offset = (i - (pellet_count - 1) / 2.0) * angle_step
			var pellet_direction = base_direction.rotated(angle_offset)
			
			var bullet = bullet_scene.instantiate()
			bullet.position = bullet_spawn_point.global_position
			bullet.direction = pellet_direction
			bullet.damage = 15
			bullet.lifetime = 0.5
			bullet.speed = 250
			get_parent().add_child(bullet)
		
		weapons[current_weapon]["ammo"] -= 1
		emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		
		if weapons[current_weapon]["ammo"] <= 0:
			weapons[current_weapon] = {"name": "Empty", "ammo": 0}
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			current_weapon = 0
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			return
		
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

	elif weapons[current_weapon]["name"] == "lazer_cannon" and weapons[current_weapon]["ammo"] > 0:
		var lazer = lazer_scene.instantiate()
		lazer.position = bullet_spawn_point.global_position
		lazer.rotation = cannon.rotation
		lazer.damage = 20
		get_parent().add_child(lazer)
		
		weapons[current_weapon]["ammo"] -= 1
		emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		
		if weapons[current_weapon]["ammo"] <= 0:
			weapons[current_weapon] = {"name": "Empty", "ammo": 0}
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			current_weapon = 0
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			return
		
		can_shoot = false
		await get_tree().create_timer(lazer_cannon_cooldown).timeout
		can_shoot = true

	elif weapons[current_weapon]["name"] == "rocket_cannon" and weapons[current_weapon]["ammo"] > 0:
		# Rocket cannon: mid-speed projectile, explodes on impact, 40 damage, 2-second cooldown
		var rocket = rocket_scene.instantiate()
		rocket.position = bullet_spawn_point.global_position
		rocket.direction = (get_global_mouse_position() - global_position).normalized()
		rocket.damage = 40
		get_parent().add_child(rocket)
		
		weapons[current_weapon]["ammo"] -= 1
		emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
		
		if weapons[current_weapon]["ammo"] <= 0:
			weapons[current_weapon] = {"name": "Empty", "ammo": 0}
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			current_weapon = 0
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			return
		
		can_shoot = false
		await get_tree().create_timer(rocket_cannon_cooldown).timeout
		can_shoot = true

func update_weapon_sprite():
	cannon_sprite.visible = weapons[current_weapon]["name"] == "cannon" or weapons[current_weapon]["name"] == "Empty"
	machine_gun_sprite.visible = weapons[current_weapon]["name"] == "machine_gun"
	shotgun_sprite.visible = weapons[current_weapon]["name"] == "shotgun"
	lazer_cannon_sprite.visible = weapons[current_weapon]["name"] == "lazer_cannon"
	rocket_cannon_sprite.visible = weapons[current_weapon]["name"] == "rocket_cannon"

func pickup_weapon(weapon_name: String, ammo: int):
	for i in range(1, weapons.size()):
		if weapons[i]["name"] == weapon_name:
			weapons[i]["ammo"] = 100 if weapon_name == "machine_gun" else 50 if weapon_name == "shotgun" else 20 if weapon_name == "lazer_cannon" else 25  # Refill to base ammo
			current_weapon = i
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			return
	
	for i in range(1, weapons.size()):
		if weapons[i]["name"] == "Empty":
			weapons[i] = {"name": weapon_name, "ammo": ammo}
			current_weapon = i
			update_weapon_sprite()
			emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
			return
	if current_weapon != 0:
		weapons[current_weapon] = {"name": weapon_name, "ammo": ammo}
		update_weapon_sprite()
		emit_signal("weapon_changed", current_weapon, weapons[current_weapon]["name"], weapons[current_weapon]["ammo"])
