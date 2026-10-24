extends Area2D

signal game_over

@onready var wave_manager = get_parent().get_node("WaveManager")
var game_over_triggered: bool = false


func _on_body_entered(body: Node2D):
	if game_over_triggered:
		return

	if body.is_in_group("zombies"):
		game_over_triggered = true

		print("GAME OVER! A zombie reached the house.")

		game_over.emit()
		wave_manager.stop_game()

		get_tree().create_timer(2.0).timeout.connect(_on_game_over_timer_timeout)


func _on_game_over_timer_timeout():
	get_tree().call_deferred(
		"change_scene_to_file",
        "res://Main Menu/gameover.tscn"
	)
