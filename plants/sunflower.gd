extends Node2D

@export var sun_scene: PackedScene
@export var sun_interval := 15.0
@export var first_sun_delay := 7.0   # the first sun comes out a bit early, like in PvZ
@export var max_health:float=100.0

var current_health:float
var is_placed:bool=false

@onready var sun_timer: Timer = $SunTimer
@onready var spawn_point: Marker2D = $SunSpawnPoint

func _ready() -> void:
	current_health=max_health
	sun_timer.one_shot = true
	sun_timer.timeout.connect(_on_sun_timer_timeout)
	sun_timer.stop()

func setup(_cell:Vector2i,_lawn:Lawn)->void:
	is_placed=true
	add_to_group("plants")
	sun_timer.start(first_sun_delay)

func _on_sun_timer_timeout() -> void:
	if not is_placed:
		return
	
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
func take_damage(amount:float)->void:
	if not is_placed:
		return
	
	current_health-=amount
	print("Sunflower health is:",current_health)
	if current_health<=0:
		die()
func die()-> void:
	print("Sunflower has been destroyed")
	is_placed=false
	sun_timer.stop()
	queue_free()
