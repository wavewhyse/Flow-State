extends Control

func _ready():
	add_user_signal("any_key")

func _input(event):
	if event is InputEventKey and event.pressed:
		emit_signal("any_key")
		visible = false
