extends Card

class_name Defend

func _init():
	visible = true

func _ready():
	pass

func play():
	combat_screen.add_block(2)
