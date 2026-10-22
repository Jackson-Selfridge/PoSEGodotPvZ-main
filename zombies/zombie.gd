extends CharacterBody2D

signal died

@export var move_speed: float = 30.0
@export var max_health: float = 100.0
@export var attack_damage:float=25.0

var current_health: float
var is_dead: bool = false
var current_target: Node=null
var game_over: bool = false


func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	current_health = max_health
	add_to_group("zombies")


func _physics_process(_delta):
	if is_dead or game_over:
		velocity= Vector2.ZERO
		return
	if is_instance_valid(current_target):
		velocity =Vector2.ZERO
	else:
		velocity=Vector2.LEFT*move_speed

	move_and_slide()


func take_damage(amount: float):
	if is_dead:
		return

	current_health -= amount
	print("Zombie health: ", current_health)

	if current_health <= 0:
		die()


func die():
	if is_dead:
		return

	is_dead = true
	died.emit()
	queue_free()


func _on_attack_area_body_entered(body: Node2D):
	if body.is_in_group("plants"):
		current_target = body
		$AttackTimer.start()
		#Add it to plants group


func _on_attack_area_body_exited(body: Node2D):
	if body == current_target:
		current_target = null
		$AttackTimer.stop()

func _on_attack_timer_timeout():
	if not is_instance_valid(current_target):
		$AttackTimer.stop()
		return
	if current_target.has_method("take_damage"):
		current_target.take_damage(attack_damage)
