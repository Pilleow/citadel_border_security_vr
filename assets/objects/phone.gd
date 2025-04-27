extends Node3D

var ringing := true
var ignore_first_enter_to_dock := true
var phone_not_docked_after_convo := true
@onready var phone_head : Pickup = $PhoneHead
@onready var phone_audio := $PhoneHead/AudioStreamPlayer3D

func _ready() -> void:
	SignalBus.alarm_activated.connect(_on_alarm_activated)

func _on_alarm_activated():
	$RingAudio.stop()
	phone_audio.stop()
	ringing = false

func update_dock_sfx():
	if phone_head._holder:
		$UndockAudio.play()
	else:
		$DockAudio.play()

func _on_docked_area_body_entered(body: Node3D) -> void:
	if ignore_first_enter_to_dock:
		ignore_first_enter_to_dock = false
		return
	if body == phone_head:
		call_deferred("update_dock_sfx")
		if ringing:
			phone_audio.call_deferred("play")
			$RingAudio.stop()
			ringing = false
		else:
			if phone_audio.playing:
				phone_audio.stop()
			if phone_not_docked_after_convo:
				phone_not_docked_after_convo = false
				SignalBus.phone_call_finished.emit()
