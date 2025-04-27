extends Node3D

@export var stamp_type: Enum.STAMPS = Enum.STAMPS.NONE
@onready var stamp_sfx := $Pickup/AudioStreamPlayer3D

func _ready() -> void:
	match stamp_type:
		Enum.STAMPS.ACCEPTED:
			$Pickup/Accepted.show()
		Enum.STAMPS.DENIED:
			$Pickup/Denied.show()

func _on_stamp_area_area_entered(area: Area3D) -> void:
	var body = area.get_parent().get_parent()
	match stamp_type:
		Enum.STAMPS.ACCEPTED:
			if body.has_method("set_accept"):
				if body.set_accept():
					stamp_sfx.play()
		Enum.STAMPS.DENIED:
			if body.has_method("set_deny"):
				if body.set_deny():
					stamp_sfx.play()
