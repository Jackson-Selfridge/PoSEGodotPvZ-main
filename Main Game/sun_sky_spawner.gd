extends Node

@export var sun_scene: PackedScene
@export var lawn: Lawn            # drag your lawn node into this slot in the Inspector
@export var enabled := true       # turn off for night levels
@export var first_delay := 5.0
@export var min_interval := 8.0
@export var max_interval := 12.0
@export var spawn_height := 250.0 # how far above the landing spot the sun appears

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	if enabled:
		timer.start(first_delay)

func _on_timer_timeout() -> void:
	_spawn_sun()
	timer.start(randf_range(min_interval, max_interval))

func _spawn_sun() -> void:
	# Pick a random tile, with a little jitter so suns don't land dead center
	var cell := Vector2i(randi_range(0, lawn.COLS - 1), randi_range(0, lawn.ROWS - 1))
	var landing := lawn.grid_to_world(cell) + Vector2(randf_range(-25.0, 25.0), randf_range(-25.0, 25.0))
	
	var sun: Sun = sun_scene.instantiate()
	get_parent().add_child(sun)
	sun.global_position = Vector2(landing.x, landing.y - spawn_height)
	sun.fall_to(landing)
