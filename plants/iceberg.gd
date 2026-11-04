class_name LobbedProjectile
extends Node2D

@export var damage := 40
@export var speed := 350.0       # horizontal px/sec, sets flight time from distance
@export var arc_height := 80.0
@export var spin_speed := 8.0    # radians/sec, set to 0 if you don't want spin
@export var slow_multiplier := 1.0   # 1.0 = no slow, 0.5 = half speed, 0.75 = 25% slower
@export var slow_duration := 5.0     # seconds

var _start: Vector2
var _end: Vector2
var _target: Node2D
var _elapsed := 0.0
var _duration := 1.0

func launch(target: Node2D) -> void:
	_target = target
	_start = global_position
	_end = target.global_position
	_duration = maxf(_start.distance_to(_end) / speed, 0.25)

func _process(delta: float) -> void:
	# Keep tracking the target while it's alive so walking zombies don't dodge it
	if is_instance_valid(_target):
		_end = _target.global_position
	
	_elapsed += delta
	var t := minf(_elapsed / _duration, 1.0)
	$"."
	var pos := _start.lerp(_end, t)
	pos.y -= arc_height * 4.0 * t * (1.0 - t)   # parabola, peaks mid-flight
	global_position = pos
	rotation += spin_speed * delta
	
	if t >= 1.0:
		_hit()

func _hit() -> void:
	if is_instance_valid(_target):
		if _target.has_method("take_damage"):
			_target.take_damage(damage)
		if slow_multiplier < 1.0 and _target.has_method("apply_slow"):
			_target.apply_slow(slow_multiplier, slow_duration)
	queue_free()
