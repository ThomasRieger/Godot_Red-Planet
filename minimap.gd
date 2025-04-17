extends ColorRect

var player_position: Vector2 = Vector2.ZERO
var rocket_parts = []
var silo_position: Vector2 = Vector2(1650, 1650)  # Fixed position of the rocket silo
var map_size: Vector2 = Vector2(3000, 3000)
var minimap_size: Vector2 = Vector2(200, 200)

func _draw():
	# Draw rocket parts
	for part in rocket_parts:
		var part_pos = part.global_position
		var scaled_pos = (part_pos / map_size) * minimap_size
		var part_rect = Rect2(scaled_pos - Vector2(2.5, 2.5), Vector2(5, 5))
		draw_rect(part_rect, Color.YELLOW)

	# Draw rocket silo
	var scaled_silo_pos = (silo_position / map_size) * minimap_size
	var silo_rect = Rect2(scaled_silo_pos - Vector2(2.5, 2.5), Vector2(5, 5))
	draw_rect(silo_rect, Color.WHITE)

	# Draw player
	var scaled_pos = (player_position / map_size) * minimap_size
	var player_rect = Rect2(scaled_pos - Vector2(2.5, 2.5), Vector2(5, 5))
	draw_rect(player_rect, Color.RED)

func update_player_position(pos: Vector2):
	player_position = pos
	queue_redraw()

func update_rocket_parts(parts: Array):
	rocket_parts = parts
	queue_redraw()
