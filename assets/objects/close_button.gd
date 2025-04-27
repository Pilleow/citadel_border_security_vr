extends Node3D

@onready var btn := $ButtonBase/Button
@export var door_y_offset := 0.0
@export var glass_door_y_offset := 0.0

var activated := false
var alarm_start := -1.0
var ensured_shut_door_sfx_played := false

func _ready() -> void:
	show()
	$Shutter2M1.position.y = global_position.y + 2 + door_y_offset
	$Shutter2M2.position.y = global_position.y + 2 + door_y_offset
	$Shutter2M3.position.y = global_position.y + 1.01 + glass_door_y_offset
	SignalBus.alarm_activated.connect(_on_alarm_activated)

func _on_alarm_activated():
	alarm_start = Time.get_ticks_msec()
	$Shutter2M1/Rattling.play()
	$AlarmSiren/Siren/SpotLight3D.show()
	$AlarmSiren2/Siren/SpotLight3D.show()
	$AlarmSiren/Alarm.play()

func activate_close():
	$ButtonBase/ButtonSFX.play()
	btn.freeze = true
	btn.position.y = -0.025
	await $ButtonBase/ButtonSFX.finished
	SignalBus.alarm_activated.emit()

func _process(delta: float) -> void:
	if alarm_start > 0:
		var door_t = (Time.get_ticks_msec() - alarm_start) / 1000.0
		if door_t < 1.1:
			door_t *= door_t
			$Shutter2M1.position.y = max(door_y_offset, 2 - door_t * 2 + door_y_offset)
			if $Shutter2M1.position.y <= door_y_offset:
				$Shutter2M1.position.y = door_y_offset
				$Shutter2M1/Rattling.stop()
				if not $Shutter2M1/Shut.playing:
					$Shutter2M1/Shut.play()
			if door_t > 0.1 and not $Shutter2M2/Rattling.playing:
				$Shutter2M2/Rattling.play()
			$Shutter2M2.position.y = max(door_y_offset, 2 - door_t * 2 + 0.2 + door_y_offset)
			$Shutter2M3.position.y = max(glass_door_y_offset, 1 - door_t + 0.05 + glass_door_y_offset)
		elif not ensured_shut_door_sfx_played:
			ensured_shut_door_sfx_played = true
			$Shutter2M1/Rattling.stop()
			if not $Shutter2M1/Shut.playing:
				$Shutter2M1/Shut.play()
			$Shutter2M2/Rattling.stop()
			if not $Shutter2M2/Shut.playing:
				$Shutter2M2/Shut.play()
			$Shutter2M1.position.y = door_y_offset
			$Shutter2M2.position.y = door_y_offset
			$Shutter2M3.position.y = glass_door_y_offset
		$AlarmSiren/Siren/SpotLight3D.rotate_y(delta*7)
		$AlarmSiren2/Siren/SpotLight3D.rotate_y(delta*4.5)
	var y = btn.position.y
	if y >= 0:
		btn.linear_velocity = Vector3.ZERO
		btn.constant_force.y = 0
		if y > 0:
			btn.position.y = 0
	elif y < -0.025:
		if not activated:
			activated = true
			activate_close()
	else:
		btn.constant_force.y = 0.1
