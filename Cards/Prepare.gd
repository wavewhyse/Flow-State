extends Card

class_name Prepare

func _init():
	visible = true

func _ready():
	pass

func play():
	combat_screen.gain_status()
