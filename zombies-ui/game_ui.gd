
extends Control

@onready var continue_popup = $ContinuePopup
@onready var continue_button = $ContinuePopup/ContinueButton
@onready var restart_button = $ContinuePopup/RestartButton

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

func _on_continue_pressed():
	continue_popup.hide()
	get_tree().paused = false


func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
