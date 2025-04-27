class_name PersonSchedule extends Resource

@export var person_character: Enum.PERSONCHARACTER = Enum.PERSONCHARACTER.COMPLIANT
@export var person_speaking_subfolder: Enum.PERSON_SPEAKING_SUBFOLDER = Enum.PERSON_SPEAKING_SUBFOLDER.MIKE_113
@export var correct_stamp: Enum.STAMPS = Enum.STAMPS.ACCEPTED

@export_group("Parameters")
@export var entry_card_full_name: String = ""
@export var entry_card_issue_date: Date = Date.new()
@export var medical_check_full_name: String = ""
@export var medical_check_status: Enum.MEDICAL_STATUS = Enum.MEDICAL_STATUS.CLEARED
@export var medical_check_stamp: Enum.MEDICAL_STAMPS = Enum.MEDICAL_STAMPS.NHD
@export var medical_check_screening_date: Date = Date.new()

@export_group("Materials")
@export_file("*.tres") var skin_material = "res://assets/meshes/person/skin_light.tres"
@export_file("*.tres") var shirt_material = "res://assets/meshes/person/shirt_green.tres"
@export_file("*.tres") var shorts_material = "res://assets/meshes/person/shorts_grey.tres"
@export_file("*.tres") var shoes_material = "res://assets/meshes/person/shoes_black.tres"

#func _init(
	#_skin_material:= "", _shirt_material:= "", _shorts_material:= "", _shoes_material:="",
	#_correct_stamp:=Enum.STAMPS.NONE, _person_character:=Enum.PERSONCHARACTER.COMPLIANT,
	#_person_speaking_subfolder:=Enum.PERSON_SPEAKING_SUBFOLDER.MIKE_113,
	#_medical_check_status:=Enum.MEDICAL_STATUS.CLEARED, _entry_card_full_name:="",
	#_medical_check_stamp:=Enum.MEDICAL_STAMPS.NHD, _medical_check_full_name:="",
	#):
	#skin_material = _skin_material
	#shirt_material = _shirt_material
	#shorts_material = _shorts_material
	#shoes_material = _shoes_material
	#correct_stamp = _correct_stamp
	#person_speaking_subfolder = _person_speaking_subfolder
	#medical_check_status = _medical_check_status
	#medical_check_stamp = _medical_check_stamp
	#entry_card_full_name= _entry_card_full_name
	#medical_check_full_name = _medical_check_full_name
