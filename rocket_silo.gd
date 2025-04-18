extends Area2D

signal parts_updated(current_parts: int)
signal rocket_launched

var required_parts: int = 6
var current_parts: int = 0

func _ready():
	add_to_group("silo")

func add_part():
	current_parts += 1
	print("Adding part. Current parts: %d/%d" % [current_parts, required_parts])
	emit_signal("parts_updated", current_parts)
	if current_parts >= required_parts:
		print("All parts delivered! Launching rocket.")
		launch_rocket()
	else:
		print("Not enough parts yet: %d/%d" % [current_parts, required_parts])

func launch_rocket():
	get_node("../title_screen/title_screen/begin_screen").win()
	print("Emitting rocket_launched signal")
	#emit_signal("rocket_launched")
	get_tree().paused = true
