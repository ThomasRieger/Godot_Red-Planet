extends CanvasLayer

@onready var control = $RbControl

func _ready() -> void:
	pass

func control_gone() -> void:
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(control, "modulate:a", 0, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
