extends Node2D

@export var lawn: Lawn
@export var peashooter_scene: PackedScene

var occupied_cells: Dictionary = {}
var preview: Node2D=null


func _ready() -> void:
	if lawn ==null:
		push_error("PlantPlacement: Lawn has not been assigned.")
	else:
		print("PlantPlacement: Lawn connected successfully.")
		print("Grid size: ", lawn.COLS, " columns x ", lawn.ROWS, " rows.")

func _process(_delta: float) -> void:
	if preview != null:
		var cell:=get_mouse_cell()
		var cell_position=lawn.to_global(lawn.map_to_local(cell))
		preview.global_position = cell_position

func start_plant_preview() -> void:
	if peashooter_scene == null:
		push_error("Peashooter scene has not been assigned.")
		return
	if preview != null:
		preview.queue_free()
	preview = peashooter_scene.instantiate()
	add_child(preview)
	
func get_mouse_cell()->Vector2i:
	var mouse_position= lawn.to_local(get_global_mouse_position())
	return lawn.local_to_map(mouse_position)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		start_plant_preview()
