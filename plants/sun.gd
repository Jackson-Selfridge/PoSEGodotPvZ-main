class_name Sun
extends Area2D

signal collected(value: int)

@export var value := 25
@export var lifetime := 10.0   # seconds before it starts fading away

var _collected := false

func _ready() -> void:
	input_event.connect(_on_input_event)
	
	# Sits there for `lifetime`, fades out over 1 second, then disappears
	var tween := create_tween()
	tween.tween_interval(lifetime)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)

# Pops the sun out in a little arc and lands it at `landing_pos`
func launch(landing_pos: Vector2) -> void:
	var peak_y := minf(global_position.y, landing_pos.y) - 40.0
	
	var tween_x := create_tween()
	tween_x.tween_property(self, "global_position:x", landing_pos.x, 0.6)
	
	var tween_y := create_tween()
	tween_y.tween_property(self, "global_position:y", peak_y, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, "global_position:y", landing_pos.y, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _collected:
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_collect()

func _collect() -> void:
	_collected = true
	collected.emit(value)
	print("Collected ", value, " sun")  # placeholder until the bank exists
	queue_free()
