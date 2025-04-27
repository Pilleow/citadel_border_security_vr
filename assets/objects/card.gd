class_name Card extends Node3D

@onready var entry_card_initial_position := global_position
@onready var entry_card_initial_rotation := global_rotation_degrees

func _ready() -> void:
	assert(is_instance_valid(find_child("Pickup", false)), "Pickup not found on Card")
	hide()

func reset():
	set_card_pos(entry_card_initial_position)
	set_card_rot(entry_card_initial_rotation)
	show()

func set_card_pos(to: Vector3):
	$Pickup.global_position = to

func set_card_rot(to: Vector3):
	$Pickup.global_rotation_degrees = to

func set_pickupable(to: bool):
	$Pickup.pickupable = to

func _on_visibility_changed() -> void:
	set_pickupable(visible)
	$Pickup.freeze = not visible
