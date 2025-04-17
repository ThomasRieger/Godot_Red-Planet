extends ColorRect

var player_position: Vector2 = Vector2.ZERO
var map_size: Vector2 = Vector2(3000, 3000)  # World map size (10x10 rooms, 3000x3000)
var minimap_size: Vector2 = Vector2(200, 200)  # Minimap display size

func _draw():
	# Scale the player's world position to the minimap
	var scaled_pos = (player_position / map_size) * minimap_size
	# Draw a small white dot (5x5 pixels) for the player
	var player_rect = Rect2(scaled_pos - Vector2(2.5, 2.5), Vector2(5, 5))
	draw_rect(player_rect, Color.WHITE)

func update_player_position(pos: Vector2):
	player_position = pos
	queue_redraw()  # Redraw the minimap when the player's position changes
