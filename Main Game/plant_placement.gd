extends Node2D

@export var lawn: Lawn
@export var peashooter_scene: PackedScene
@export var sunflower_scene: PackedScene
@onready var peashooter_button: Button=get_node("../UI/UIContainer/PlantPanel/HBoxContainer/PeashooterButton")
@onready var sunflower_button: Button = get_node("../UI/UIContainer/PlantPanel/HBoxContainer/SunflowerButton")


var occupied_cells: Dictionary = {}
var preview: Node2D=null


func _ready() -> void:
	if lawn ==null:
		push_error("PlantPlacement: Lawn has not been assigned.")
	else:
		print("PlantPlacement: Lawn connected successfully.")
		print("Grid size: ", lawn.COLS, " columns x ", lawn.ROWS, " rows.")
	peashooter_button.pressed.connect(_on_peashooter_button_pressed)
	sunflower_button.pressed.connect(_on_sunflower_button_pressed)

func _on_peashooter_button_pressed()->void:
	start_plant_preview(peashooter_scene)
func _on_sunflower_button_pressed()->void:
	start_plant_preview(sunflower_scene)

func _process(_delta: float) -> void:
	if preview != null:
		var cell:=get_mouse_cell()
		var cell_position=lawn.to_global(lawn.map_to_local(cell))
		preview.global_position = cell_position

func start_plant_preview(plant_scene:PackedScene) -> void:
	if plant_scene == null:
		push_error("Plant scene has not been assigned")
		return
	if preview != null:
		preview.queue_free()
	preview = plant_scene.instantiate()
	add_child(preview)
	
func get_mouse_cell()->Vector2i:
	var mouse_position= lawn.to_local(get_global_mouse_position())
	return lawn.local_to_map(mouse_position)

func _input(event: InputEvent) -> void:
	#Press letter P to select a Peashooter
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		start_plant_preview(peashooter_scene)
	#Press the left click to place the plant
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			place_plant()

func place_plant() ->void:
	if preview ==null:
		return
	var cell:=get_mouse_cell()
	#Check if the cell is inside the lawn
	if cell.x<0 or cell.x>=lawn.COLS or cell.y<0 or cell.y>=lawn.ROWS:
		print("Cannot plant outside the lawn")
		return
	#Check if the cell is occupied
	if occupied_cells.has(cell):
		print("This cell is occupied")
		return
	#Place the plant
	preview.setup(cell,lawn)
	occupied_cells[cell]=true
	print("Plant placed at:", cell)
	#Remove the preview reference
	preview=null
	
