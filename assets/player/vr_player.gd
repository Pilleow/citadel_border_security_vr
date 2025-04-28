class_name VRPlayer extends Node3D


## Emitted when the player has his or her head within a wall for 1.2 seconds.
signal bounds_escaped()

## Multiplier for how hard the player can throw a held [Pickup].
@export_range(0.0, 2.0, 0.05, "or_greater", "hide_slider") var impulse_multiplier := 0.2

var _left_grabbable: Grabbable = null
var _right_grabbable: Grabbable = null
var target_fade_alpha := 1.0

@onready var _body := $CharacterBody3D as CharacterBody3D
@onready var _left_controller := $CharacterBody3D/Origin/LeftController as VRController
@onready var _right_controller := $CharacterBody3D/Origin/RightController as VRController
@onready var _left_hand := $LeftHand as VRHand
@onready var _right_hand := $RightHand as VRHand
@onready var _left_glove := $LeftHand/VRGlove as VRGlove
@onready var _right_glove := $RightHand/VRGlove as VRGlove
@onready var _camera := $CharacterBody3D/Origin/Camera as XRCamera3D
@onready var _out_of_bounds_player := $OutOfBoundsPlayer as AnimationPlayer
@onready var fade_mesh := $CharacterBody3D/Origin/Camera/FadeMesh

func _ready():
	show()
	SignalBus.move_to_next_level.connect(_on_move_to_next_level)

func _on_move_to_next_level(path: String):
	target_fade_alpha = 0.0
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file(path)

func _process(delta: float) -> void:
	if fade_mesh.transparency != target_fade_alpha:
		fade_mesh.transparency = move_toward(
			fade_mesh.transparency,
			target_fade_alpha,
			delta
		)

## Position the player with their feet at [param global_position].
func position_feet(global_position: Vector3) -> void:
	var camera_offset := _camera.global_position - self.global_position
	_body.position.y = 0.0
	camera_offset.y = 0.0
	self.global_position = global_position - camera_offset


## Position the player with their head at [param global_position].
func position_head(global_position: Vector3) -> void:
	var camera_offset := _camera.global_position - global_position
	self.global_position = global_position - camera_offset


## Apply the given [param controller_settings] to this player.
func set_controller_settings(controller_settings: ControllerSettings) -> void:
	_set_hand_offset(controller_settings.hand_offset_position, controller_settings.hand_offset_rotation)
	_left_controller.pose = controller_settings.pose
	_right_controller.pose = controller_settings.pose


func _set_hand_offset(position: Vector3, rotation: Vector3) -> void:
	$RightHandAnchor.offset_position = position
	position.x = -position.x
	$LeftHandAnchor.offset_position = position
	_right_hand.offset_rotation = Basis.from_euler(rotation)
	rotation.y = -rotation.y
	rotation.z = -rotation.z
	_left_hand.offset_rotation = Basis.from_euler(rotation)
	

func _try_grab(tracker_hand: XRPositionalTracker.TrackerHand) -> void:
	var controller := _left_controller if tracker_hand == \
			XRPositionalTracker.TRACKER_HAND_LEFT else _right_controller
	var hand := _left_hand if tracker_hand == \
			XRPositionalTracker.TRACKER_HAND_LEFT else _right_hand
	var result: GrabResult = controller.try_grab(0.2)
	if result.grabbable != null:
		#print("grab\n" + str(controller) + "\n" + str(hand) + "\n" + str(result.grabbable) + "\n" + str(result.grab_point))
		hand.global_transform = result.grab_point.global_transform
		hand.translate_object_local(controller.grab_offset)
		result.grabbable.grab(hand)
		if tracker_hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_left_grabbable = result.grabbable
		else:
			_right_grabbable = result.grabbable


func _on_grab_left_action_pressed() -> void:
	_try_grab.call_deferred(XRPositionalTracker.TRACKER_HAND_LEFT)
	_left_glove.grip()


func _on_grab_left_action_released() -> void:
	if is_instance_valid(_left_grabbable):
		_left_grabbable.release(_left_hand.velocity * impulse_multiplier)
	_left_grabbable = null
	_left_glove.release()


func _on_grab_right_action_pressed() -> void:
	_try_grab.call_deferred(XRPositionalTracker.TRACKER_HAND_RIGHT)
	_right_glove.grip()


func _on_grab_right_action_released() -> void:
	if is_instance_valid(_right_grabbable):
		_right_grabbable.release(_right_hand.velocity * impulse_multiplier)
	_right_grabbable = null
	_right_glove.release()


func _on_bounds_check_body_entered(_body: Node) -> void:
	_out_of_bounds_player.play(&"out_of_bounds")


func _on_bounds_check_body_exited(_body: Node) -> void:
	_out_of_bounds_player.play(&"RESET")


func _on_out_of_bounds_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"out_of_bounds":
		bounds_escaped.emit()


func _on_controller_button_pressed(
	name: StringName,
	hand: XRPositionalTracker.TrackerHand
) -> void:
	if name == &"grab":
		if hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_on_grab_left_action_pressed()
		else:
			assert(hand == XRPositionalTracker.TRACKER_HAND_RIGHT)
			_on_grab_right_action_pressed()


func _on_controller_button_released(
	name: StringName,
	hand: XRPositionalTracker.TrackerHand
) -> void:
	if name == &"grab":
		if hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_on_grab_left_action_released()
		else:
			assert(hand == XRPositionalTracker.TRACKER_HAND_RIGHT)
			_on_grab_right_action_released()
