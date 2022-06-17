extends Node2D

onready var combat_screen = $"/root/CombatScreen"
var beat_num = 1

func beat():
	$hihat.stop()
	$drum.stop()
	match beat_num:
		2:
			$ColorRect2.visible = false
			$ColorRect3.visible = false
			$ColorRect4.visible = false
			beat_num = beat_num + 1
			#$hihat.play()
			$AnimationPlayer.play("bg_flash")
		3:
			$ColorRect2.visible = true
			beat_num = beat_num + 1
			#$hihat.play()
			$AnimationPlayer.play("bg_flash")
		4:
			$ColorRect3.visible = true
			beat_num = 1
			#$hihat.play()
			$AnimationPlayer.play("bg_flash")
		1:
			combat_screen.end_turn()
			$ColorRect4.visible = true
			beat_num = beat_num + 1
			#$drum.play()
			$AnimationPlayer.play("bg_bigflash")
	
