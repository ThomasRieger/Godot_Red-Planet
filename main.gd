extends Node2D

@onready var player: CharacterBody2D = $Player/CharacterBody2D
@onready var camera: Camera2D = $Camera2D
@onready var health_label: Label = $CanvasLayer/VBoxContainer/HealthLabel
@onready var timer_label: Label = $CanvasLayer/VBoxContainer/TimerLabel
@onready var slots = [
	$CanvasLayer/HBoxContainer/Slot1,
	$CanvasLayer/HBoxContainer/Slot2,
	$CanvasLayer/HBoxContainer/Slot3,
	$CanvasLayer/HBoxContainer/Slot4,
	$CanvasLayer/HBoxContainer/Slot5
]
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
var follow_speed: float = 5.0
var timer: float = 0.0
var walker_enemy_scene = preload("res://Enemy/WalkerEnemy.tscn")

func _ready():
	player.position = Vector2(100, 100)
	camera.position = player.position

	# Connect player signals to UI updates
	if player.health_changed.is_connected(_on_player_health_changed):
		player.health_changed.disconnect(_on_player_health_changed)
	player.health_changed.connect(_on_player_health_changed)
	if player.weapon_changed.is_connected(_on_player_weapon_changed):
		player.weapon_changed.disconnect(_on_player_weapon_changed)
	player.weapon_changed.connect(_on_player_weapon_changed)

	# Initialize UI
	_on_player_health_changed(player.health)
	# Initialize all weapon slots
	for i in range(slots.size()):
		var weapon_name = player.weapons[i]["name"]
		var ammo = player.weapons[i]["ammo"]
		update_slot(i, weapon_name, ammo)
		# Highlight the default slot (slot 0, cannon)
		slots[i].modulate = Color(1, 1, 1, 0.5) if i != 0 else Color(1, 1, 1, 1)

	# Connect the enemy spawn timer
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)

func _physics_process(delta):
	camera.position = camera.position.lerp(player.position, follow_speed * delta)
	
	timer += delta
	var minutes = int(timer / 60)
	var seconds = int(timer) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _on_player_health_changed(new_health: int):
	health_label.text = "Health: %d" % new_health

func _on_player_weapon_changed(slot: int, weapon_name: String, ammo: int):
	update_slot(slot, weapon_name, ammo)
	# Highlight the active slot
	for i in range(slots.size()):
		if slots[i].visible:  # Only highlight visible slots
			slots[i].modulate = Color(1, 1, 1, 0.5) if i != slot else Color(1, 1, 1, 1)

func update_slot(slot: int, weapon_name: String, ammo: int):
	# Hide the slot if it's empty, show it otherwise
	slots[slot].visible = weapon_name != "Empty"
	if slots[slot].visible:
		var ammo_text = "Inf" if ammo == -1 else str(ammo)
		slots[slot].text = "%s: %s" % [weapon_name, ammo_text]

func _on_enemy_spawn_timer_timeout():
	# Spawn 5 to 10 enemies at a time
	var num_enemies = randi_range(5, 10)
	for i in range(num_enemies):
		spawn_enemy()

func spawn_enemy():
	# Get the viewport size (adjusted for camera zoom if any)
	var viewport_size = get_viewport_rect().size / camera.zoom
	# Calculate a spawn position outside the viewport
	var spawn_radius = max(viewport_size.x, viewport_size.y) * 0.7  # Slightly outside the viewport
	var angle = randf_range(0, 2 * PI)  # Random angle in radians
	var spawn_offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_position = player.global_position + spawn_offset

	# Ensure the position is within reasonable bounds (adjust based on your game world size)
	spawn_position.x = clamp(spawn_position.x, -1000, 1000)
	spawn_position.y = clamp(spawn_position.y, -1000, 1000)

	# Spawn the enemy
	var enemy = walker_enemy_scene.instantiate()
	enemy.global_position = spawn_position
	add_child(enemy)
