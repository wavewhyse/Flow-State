extends Card

class_name Clear

func _init():
	visible = true

func _ready():
	pass

func play():
	combat_screen.deal_damage(2)
