extends Control

func _ready():
	add_user_signal("any_key")

func _input(event):
	if visible and event is InputEventKey and event.pressed:
		emit_signal("any_key")
		$AnimationPlayer.play("fade")
		yield($AnimationPlayer,"animation_finished")
		visible = false
