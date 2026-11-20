class_name Lawn
extends TileMapLayer
# This is a comment, testing git
const ROWS := 5
const COLS := 9

const SOURCE_LIGHT := 1
const SOURCE_DARK := 2
const TILE_COORDS := Vector2i(0, 1)

# Tracks which grid cells currently have a plant
var occupied: Dictionary = {}  # Vector2i(col, row) -> true

func _ready() -> void:
	generate_lawn()

func generate_lawn() -> void:
	for row in range(ROWS):
		for col in range(COLS):
			var src := SOURCE_LIGHT if (row + col) % 2 == 0 else SOURCE_DARK
			set_cell(Vector2i(col, row), src, TILE_COORDS)

# --- Grid <-> World helpers ---

# Grid cell (col, row) -> world position of that cell's center
func grid_to_world(cell: Vector2i) -> Vector2:
	var local_pos := map_to_local(cell)
	return to_global(local_pos)

# World position (e.g. a mouse click) -> grid cell it falls in
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local_pos := to_local(world_pos)
	return local_to_map(local_pos)

# Is this cell inside the 5x9 playable lawn?
func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < COLS and cell.y >= 0 and cell.y < ROWS

# --- Occupancy tracking ---

func is_occupied(cell: Vector2i) -> bool:
	return occupied.has(cell)

func set_occupied(cell: Vector2i, value: bool) -> void:
	if value:
		occupied[cell] = true
	else:
		occupied.erase(cell)
