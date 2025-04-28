class_name Person extends Node3D

var greeting_sfx = []
var on_accept_sfx = []
var on_deny_sfx = []
var on_alarm_aggressive_sfx = []
var on_alarm_innocent_sfx = []
var on_forgot_to_give_sfx = []
var on_missing_document_sfx = []
var pitch := 1.0

@onready var faces_node := $Model/Armature/Skeleton3D/head/head/Faces

func load_all_sounds(person_sfx_directory):
	greeting_sfx = load_audio_from_path(person_sfx_directory + "greeting/")
	on_accept_sfx = load_audio_from_path(person_sfx_directory + "on_accept/")
	on_deny_sfx = load_audio_from_path(person_sfx_directory + "on_deny/")
	on_alarm_innocent_sfx = load_audio_from_path(person_sfx_directory + "on_alarm_innocent/")
	on_forgot_to_give_sfx = load_audio_from_path(person_sfx_directory + "on_forgot_to_give/")
	on_alarm_aggressive_sfx = load_audio_from_path(person_sfx_directory + "on_alarm_aggressive/")
	on_missing_document_sfx = load_audio_from_path(person_sfx_directory + "on_missing_document/")

func play_sound(family: Enum.PERSON_SPEAKING_SFX) -> AudioStreamPlayer3D:
	var sfx = null
	match family:
		Enum.PERSON_SPEAKING_SFX.GREETING:
			sfx = greeting_sfx.pick_random()
		Enum.PERSON_SPEAKING_SFX.ON_ACCEPT:
			sfx = on_accept_sfx.pick_random()
		Enum.PERSON_SPEAKING_SFX.ON_DENY:
			sfx = on_deny_sfx.pick_random()
		Enum.PERSON_SPEAKING_SFX.ON_ALARM_INNOCENT:
			sfx = on_alarm_innocent_sfx.pick_random()
		Enum.PERSON_SPEAKING_SFX.ON_FORGOT_TO_GIVE:
			sfx = on_forgot_to_give_sfx.pick_random()
		Enum.PERSON_SPEAKING_SFX.ON_ALARM_AGGRESSIVE:
			sfx = on_alarm_aggressive_sfx.pick_random()
		Enum.PERSON_SPEAKING_SFX.ON_MISSING_DOCUMENT:
			sfx = on_missing_document_sfx.pick_random()
	if sfx:
		(sfx as AudioStreamPlayer3D).pitch_scale = pitch
		sfx.play()
	return sfx

func set_random_face():
	var fch = faces_node.get_children()
	for f in fch:
		f.hide()
	fch.pick_random().show()

func set_face(to: Enum.PERSON_FACE):
	for f in faces_node.get_children():
		f.hide()
	match to:
		Enum.PERSON_FACE.MALE_1:
			$Model/Armature/Skeleton3D/head/head/Male1.show()
		Enum.PERSON_FACE.MALE_2:
			$Model/Armature/Skeleton3D/head/head/Male2.show()
		Enum.PERSON_FACE.MALE_3:
			$Model/Armature/Skeleton3D/head/head/Male3.show()
		Enum.PERSON_FACE.MALE_4:
			$Model/Armature/Skeleton3D/head/head/Male4.show()
		Enum.PERSON_FACE.MALE_5:
			$Model/Armature/Skeleton3D/head/head/Male5.show()
			
			
func set_random_anim_time():
	$Model/AnimationPlayer.play("standing")
	$Model/AnimationPlayer.seek(randf_range(0, $Model/AnimationPlayer.current_animation_length))

func set_skin_material(mat: StandardMaterial3D):
	$Model/Armature/Skeleton3D/neck/neck.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/head/head.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/elbow_l/elbow_l.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/lower_arm_l/lower_arm_l.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/elbow_r/elbow_r.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/lower_arm_r/lower_arm_r.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/knee_l/knee_l.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/lower_leg_l/lower_leg_l.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/knee_r/knee_r.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/lower_leg_r/lower_leg_r.set_surface_override_material(0, mat)

func set_shirt_material(mat: StandardMaterial3D):
	$Model/Armature/Skeleton3D/pelvis/pelvis.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/abdomen/abdomen.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/torso_upper/torso_upper.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/shoulder_l/shoulder_l.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/shoulder_r/shoulder_r.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/upper_arm_l/upper_arm_l.set_surface_override_material(0, mat)
	$Model/Armature/Skeleton3D/upper_arm_r/upper_arm_r.set_surface_override_material(0, mat)
	
func load_audio_from_path(dir_pa, v_db = 0, named=false):
	var dir = DirAccess.open(dir_pa)
	var out = []
	if named:
		out = {}
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			file_name = file_name.replace(".import", "")
			if not dir.current_is_dir() and (file_name.ends_with(".ogg") or file_name.ends_with(".wav") or file_name.ends_with(".mp3")):
				var stream = load(dir_pa + file_name)
				if stream:
					var asp = AudioStreamPlayer3D.new()
					asp.volume_db = v_db
					asp.stream = stream
					if named:
						out[file_name] = asp
					else:
						out.append(asp)
					add_child(asp)
			file_name = dir.get_next()
		dir.list_dir_end()
	return out
