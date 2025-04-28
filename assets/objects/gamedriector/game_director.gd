extends Node3D

@export_range(0.5, 5) var person_linear_speed := 2.0
@export_range(.5, 15) var person_angular_speed := 4.0
@export var correct_stamp: Enum.STAMPS = Enum.STAMPS.ACCEPTED
@export var person_character: Enum.PERSONCHARACTER = Enum.PERSONCHARACTER.COMPLIANT
@export_dir var person_speaking_parent_folder := "res://assets/sounds/person_speaking/"
@export var person_speaking_subfolder :String = "mike_p113/"
@export var next_level: String = "res://assets/scenes/levels/level_after_1.tscn"

@onready var monitor = get_tree().get_nodes_in_group("Monitor")[0] as Monitor
@onready var person :Person = $Person
@onready var entry_card : EntryCard = $EntryCard
@onready var medical_check : MedicalCheck = $MedicalCheck
@onready var person_start_position :Vector3= $Person.global_position
@onready var person_start_rotation :Vector3= $Person.global_rotation

var document_receiver_locked := true
var documents_given := 0
var person_speaking_now : AudioStreamPlayer3D = null
var person_animation_state :int = 0
var person_state: Enum.PERSONSTATES = Enum.PERSONSTATES.ON_START

var incorrect_stamped :int = 0
var total_stamped :int = 0

func _ready():
	assert(person_speaking_parent_folder.ends_with("/"), "person_speaking_parent_folder must end with /")
	assert(person_speaking_subfolder.ends_with("/"), "person_speaking_subfolder must end with /")
	SignalBus.phone_call_finished.connect(send_next_guy)
	person.load_all_sounds(person_speaking_parent_folder + person_speaking_subfolder)
	person.set_random_face()
	SignalBus.alarm_activated.connect(_on_alarm_activated)
	person.pitch = randf_range(0.8, 1.2)

func _on_alarm_activated():
	if person_character == Enum.PERSONCHARACTER.AGGRESSIVE:
		person_state = Enum.PERSONSTATES.DANGER
		person.play_sound(Enum.PERSON_SPEAKING_SFX.ON_ALARM_AGGRESSIVE)
	else:
		person_state = Enum.PERSONSTATES.INNOCENT
		person.play_sound(Enum.PERSON_SPEAKING_SFX.ON_ALARM_INNOCENT)

func get_money_amount():
	return 12 * total_stamped - 10 * incorrect_stamped

func wait_and_go_to_next_level(sec := 4.0):
	await get_tree().create_timer(sec).timeout
	SignalBus.move_to_next_level.emit(next_level)

func send_next_guy():
	var ps: PersonScheduler = $PersonScheduler
	var np: PersonSchedule = ps.get_next_person()
	if not np:
		monitor.add_text(
			"\nYou have completed your daily quota.\nYou have been awarded with $" 
			+ str(get_money_amount()) + "\nYour efficiency is " + str(0.1*int(1000*(1-float(incorrect_stamped) / float(total_stamped)))) 
			+ "%.\nCongratulations.\n"
		)
		wait_and_go_to_next_level.call_deferred()
		return # TODO end day and go to next level
	
	correct_stamp = np.correct_stamp
	person_character = np.person_character
	
	person_speaking_subfolder = Enum.get_speaking_subfolder(np.person_speaking_subfolder)
	person.set_skin_material(load(np.skin_material))
	person.set_shirt_material(load(np.shirt_material))
	person.pitch = randf_range(0.8, 1.2)
	person.set_random_face() # TODO incorporate faces into PersonSchedule
	#person.set_shorts_material(load(np.shorts_material))
	#person.set_shoes_material(load(np.shoes_material))
	
	medical_check.set_medical_status(np.medical_check_status)
	medical_check.set_stamp(np.medical_check_stamp)
	entry_card.set_details(np.entry_card_full_name, np.entry_card_issue_date)
	medical_check.set_details(np.medical_check_full_name, np.medical_check_screening_date)
	
	person.global_position = person_start_position
	person.global_rotation = person_start_rotation
	if person_state == Enum.PERSONSTATES.ON_START:
		person_animation_state = 0
		person_state = Enum.PERSONSTATES.APPROACHING_GLASS

func lock_document_receiver():
	document_receiver_locked = true

func unlock_document_receiver():
	document_receiver_locked = false

