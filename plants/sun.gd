class_name Sun
extends Area2D

signal collected(value: int)

@export var value := 25
@export var lifetime := 8.0   # seconds it sits on the ground before fading

var _collected := false

func _ready() -> void:
	input_event.connect(_on_input_event)

# Sunflower style: pops out in a little arc
func launch(landing_pos: Vector2) -> void:
	var peak_y := minf(global_position.y, landing_pos.y) - 40.0
	
	var tween_x := create_tween()
	tween_x.tween_property(self, "global_position:x", landing_pos.x, 0.6)
	
	var tween_y := create_tween()
	tween_y.tween_property(self, "global_position:y", peak_y, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, "global_position:y", landing_pos.y, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween_y.tween_callback(_start_expiry)

# Sky style: falls straight down at a constant speed
func fall_to(landing_pos: Vector2, fall_speed := 60.0) -> void:
	var duration := absf(landing_pos.y - global_position.y) / fall_speed
	var tween := create_tween()
	tween.tween_property(self, "global_position", landing_pos, duration)
	tween.tween_callback(_start_expiry)

func _start_expiry() -> void:
	var tween := create_tween()
	tween.tween_interval(lifetime)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _collected:
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_collect()

func _collect() -> void:
	_collected = true
	collected.emit(value)
	SunBank.add(value)
	queue_free()
