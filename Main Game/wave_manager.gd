extends Node

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

var zombie_scene = preload("res://zombies/zombie.tscn")

@export var initial_zombies: int = 3
@export var initial_spawn_interval: float = 3.0
@export var initial_zombie_health: float = 100.0

var spawn_x: float = 1000.0
var lane_positions = [64.0, 192.0, 320.0, 448.0, 576.0]

var wave_number: int = 0
var zombies_to_spawn: int = 0
var alive_zombies: int = 0
var spawning: bool = false
var game_over: bool = false


func _ready():
	$SpawnTimer.wait_time = initial_spawn_interval
	$SpawnTimer.one_shot = false
	$SpawnTimer.start()
	start_next_wave()


func start_next_wave():
	if game_over:
		return
	wave_number += 1
	zombies_to_spawn = initial_zombies + (wave_number - 1) * 2
	spawning = true

	print("Starting wave ", wave_number)
	print("Zombies in this wave: ", zombies_to_spawn)

	wave_started.emit(wave_number)
	spawn_zombie()


func _on_spawn_timer_timeout():
	if game_over:
		return
	if spawning and zombies_to_spawn > 0:
		spawn_zombie()


func spawn_zombie():
	if zombies_to_spawn <= 0:
		return
	if zombies_to_spawn <=0:
		return

	var zombie = zombie_scene.instantiate()

	var random_lane = randi_range(0, lane_positions.size() - 1)
	zombie.position = Vector2(spawn_x, lane_positions[random_lane])

	zombie.max_health = initial_zombie_health + (wave_number - 1) * 15

	zombie.died.connect(_on_zombie_died)

	get_parent().add_child.call_deferred(zombie)

	zombies_to_spawn -= 1
	alive_zombies += 1

	if zombies_to_spawn == 0:
		spawning = false
		$SpawnTimer.stop()


func _on_zombie_died():
	alive_zombies -= 1

	if alive_zombies <= 0 and zombies_to_spawn == 0:
		complete_wave()


func complete_wave():
	if game_over:
		return
	print("Wave ", wave_number, " completed!")
	wave_completed.emit(wave_number)

	$SpawnTimer.wait_time = max(
		0.5,
		initial_spawn_interval - (wave_number * 0.2)
	)

	$SpawnTimer.start()

	await get_tree().create_timer(3.0).timeout

	start_next_wave()
	
func stop_game():
	if game_over:
		return

	game_over = true
	spawning = false
	$SpawnTimer.stop()
	print("Game Over! Zombie spawning stopped.")