func present_documents():
	entry_card.reset()
	medical_check.reset()
	documents_given = 2

func handle_person_state(delta):
	match person_state:
		Enum.PERSONSTATES.APPROACHING_GLASS:
			match person_animation_state:
				0:
					person.global_position.x = max(0, person.global_position.x - delta * person_linear_speed)
					if person.global_position.x == 0: person_animation_state += 1
				1:
					person.rotation.y = min(0, person.rotation.y + delta * person_angular_speed)
					if person.rotation.y == 0: person_animation_state += 1
				2:
					person_speaking_now = person.play_sound(Enum.PERSON_SPEAKING_SFX.GREETING)
					person_animation_state += 1
				3:
					if person_speaking_now and not person_speaking_now.playing:
						person_animation_state += 1
						person_speaking_now = null
				4:
					present_documents()
					person_state = Enum.PERSONSTATES.ON_GLASS
		Enum.PERSONSTATES.ENTERING:
			match person_animation_state:
				0:
					person_speaking_now = person.play_sound(Enum.PERSON_SPEAKING_SFX.ON_ACCEPT)
					person_animation_state += 1
				1:
					if person_speaking_now and not person_speaking_now.playing:
						person_animation_state += 1
						person_speaking_now = null
				2:
					if person.rotation.y > 3.1: # when -PI goes to +PI due to rotation overflow
						person.rotation.y = -PI-0.001
					person.rotation.y = min(-PI/2, person.rotation.y + delta * person_angular_speed)
					if is_equal_approx(person.rotation.y, -PI/2): person_animation_state += 1
				3:
					person.global_position.x = max(-4, person.global_position.x - delta * person_linear_speed)
					if person.global_position.x == -4: person_animation_state += 1
				4:
					person_state = Enum.PERSONSTATES.ENTERED
					if not is_valid_stamp():
						monitor.add_text("\npermit specification void by gate personnel. record sent to supervisor.\n")
					person_animation_state += 1
		Enum.PERSONSTATES.LEAVING:
			match person_animation_state:
				0:
					person_speaking_now = person.play_sound(Enum.PERSON_SPEAKING_SFX.ON_DENY)
					person_animation_state += 1
				1:
					if person_speaking_now and not person_speaking_now.playing:
						person_animation_state += 1
						person_speaking_now = null
				2:
					person.rotation.y = max(PI/2, person.rotation.y - delta * person_angular_speed)
					if is_equal_approx(person.rotation.y, PI/2): person_animation_state += 1
				3:
					person.global_position.x = min(4, person.global_position.x + delta * person_linear_speed)
					if person.global_position.x == 4: person_animation_state += 1
				4:
					person_state = Enum.PERSONSTATES.LEFT
					if not is_valid_stamp():
						monitor.add_text("\npermit specification void by gate personnel. record sent to supervisor.\n")
					person_animation_state += 1

func _process(delta: float) -> void:
	handle_person_state(delta)
	if person_state == Enum.PERSONSTATES.LEFT or person_state == Enum.PERSONSTATES.ENTERED:
		person_state = Enum.PERSONSTATES.ON_START
		send_next_guy()

func is_valid_stamp():
	return entry_card.state == correct_stamp and correct_stamp != Enum.STAMPS.NONE

func _on_document_receiver_area_entered(area: Area3D) -> void:
	var item = area.get_parent().get_parent()
	var rgb = area.get_parent()
	if not person_state == Enum.PERSONSTATES.ON_GLASS or not (
		is_instance_of(rgb, Pickup) and rgb.freeze
	) or not (
		(is_instance_of(item, EntryCard) and entry_card.state != Enum.STAMPS.NONE) 
		or is_instance_of(item, MedicalCheck)
	):
		return
	item.hide()
	if documents_given > 0:
		documents_given -= 1
		if documents_given > 0:
			return

	if not is_valid_stamp():
		incorrect_stamped += 1
	total_stamped += 1
	if entry_card.state == Enum.STAMPS.ACCEPTED:
		person_animation_state = 0
		person_state = Enum.PERSONSTATES.ENTERING
	elif entry_card.state == Enum.STAMPS.DENIED:
		if person_character == Enum.PERSONCHARACTER.AGGRESSIVE:
			person_animation_state = 0
			person_state = Enum.PERSONSTATES.DANGER
		else:
			person_animation_state = 0
			person_state = Enum.PERSONSTATES.LEAVING
