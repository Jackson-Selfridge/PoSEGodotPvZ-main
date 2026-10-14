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
		for zombie in get_tree().get_nodes_in_group("zombies"):
			zombie.game_over = true
			
		await get_tree().create_timer(2.0).timeout

		get_tree().change_scene_to_file("res://Main Menu/mainmenu.tscn")
