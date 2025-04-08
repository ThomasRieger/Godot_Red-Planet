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
var follow_speed: float = 5.0
var timer: float = 0.0

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
	# Initialize all weapon slots and highlight the default (cannon in slot 0)
	for i in range(slots.size()):
		var weapon_name = player.weapons[i]["name"]
		var ammo = player.weapons[i]["ammo"]
		var ammo_text = "Inf" if ammo == -1 else str(ammo)
		slots[i].text = "%s: %s" % [weapon_name, ammo_text]
		# Highlight the default slot (slot 0, cannon)
		slots[i].modulate = Color(1, 1, 1, 0.5) if i != 0 else Color(1, 1, 1, 1)

func _physics_process(delta):
	camera.position = camera.position.lerp(player.position, follow_speed * delta)
	
	timer += delta
	var minutes = int(timer / 60)
	var seconds = int(timer) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _on_player_health_changed(new_health: int):
	health_label.text = "Health: %d" % new_health

func _on_player_weapon_changed(slot: int, weapon_name: String, ammo: int):
	var ammo_text = "Inf" if ammo == -1 else str(ammo)
	slots[slot].text = "%s: %s" % [weapon_name, ammo_text]
	# Highlight the active slot
	for i in range(slots.size()):
		slots[i].modulate = Color(1, 1, 1, 0.5) if i != slot else Color(1, 1, 1, 1)
