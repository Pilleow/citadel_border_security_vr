## A grabbable object that the player can pick up, carry, and potentially throw.
class_name Pickup extends Grabbable


## If [code]true[/code], the player can throw this object, else it always drops straight down when
## released.
@export var throwable := true
@export var reset_on_ground_fall := true
var initial_position := Vector3.ZERO

var pickupable := true
var _holder: Node3D = null
var _collision_shapes: Array[CollisionShape3D] = []
@onready var _original_parent := get_parent() as Node3D


func reset_to_initial_position():
	global_position = initial_position
	linear_velocity = Vector3.ZERO


func _ready():
	super()
	initial_position = global_position
	for current_child in get_children():
		if current_child is CollisionShape3D:
			_collision_shapes.append(current_child)

func _exit_tree():
	assert(_holder == null, name + " was removed from the tree while still being held")

func grab(by: PhysicsBody3D) -> void:
	if is_instance_valid(_holder) or not pickupable:
		return
	for csh in _collision_shapes:
		csh.disabled = true
	var asp_seek = -1
	var asp = get_node_or_null("AudioStreamPlayer3D")
	if asp and asp.playing:
		asp_seek = asp.get_playback_position()
	reparent(by)
	if asp_seek >= 0 and asp:
		asp.play(asp_seek)
	_holder = by
	print(get_parent())
	freeze = true


func release(impulse := Vector3.ZERO) -> void:
	_holder = null
	var asp_seek = -1
	var asp = get_node_or_null("AudioStreamPlayer3D")
	if asp and asp.playing:
		asp_seek = asp.get_playback_position()
	reparent(_original_parent)
	if asp_seek >= 0 and asp:
		asp.play(asp_seek)
	for csh in _collision_shapes:
		csh.disabled = false
	freeze = false
	if throwable:
		apply_central_impulse(impulse)
