extends Node2D

@export var lawn: Lawn
@export var peashooter_scene: PackedScene
@export var sunflower_scene: PackedScene
@export var icebergpult_scene:PackedScene

const PEASHOOTER_COST:=100
const SUNFLOWER_COST:=50
const PEASHOOTER_COOLDOWN:=2.0
const SUNFLOWER_COOLDOWN:=2.0
const ICEBERGPULT_COST:=175
const ICEBERGPULT_COOLDOWN:=3.0

var peashooter_cooldown_timer: float=0.0
var sunflower_cooldown_timer: float=0.0
var icebergpult_cooldown_timer:float=0.0
var selected_plant_cost: int=0

@onready var peashooter_button: Button=get_node("../UI/UIContainer/PlantPanel/HBoxContainer/PeashooterButton")
@onready var sunflower_button: Button = get_node("../UI/UIContainer/PlantPanel/HBoxContainer/SunflowerButton")
@onready var icebergpult_button: Button = get_node("../UI/UIContainer/PlantPanel/HBoxContainer/IcebergpultButton")

var occupied_cells: Dictionary = {}
var preview: Node2D=null


func _ready() -> void:
	if lawn ==null:
		push_error("PlantPlacement: Lawn has not been assigned.")
	else:
		print("PlantPlacement: Lawn connected successfully.")
		print("Grid size: ", lawn.COLS, " columns x ", lawn.ROWS, " rows.")
	
	peashooter_button.text="☀ 100"
	sunflower_button.text = "☀ 50"
	icebergpult_button.text = "☀ 175"
	
	peashooter_button.pressed.connect(_on_peashooter_button_pressed)
	sunflower_button.pressed.connect(_on_sunflower_button_pressed)
	icebergpult_button.pressed.connect(_on_icebergpult_button_pressed)
	
func _on_peashooter_button_pressed()->void:
	if peashooter_cooldown_timer>0:
		return
	selected_plant_cost=PEASHOOTER_COST
	start_plant_preview(peashooter_scene)
	
func _on_sunflower_button_pressed()->void:
	if sunflower_cooldown_timer>0:
		return
	selected_plant_cost=SUNFLOWER_COST
	start_plant_preview(sunflower_scene)

func _on_icebergpult_button_pressed()->void:
	if icebergpult_cooldown_timer > 0:
		return
	selected_plant_cost = ICEBERGPULT_COST
	start_plant_preview(icebergpult_scene)




func _process(delta: float) -> void:
	#Update Peashooter cooldown timer
	if peashooter_cooldown_timer>0:
		peashooter_cooldown_timer=maxf(0.0, peashooter_cooldown_timer-delta)
	#Update Sunflower cooldown timer
	if sunflower_cooldown_timer>0:
		sunflower_cooldown_timer=maxf(0.0,sunflower_cooldown_timer-delta)
	#Update Icebergpult cooldown timer
	if icebergpult_cooldown_timer>0:
		icebergpult_cooldown_timer=maxf(0.0,icebergpult_cooldown_timer-delta)
	
	#Update Peashooter button
	if peashooter_cooldown_timer>0:
		peashooter_button.disabled=true
		peashooter_button.modulate=Color(0.5,0.5,0.5,1.0)
		peashooter_button.text = "☀ 100\n" + str(ceili(peashooter_cooldown_timer))
	elif not SunBank.can_afford(PEASHOOTER_COST):
		peashooter_button.disabled=true
		peashooter_button.modulate=Color(0.5,0.5,0.5,1.0)
		peashooter_button.text="☀ 100"
	else:
		peashooter_button.disabled=false
		peashooter_button.modulate=Color.WHITE
		peashooter_button.text="☀ 100"
	
	#Update Sunflower button
	if sunflower_cooldown_timer>0:
		sunflower_button.disabled=true
		sunflower_button.modulate=Color(0.5,0.5,0.5,1.0)
		sunflower_button.text="☀ 50\n" +str(ceili(sunflower_cooldown_timer))
	elif not SunBank.can_afford(SUNFLOWER_COST):
		sunflower_button.disabled=true
		sunflower_button.modulate=Color(0.5,0.5,0.5,1.0)
		sunflower_button.text="☀ 50"
	else:
		sunflower_button.disabled=false
		sunflower_button.modulate=Color.WHITE
		sunflower_button.text="☀ 50"
	
	#Update Icebergpult button
	if icebergpult_cooldown_timer>0:
		icebergpult_button.disabled=true
		icebergpult_button.modulate=Color(0.5, 0.5, 0.5, 1.0)
		icebergpult_button.text="☀ 175\n" + str(ceili(icebergpult_cooldown_timer))
	elif not SunBank.can_afford(ICEBERGPULT_COST):
		icebergpult_button.disabled=true
		icebergpult_button.modulate=Color(0.5, 0.5, 0.5, 1.0)
		icebergpult_button.text="☀ 175"
	else:
		icebergpult_button.disabled=false
		icebergpult_button.modulate=Color.WHITE
		icebergpult_button.text="☀ 175"
	
	
	#Update plant preview
	if preview != null:
		var cell:=get_mouse_cell()
		var cell_position=lawn.to_global(lawn.map_to_local(cell))
		preview.global_position = cell_position
		if can_place_plant(cell):
			preview.modulate=Color(0.4,1.0,0.4,0.5)
		else:
			preview.modulate=Color(1.0,0.3,0.3,0.5)

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
	
func can_place_plant(cell:Vector2i)->bool:
	if cell.x<0 or cell.x >=lawn.COLS:
		return false
	if cell.y<0 or cell.y >=lawn.ROWS:
		return false
	if occupied_cells.has(cell):
		return false
	if not SunBank.can_afford(selected_plant_cost):
		return false
	return true

func _input(event: InputEvent) -> void:
	if preview==null:
		return
	#Cancel with right mouse button
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_plant_preview()
			return
		#Place with left mouse button
		if event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			place_plant()
	# Cancel with ESC
	if event is InputEventKey:
		if event.keycode== KEY_ESCAPE and event.pressed and not event.echo:
			cancel_plant_preview()
func cancel_plant_preview()->void:
	if preview !=null:
		preview.queue_free()
		preview=null
	selected_plant_cost=0
	print("Plant selection cancelled")
	
	
	
func place_plant() ->void:
	if preview ==null:
		return
	var cell:=get_mouse_cell()
	if not can_place_plant(cell):
		print("Cannot place plant here")
		return
	#Spend the sun
	if not SunBank.try_spend(selected_plant_cost):
		return
	#Start the corresponding cooldown
	if selected_plant_cost==PEASHOOTER_COST:
		peashooter_cooldown_timer=PEASHOOTER_COOLDOWN
	elif selected_plant_cost==SUNFLOWER_COST:
		sunflower_cooldown_timer=SUNFLOWER_COOLDOWN
	elif selected_plant_cost==ICEBERGPULT_COST:
		icebergpult_cooldown_timer=ICEBERGPULT_COOLDOWN
	#Place the plant
	if preview.has_method("setup"):
		preview.setup(cell,lawn)
	occupied_cells[cell]=true
	
	#Restore normal appearance after placement
	preview.modulate=Color.WHITE
	
	print("Plant placed at:", cell)
	
	#Remove the preview reference
	preview=null
	selected_plant_cost=0
	
