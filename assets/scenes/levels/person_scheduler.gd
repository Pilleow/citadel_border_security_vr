class_name PersonScheduler extends Node3D

@export var person_schedule : Array[PersonSchedule]

var current_person_index = -1

func get_next_person():
	current_person_index += 1
	if current_person_index >= len(person_schedule):
		return null
	return person_schedule[current_person_index]
