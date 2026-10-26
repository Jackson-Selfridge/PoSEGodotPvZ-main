extends Node2D

@export var sun_scene: PackedScene
@export var sun_interval := 15.0
@export var first_sun_delay := 7.0   # the first sun comes out a bit early, like in PvZ

@onready var sun_timer: Timer = $SunTimer
@onready var spawn_point: Marker2D = $SunSpawnPoint

func _ready() -> void:
	sun_timer.one_shot = true
	sun_timer.timeout.connect(_on_sun_timer_timeout)
	sun_timer.start(first_sun_delay)

func _on_sun_timer_timeout() -> void:
	_produce_sun()
	sun_timer.start(sun_interval)

func _produce_sun() -> void:
	var sun: Sun = sun_scene.instantiate()
	# Add to the level, not the plant, so the sun stays if the plant gets eaten
	get_parent().add_child(sun)
	sun.global_position = spawn_point.global_position
	
	# Land somewhere near the flower, slightly left or right and a bit below it
	var offset := Vector2(randf_range(-30.0, 30.0), randf_range(20.0, 40.0))
	sun.launch(global_position + offset)
