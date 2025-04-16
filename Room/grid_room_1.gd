extends Node2D

@onready var bg = $bg

@export var rock_scene = preload("res://Room/rocks.tscn")
@export var num_clusters: int = 50
@export var rocks_per_cluster: int = 50
@export var cluster_radius: float = 100.0

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	rocks_per_cluster = rng.randi_range(3, 100)
	
	for i in range(num_clusters):
		var cluster_center = Vector2(
			rng.randi_range(-480, 480),
			rng.randi_range(-270, 270)
		)

		for j in range(rocks_per_cluster):
			var rock = rock_scene.instantiate()
			
			var offset = Vector2(
				rng.randf_range(-cluster_radius, cluster_radius),
				rng.randf_range(-cluster_radius, cluster_radius)
			)
			offset *= rng.randf()  # bias toward center

			rock.position = cluster_center + offset
			rock.scale = Vector2.ONE * rng.randf_range(0.5, 1.5)
			rock.rotation_degrees = rng.randf_range(0, 360)
			
			# Color: full red (0.6 - 1.0), lower green/blue (0 - 0.2)
			var red = rng.randf_range(0.6, 0.7)
			var green_blue = rng.randf_range(0.2, 0.4)
			rock.modulate = Color(red, green_blue, green_blue)

			add_child(rock)
