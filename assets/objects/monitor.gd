class_name Monitor extends Node3D


@onready var label_final_text :String = $Label3D.text
@onready var label := $Label3D
@onready var sfx_clicks := $ClickSounds.get_children()

@export_range(0.02, 0.2) var typing_delay := 0.08
@export_range(1, 7) var type_at_once := 5

var num_of_newlines = 0

func _ready():
	label.text = ""
	SignalBus.phone_call_finished.connect(_on_call_finished)

func update_text():
	while len(label.text) < len(label_final_text):
		for i in type_at_once:
			label.text += label_final_text[len(label.text)]
			if label.text.ends_with("\n"):
				num_of_newlines += 1
				if num_of_newlines > 20:
					var new_lb_txt: Array = label.text.split("\n")
					var new_fn_txt: Array = label_final_text.split("\n")
					new_lb_txt.remove_at(0)
					new_fn_txt.remove_at(0)
					label.text = "\n".join(new_lb_txt)
					label_final_text = "\n".join(new_fn_txt)
					num_of_newlines -= 1
			if len(label.text) >= len(label_final_text): break
		sfx_clicks.pick_random().play()
		await get_tree().create_timer(typing_delay).timeout

func _on_call_finished():
	update_text()

func add_text(s: String):
	label_final_text += s
	update_text()

func change_text(to: String):
	label_final_text = to
	update_text()
