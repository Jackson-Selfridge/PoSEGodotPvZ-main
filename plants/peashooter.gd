extends Node2D

@export var pea_scene: PackedScene
@export var shoot_interval := 1.5

@onready var sight: Area2D = $SightArea
@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

# Call this right after instancing, with the cell it was planted in.
func setup(cell: Vector2i, lawn: Lawn) -> void:
	var tile_size := Vector2(lawn.tile_set.tile_size)
	var width := (lawn.COLS - cell.x) * tile_size.x
	
	# New shape per instance, otherwise all peashooters would share one resource
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, tile_size.y * 0.8)  # a bit shorter than the lane
	
	var col_shape: CollisionShape2D = $SightArea/CollisionShape2D
	col_shape.shape = shape
	# Plant origin is the tile center, so shift the box to start at this tile's left edge
	col_shape.position = Vector2(width / 2.0 - tile_size.x / 2.0, 0)

func _on_shoot_timer_timeout() -> void:
	if sight.has_overlapping_areas():
		_shoot()

func _shoot() -> void:
	var pea := pea_scene.instantiate()
	# Add to the level, not the plant, so peas keep flying if the plant dies
	get_parent().add_child(pea)
	pea.global_position = muzzle.global_position
