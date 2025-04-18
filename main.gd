extends Node2D

@onready var player: CharacterBody2D = $Player/CharacterBody2D
@onready var camera: Camera2D = $Camera2D
@onready var health_label: Label = $CanvasLayer/VBoxContainer/HealthLabel
@onready var timer_label: Label = $CanvasLayer/VBoxContainer/TimerLabel
@onready var parts_label: Label = $CanvasLayer/PartsLabel
@onready var slots = [
	$CanvasLayer/HBoxContainer/Slot1,
	$CanvasLayer/HBoxContainer/Slot2,
	$CanvasLayer/HBoxContainer/Slot3,
	$CanvasLayer/HBoxContainer/Slot4,
	$CanvasLayer/HBoxContainer/Slot5
]
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var weapon_pickup_timer: Timer = $WeaponPickupTimer  # Added
@onready var minimap: ColorRect = $CanvasLayer/MinimapContainer/Minimap
@onready var rocket_silo: Area2D = $RocketSilo
var follow_speed: float = 5.0
var timer: float = 0.0
var walker_enemy_scene = preload("res://Enemy/WalkerEnemy.tscn")
var rocket_part_scene = preload("res://RocketPart.tscn")
# Added weapon pickup scenes
var weapon_pickup_scenes = [
	preload("res://Weapon/MachineGunPickup.tscn"),
	preload("res://Weapon/ShotgunPickup.tscn"),
	preload("res://Weapon/LazerCannonPickup.tscn"),
	preload("res://Weapon/RocketCannonPickup.tscn")
]
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
var rocket_parts = []
var weapon_pickups = []  # Added to track active pickups
var collected_parts: int = 0
var can_deliver: bool = true
var total_parts_required: int = 6

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

	# Position the rocket silo at the player's spawn point
	rocket_silo.position = Vector2(1650, 1650)

	# Verify silo's group
	if rocket_silo.is_in_group("silo"):
		print("RocketSilo is in group 'silo'")
	else:
		print("Error: RocketSilo is not in group 'silo'!")

	# Position the DummyEnemy in a nearby room (6, 6)
	#var dummy_enemy = get_node("DummyEnemy")
	#if dummy_enemy:
		#dummy_enemy.position = Vector2(1950, 1950)

	# Spawn rocket parts
	spawn_rocket_parts()

	# Connect player signals to UI updates
	if player.health_changed.is_connected(_on_player_health_changed):
		player.health_changed.disconnect(_on_player_health_changed)
	player.health_changed.connect(_on_player_health_changed)
	if player.weapon_changed.is_connected(_on_player_weapon_changed):
		player.weapon_changed.disconnect(_on_player_weapon_changed)
	player.weapon_changed.connect(_on_player_weapon_changed)

	# Connect rocket silo signals
	rocket_silo.parts_updated.connect(_on_rocket_silo_parts_updated)
	rocket_silo.rocket_launched.connect(_on_rocket_launched)

	# Get total parts required from the silo
	total_parts_required = rocket_silo.required_parts

	# Connect player to silo interaction
	var player_area = player.get_node("Area2D")
	if player_area:
		player_area.area_entered.connect(_on_player_area_entered)
		player_area.area_exited.connect(_on_player_area_exited)
		print("Player Area2D found and signals connected")
	else:
		print("Error: Player Area2D node not found!")

	# Initialize UI
	_on_player_health_changed(player.health)
	parts_label.text = "Parts: 0/%d" % total_parts_required
	for i in range(slots.size()):
		var weapon_name = player.weapons[i]["name"]
		var ammo = player.weapons[i]["ammo"]
		update_slot(i, weapon_name, ammo)
		slots[i].modulate = Color(1, 1, 1, 0.5) if i != 0 else Color(1, 1, 1, 1)

	# Connect the enemy spawn timer
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)

	# Connect the weapon pickup timer
	weapon_pickup_timer.timeout.connect(_on_weapon_pickup_timer_timeout)  # Added

	# Initial visibility update
	update_room_visibility()

	# Initialize minimap
	minimap.update_player_position(player.position)
	minimap.update_rocket_parts(rocket_parts)
	minimap.update_weapon_pickups(weapon_pickups)  # Added

