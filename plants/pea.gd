extends Area2D

@export var speed := 400.0
@export var damage := 20

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position.x += speed * delta

func _on_area_entered(area: Area2D) -> void:
	var zombie := area.get_parent()  # assumes the hitbox Area2D is a child of the zombie
	if zombie.has_method("take_damage"):
		zombie.take_damage(damage)
	queue_free()
