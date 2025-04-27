class_name EntryCard extends Card

var state: Enum.STAMPS = Enum.STAMPS.NONE

func _ready() -> void:
	super()
	hide()

func reset():
	super.reset()
	set_none()

func set_accept():
	if state != Enum.STAMPS.NONE:
		return false
	state = Enum.STAMPS.ACCEPTED
	$Pickup/Accepted.show()
	return true

func set_none():
	state = Enum.STAMPS.NONE
	$Pickup/Accepted.hide()
	$Pickup/Denied.hide()

func set_deny():
	if state != Enum.STAMPS.NONE:
		return false
	state = Enum.STAMPS.DENIED
	$Pickup/Denied.show()
	return true

func set_details(fullname: String, date: Date):
	assert(0 < date.day and date.day < 32, "Invalid day provided")
	assert(0 <  date.month and  date.month < 13, "Invalid month provided")
	$Pickup/NameText.text = (
		"Name: " + fullname
		+ "\nDate of Issue: " + str(date.day) + "." + str( date.month) + "." + str( date.year) 
		+ "\nIssuing Authority: Citadel External Embassy" 
		+ "\nAuthorization Number: CXR0" + str(randi_range(11111111, 99999999))
)

func _on_visibility_changed() -> void:
	super._on_visibility_changed()
	$Pickup/StampArea.monitorable = visible
