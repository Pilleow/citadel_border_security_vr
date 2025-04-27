extends Node3D

@onready var asp := $Object/AudioStreamPlayer3D

func _ready():
	SignalBus.alarm_activated.connect(_on_alarm_activated)

func _on_alarm_activated():
	asp.stop()
