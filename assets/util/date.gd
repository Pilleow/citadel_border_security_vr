class_name Date extends Resource

@export var day: int = 1
@export var month: int = 1
@export var year: int = 1971

func _init(_day:=1, _month:=1, _year:=1971):
	day = _day
	month = _month
	year = _year
