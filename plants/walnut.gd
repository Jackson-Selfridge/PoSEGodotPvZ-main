class_name Plant
extends Node2D

signal died

@export var max_health := 300

var health: int
var cell: Vector2i
var lawn: Lawn
var _dead := false

func _ready() -> void:
	health = max_health

# The planting code already calls this, so it just starts doing something useful
func setup(plant_cell: Vector2i, plant_lawn: Lawn) -> void:
	cell = plant_cell
	lawn = plant_lawn

func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	_on_damaged()
	if health <= 0:
		_die()

# Subclasses override this for things like cracked sprites
func _on_damaged() -> void:
	pass

func _die() -> void:
	_dead = true
	if lawn:
		lawn.set_occupied(cell, false)   # frees the tile so you can replant
	died.emit()
	queue_free()
