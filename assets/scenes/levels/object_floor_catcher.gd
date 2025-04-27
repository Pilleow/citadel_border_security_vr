extends Area3D

func _on_body_entered(body: Node3D) -> void:
	var opt = body.get("reset_on_ground_fall")
	var inpos = body.get("initial_position")
	if opt and inpos:
		body.reset_to_initial_position()
		
