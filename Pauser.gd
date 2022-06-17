extends Control

func _process(delta):
	if Input.is_action_just_pressed("ui_end"):
		get_tree().paused = !get_tree().paused
		$RichTextLabel.visible = !$RichTextLabel.visible
