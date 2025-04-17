extends Area2D

signal collected(part: Node)

func _ready():
	add_to_group("rocket_parts")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("collected", self)
		queue_free()
