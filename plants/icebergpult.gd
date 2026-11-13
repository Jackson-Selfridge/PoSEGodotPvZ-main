extends Node2D

@export var projectile_scene: PackedScene
@export var shoot_interval := 2.5  # peashooter is 1.5; real PvZ cabbage-pult is ~3.0
@export var max_health:float=100.0

var current_health:float
var is_placed:bool=false

@onready var sight: Area2D = $SightArea
@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	current_health=max_health
	
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	shoot_timer.stop()
	sight.monitoring=false

# Same setup as the peashooter: builds the lane-wide sight box
func setup(cell: Vector2i, lawn: Lawn) -> void:
	var tile_size := Vector2(lawn.tile_set.tile_size)
	var width := (lawn.COLS - cell.x) * tile_size.x
	
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, tile_size.y * 0.8)
	
	var col_shape: CollisionShape2D = $SightArea/CollisionShape2D
	col_shape.shape = shape
	col_shape.position = Vector2(width / 2.0 - tile_size.x / 2.0, 0)
	is_placed=true
	add_to_group("plants")
	
	sight.monitoring=true
	shoot_timer.start()
	
	
func _on_shoot_timer_timeout() -> void:
	if not is_placed:
		return
	var target := _get_target()
	if target:
		_shoot(target)

# Picks the zombie closest to the plant in its lane
func _get_target() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for area in sight.get_overlapping_areas():
		var zombie := area.get_parent() as Node2D
		if zombie == null:
			continue
		if not zombie.is_in_group("zombies"):
			continue
		var dist := global_position.distance_to(zombie.global_position)
		if dist < best_dist:
			best_dist = dist
			best = zombie
	return best

func _shoot(target: Node2D) -> void:
	if projectile_scene==null:
		push_error("Icebergpult: Projectile scene has not been assigned.")
		return
		
	var shot: LobbedProjectile = projectile_scene.instantiate()
	
	get_parent().add_child(shot)
	shot.global_position = muzzle.global_position
	shot.launch(target)

func take_damage(amount:float)->void:
	if not is_placed:
		return
	
	current_health-=amount
	
	print("Icebergpult health: ", current_health)
	if current_health<=0:
		die()
	
func die()->void:
	print("Iceberg has been destroyed")
	queue_free()
