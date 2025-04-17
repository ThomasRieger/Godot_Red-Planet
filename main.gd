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
@onready var minimap: ColorRect = $CanvasLayer/MinimapContainer/Minimap
var follow_speed: float = 5.0
var timer: float = 0.0
var walker_enemy_scene = preload("res://Enemy/WalkerEnemy.tscn")
var room_scenes = [
	preload("res://Room/grid_room_1.tscn"),
	preload("res://Room/grid_room_2.tscn"),
	preload("res://Room/grid_room_3.tscn"),
	preload("res://Room/grid_room_4.tscn"),
	preload("res://Room/grid_room_5.tscn")
]
var map_width: int = 10
var map_height: int = 10
var room_size: int = 300
var rooms = []

func _ready():
	# Generate the 10x10 map
	for x in range(map_width):
		var row = []
		for y in range(map_height):
			var room_scene = room_scenes[randi() % room_scenes.size()]
			var room = room_scene.instantiate()
			room.position = Vector2(x * room_size, y * room_size)
			add_child(room)
			move_child(room, 0)
			room.visible = false
			row.append(room)
		rooms.append(row)

	# Position the player at the center of the grid (5, 5)
	player.position = Vector2(1650, 1650)
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
	for i in range(slots.size()):
		var weapon_name = player.weapons[i]["name"]
		var ammo = player.weapons[i]["ammo"]
		update_slot(i, weapon_name, ammo)
		slots[i].modulate = Color(1, 1, 1, 0.5) if i != 0 else Color(1, 1, 1, 1)

	# Connect the enemy spawn timer
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)

	# Initial visibility update
	update_room_visibility()

	# Initialize minimap
	minimap.update_player_position(player.position)

func _physics_process(delta):
	camera.position = camera.position.lerp(player.position, follow_speed * delta)
	
	timer += delta
	var minutes = int(timer / 60)
	var seconds = int(timer) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

	# Update room visibility each frame
	update_room_visibility()

	# Update minimap with player's current position
	minimap.update_player_position(player.position)

func update_room_visibility():
	var player_grid_x = int(player.position.x / room_size)
	var player_grid_y = int(player.position.y / room_size)
	var visibility_distance = 2

	for x in range(map_width):
		for y in range(map_height):
			var distance_x = abs(x - player_grid_x)
			var distance_y = abs(y - player_grid_y)
			var room = rooms[x][y]
			room.visible = distance_x <= visibility_distance and distance_y <= visibility_distance

func _on_player_health_changed(new_health: int):
	health_label.text = "Health: %d" % new_health

func _on_player_weapon_changed(slot: int, weapon_name: String, ammo: int):
	update_slot(slot, weapon_name, ammo)
	for i in range(slots.size()):
		if slots[i].visible:
			slots[i].modulate = Color(1, 1, 1, 0.5) if i != slot else Color(1, 1, 1, 1)

func update_slot(slot: int, weapon_name: String, ammo: int):
	slots[slot].visible = weapon_name != "Empty"
	if slots[slot].visible:
		var ammo_text = "Inf" if ammo == -1 else str(ammo)
		slots[slot].text = "%s: %s" % [weapon_name, ammo_text]

func _on_enemy_spawn_timer_timeout():
	var num_enemies = randi_range(5, 10)
	for i in range(num_enemies):
		spawn_enemy()

func spawn_enemy():
	var viewport_size = get_viewport_rect().size / camera.zoom
	var spawn_radius = max(viewport_size.x, viewport_size.y) * 0.7
	var angle = randf_range(0, 2 * PI)
	var spawn_offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_position = player.global_position + spawn_offset

	var map_max = map_width * room_size
	spawn_position.x = clamp(spawn_position.x, 0, map_max)
	spawn_position.y = clamp(spawn_position.y, 0, map_max)

	var min_distance = 300.0
	var direction_to_player = (player.global_position - spawn_position).normalized()
	var distance_to_player = player.global_position.distance_to(spawn_position)
	if distance_to_player < min_distance:
		spawn_position = player.global_position + direction_to_player * min_distance

	var enemy = walker_enemy_scene.instantiate()
	enemy.global_position = spawn_position
	add_child(enemy)
