extends Node2D

@onready var bg = $bg

@export var rock_scene = preload("res://Room/rocks.tscn")
@export var num_clusters: int = 10
@export var rocks_per_cluster: int = 10
@export var cluster_radius: float = 100.0

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	rocks_per_cluster = rng.randi_range(3, 100)
	
	for i in range(num_clusters):
		# Place clusters within a 300x300 square (-150, 150)
		var cluster_center = Vector2(
			rng.randi_range(-150, 150),
			rng.randi_range(-150, 150)
		)

		for j in range(rocks_per_cluster):
			var rock = rock_scene.instantiate()
			
			var offset = Vector2(
				rng.randf_range(-cluster_radius, cluster_radius),
				rng.randf_range(-cluster_radius, cluster_radius)
			)
			offset *= rng.randf()  # Bias toward center

			rock.position = cluster_center + offset
			# Rock size for grid_room_1: 0.5 to 1.5
			rock.scale = Vector2.ONE * rng.randf_range(0.5, 1.5)
			rock.rotation_degrees = rng.randf_range(0, 360)
			
			# Keep colors as defined
			var red = rng.randf_range(0.6, 0.7)
			var green_blue = rng.randf_range(0.2, 0.4)
			rock.modulate = Color(red, green_blue, green_blue)

			# Add to "world" group for collisions
			rock.add_to_group("world")
			add_child(rock)
