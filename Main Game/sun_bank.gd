extends Node

signal sun_changed(new_amount: int)

const STARTING_SUN = 50

var sun: int = STARTING_SUN:
	set(value):
		sun = maxi(value, 0)
		sun_changed.emit(sun)
		
func add(amount: int) -> void:
	sun += amount
	
func can_afford(cost: int) -> bool:
	return sun >= cost

func try_spend(cost : int) -> bool:
	if not can_afford(cost):
		return false
	sun -= cost
	return true
	
func reset() -> void:
	sun = STARTING_SUN
