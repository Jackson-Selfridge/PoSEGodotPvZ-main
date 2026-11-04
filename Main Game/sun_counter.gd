extends PanelContainer

@onready var sun_label: Label = $SunLabel

func _ready() -> void:
	SunBank.sun_changed.connect(_on_sun_changed)
	_on_sun_changed(SunBank.sun)

func _on_sun_changed(new_amount: int) -> void:
	sun_label.text = "☀ " + str(new_amount)