func spawn_rocket_parts():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var placed_parts = 0
	var num_parts = total_parts_required

	while placed_parts < num_parts:
		var grid_x = rng.randi_range(0, map_width - 1)
		var grid_y = rng.randi_range(0, map_height - 1)
		if grid_x == 5 and grid_y == 5:
			continue
		var room_pos = Vector2(grid_x * room_size, grid_y * room_size)
		var part_pos = room_pos + Vector2(
			rng.randi_range(-150, 150) + 150,
			rng.randi_range(-150, 150) + 150
		)
		var part = rocket_part_scene.instantiate()
		part.position = part_pos
		part.collected.connect(_on_rocket_part_collected)
		add_child(part)
		rocket_parts.append(part)
		placed_parts += 1

func _physics_process(delta):
	camera.position = camera.position.lerp(player.position, follow_speed * delta)
	
	timer += delta
	var minutes = int(timer / 60)
	var seconds = int(timer) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

	# Clamp player's position to map boundaries
	var map_max = map_width * room_size
	player.position.x = clamp(player.position.x, 0, map_max)
	player.position.y = clamp(player.position.y, 0, map_max)

	update_room_visibility()
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

func _on_rocket_part_collected(part: Node):
	collected_parts += 1
	rocket_parts.erase(part)
	var remaining_parts = total_parts_required - rocket_silo.current_parts
	parts_label.text = "Parts: %d/%d" % [collected_parts, remaining_parts]
	minimap.update_rocket_parts(rocket_parts)

func _on_player_area_entered(area: Area2D):
	print("Player entered area: ", area.name)
	if area.is_in_group("silo") and collected_parts > 0 and can_deliver:
		print("Delivering %d parts to silo" % collected_parts)
		can_deliver = false
		for i in range(collected_parts):
			rocket_silo.add_part()
		collected_parts = 0
		var remaining_parts = total_parts_required - rocket_silo.current_parts
		parts_label.text = "Parts: 0/%d" % remaining_parts
	else:
		print("Condition failed: is_in_group('silo') = %s, collected_parts = %d, can_deliver = %s" % [area.is_in_group("silo"), collected_parts, can_deliver])

func _on_player_area_exited(area: Area2D):
	if area.is_in_group("silo"):
		can_deliver = true

func _on_rocket_silo_parts_updated(current_parts: int):
	var remaining_parts = total_parts_required - current_parts
	parts_label.text = "Parts: 0/%d (Delivered: %d/%d)" % [remaining_parts, current_parts, total_parts_required]

func _on_rocket_launched():
	print("Rocket launched signal received. Quitting game for testing.")
	get_tree().quit()
	# Original behavior (commented out):
	# get_tree().change_scene_to_file("res://WinScene.tscn")

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
	var num_enemies = randi_range(4, 6)
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

# Added: Function to spawn weapon pickups
func _on_weapon_pickup_timer_timeout():
	var num_pickups = 2  # Spawn 2 pickups each time
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in range(num_pickups):
		# Select a random pickup type
		var pickup_scene = weapon_pickup_scenes[randi() % weapon_pickup_scenes.size()]
		var pickup = pickup_scene.instantiate()
		
		# Set a random position within the map
		var grid_x = rng.randi_range(0, map_width - 1)
		var grid_y = rng.randi_range(0, map_height - 1)
		var room_pos = Vector2(grid_x * room_size, grid_y * room_size)
		var pickup_pos = room_pos + Vector2(
			rng.randi_range(-150, 150) + 150,
			rng.randi_range(-150, 150) + 150
		)
		pickup.position = pickup_pos
		
		# Connect a signal to handle pickup collection
		pickup.connect("body_entered", _on_weapon_pickup_collected.bind(pickup))
		
		# Add to scene and track in list
		add_child(pickup)
		weapon_pickups.append(pickup)
	
	# Update minimap with new pickups
	minimap.update_weapon_pickups(weapon_pickups)

# Added: Function to handle pickup collection
func _on_weapon_pickup_collected(body: Node, pickup: Node):
	if body.is_in_group("player"):
		weapon_pickups.erase(pickup)
		minimap.update_weapon_pickups(weapon_pickups)
		pickup.queue_free()
