class_name Lawn
extends TileMapLayer
# This is a comment, testing git
const ROWS := 5
const COLS := 9

const SOURCE_LIGHT := 1
const SOURCE_DARK := 2
const TILE_COORDS := Vector2i(0, 1)

func _ready() -> void:
	generate_lawn()

func generate_lawn() -> void:
	for row in range(ROWS):
		for col in range(COLS):
			var src := SOURCE_LIGHT if (row + col) % 2 == 0 else SOURCE_DARK
			set_cell(Vector2i(col, row), src, TILE_COORDS)
