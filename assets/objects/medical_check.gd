class_name MedicalCheck extends Card

var status: Enum.MEDICAL_STATUS = Enum.MEDICAL_STATUS.NONE
var stamp: Enum.MEDICAL_STAMPS = Enum.MEDICAL_STAMPS.NONE

func _ready():
	super()

func set_stamp(to: Enum.MEDICAL_STAMPS):
	stamp = to
	$Pickup/CCCstamp.hide()
	$Pickup/NHDstamp.hide()
	$Pickup/MDTFstamp.hide()
	match stamp:
		Enum.MEDICAL_STAMPS.CCC:
			$Pickup/CCCstamp.show()
		Enum.MEDICAL_STAMPS.NHD:
			$Pickup/NHDstamp.show()
		Enum.MEDICAL_STAMPS.MDTF:
			$Pickup/MDTFstamp.show()
			
func set_medical_status(to: Enum.MEDICAL_STATUS):
	status = to
	$Pickup/MedicalCleared.hide()
	$Pickup/MedicalFlagged.hide()
	$Pickup/MedicalHazardous.hide()
	match status:
		Enum.MEDICAL_STATUS.CLEARED:
			$Pickup/MedicalCleared.show()
		Enum.MEDICAL_STATUS.FLAGGED:
			$Pickup/MedicalFlagged.show()
		Enum.MEDICAL_STATUS.HAZARDOUS:
			$Pickup/MedicalHazardous.show()

func set_details(fullname: String, date: Date):
	var id = randi_range(11111111, 99999999)
	assert(0 < date.day and date.day < 32, "Invalid day provided")
	assert(0 <  date.month and  date.month < 13, "Invalid month provided")
	var dformatted = str(date.day) + "/" + str( date.month) + "/" + str( date.year)
	$Pickup/NameText.text = "Name: " + fullname + "\nDate of Screening: " + dformatted + "\nScreening ID: 00" + str(id)

func _on_visibility_changed() -> void:
	super._on_visibility_changed()
