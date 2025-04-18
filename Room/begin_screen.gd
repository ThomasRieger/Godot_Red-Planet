extends ColorRect

var rng = RandomNumberGenerator.new()
var animation_started := false
var star = preload("res://Room/star.tscn")

@onready var star_ship = $star_ship
@onready var planet = $planet
@onready var press_label = $press_label
@onready var crash_label = $crash_label
var original_ship_pos = Vector2(480, 270)

func _ready() -> void:
	press_blink()
	updown_ship()
	gen_star()
	self.visible = true
	#gen_star
	get_tree().paused = true
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not animation_started:
		animation_started = true
		start_title_animation()

func press_blink() -> void:
	if animation_started:
		return
	press_label.visible = true
	await get_tree().create_timer(1).timeout
	press_label.visible = false
	await get_tree().create_timer(0.7).timeout
	press_blink()

func updown_ship() -> void:
	if animation_started:
		return
	var tween = create_tween()
	tween.tween_property(star_ship, "position:y", original_ship_pos.y - 15, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(1).timeout
	tween = create_tween()
	tween.tween_property(star_ship, "position:y", original_ship_pos.y + 15, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(1).timeout
	updown_ship()

func gen_star() -> void:
	if animation_started:
		return
	await get_tree().create_timer(rng.randf_range(0.01,0.5)).timeout
	var new_star = star.instantiate()
	new_star.position = Vector2(1000, rng.randi_range(0, 540))
	var star_id = rng.randi_range(0, 2)
	new_star.get_child(0).frame = star_id
	new_star.z_index = 10
	match star_id:
		0:
			new_star.scale /= rng.randf_range(1, 2)
		1:
			new_star.scale /= rng.randf_range(1, 2)
		2:
			new_star.scale *= rng.randf_range(1, 2)
	add_child(new_star)
	gen_star()

func start_title_animation():
	#print("Title animation started")
	var tween = create_tween()
	tween.tween_property(planet, "position:x", 770, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var tween2 = create_tween()
	tween2.tween_property(star_ship, "position:x", 700, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1).timeout
	var tween3 = create_tween()
	tween3.tween_property(star_ship, "rotation", 5, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var tween4 = create_tween()
	tween4.tween_property(star_ship, "position", star_ship.position + Vector2(100, 100), 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var tween5 = create_tween()
	tween5.tween_property(star_ship, "modulate:a", 0, 1.5).set_trans(Tween.TRANS_SINE)
	var tween6 = create_tween()
	tween6.tween_property(crash_label, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.8).timeout
	
	var tween7 = create_tween()
	tween7.tween_property(get_parent(), "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	get_parent().get_parent().queue_free()
