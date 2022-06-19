extends Node2D

export(float) var input_buffer
export(PackedScene) var UI_damage
export(PackedScene) var UI_block
export(PackedScene) var UI_boost
export(int) var bpm

var beat_num
var multiplier = 1
var next_multiplier = 1
var block = 0
var action_direction
var active_turn = false

var deck = []
var discard = []

func _ready():
	set_process(false)
	$Timer.wait_time = 60.0 / bpm
	randomize()
	add_user_signal("newturn")
	$Intro.visible = true
	yield($Intro, "any_key")
	$MusicDelay.start()
	$DelayTimer.start()
	$CurrentHand/UpSlot.set_direction("ui_up")
	$CurrentHand/LeftSlot.set_direction("ui_left")
	$CurrentHand/RightSlot.set_direction("ui_right")
	$CurrentHand/DownSlot.set_direction("ui_down")
	
	for c in [
		"Clear",   "Clear",   "Clear",   "Clear",
		"Defend",  "Defend",  "Defend",  "Defend",
		"Prepare", "Prepare",
		"Rest"
	]:
		deck.append(get_card(c))
	deck.shuffle()
	
	for s in $NextHand.get_children():
		s.fill(deck.pop_front())
	for i in range(randi()%2 + randi()%2 + randi()%2):
		var new_dmg = UI_damage.instance()
		$NextDamageDisplay.add_child(new_dmg)
		new_dmg.position.y = i * 64
	new_turn()
	discard.clear()
	yield($DelayTimer,"timeout")
	set_process(true)

func start_timer():
	$Timer.start()

func start_music():
	$Music.play()

func _process(delta):
	if (check_input() and action_direction == null):
		if (Input.is_action_just_pressed("ui_up") and $CurrentHand/UpSlot.enabled):
			action_direction = "up"
			activate_slot($CurrentHand/UpSlot)
		elif (Input.is_action_just_pressed("ui_left") and $CurrentHand/LeftSlot.enabled):
			action_direction = "left"
			activate_slot($CurrentHand/LeftSlot)
		elif (Input.is_action_just_pressed("ui_right") and $CurrentHand/RightSlot.enabled):
			action_direction = "right"
			activate_slot($CurrentHand/RightSlot)
		elif (Input.is_action_just_pressed("ui_down") and $CurrentHand/DownSlot.enabled):
			action_direction = "down"
			activate_slot($CurrentHand/DownSlot)
	if (check_beat_reset(delta)):
		action_direction = null
		if($RhythmManager.beat_num == 2):
			emit_signal("newturn")

func is_final_beat():
	return (($Timer.time_left < input_buffer                   and $RhythmManager.beat_num == 1)
		or ($Timer.time_left > $Timer.wait_time - input_buffer and $RhythmManager.beat_num == 2))

func activate_slot(slot):
	if not active_turn:
		for d in $DamageDisplay.get_children():
			d.activate()
	active_turn = true
	while (multiplier > 0):
		slot.activate()
		if is_final_beat():
			slot.activate()
		multiplier -= 1
	multiplier = 1
	for b in $BoostDisplay.get_children():
		b.queue_free()
	for i in range(next_multiplier-1):
		var bst = UI_boost.instance()
		$BoostDisplay.add_child(bst)
		bst.position.y = i * -64 - 64
		multiplier += 1
	next_multiplier = 1

func get_card(card_name):
	return load("res://Cards/" + card_name + ".tscn").instance()

func check_input():
	return $Timer.time_left < input_buffer or $Timer.time_left > $Timer.wait_time - input_buffer

func check_beat_reset(delta):
	return $Timer.time_left < $Timer.wait_time - input_buffer and $Timer.time_left > $Timer.wait_time - input_buffer - delta

func deal_damage(dmg):
	$hitsound.stop()
	if is_final_beat():
		$bighitsound.play()
	else:
		$hitsound.play()
	$EnemyHP.value -= dmg
	
	#$perlin.modulate.a = 1.0 * $EnemyHP.value / $EnemyHP.max_value

func add_block(blk):
	$blocksound.stop()
	if is_final_beat():
		$bigblocksound.play()
	else:
		$blocksound.play()
	for _i in range(1, blk):
		var new_block = UI_block.instance()
		$BlockDisplay.add_child(new_block)
		#new_block.margin_left = block%4 * 64
		new_block.position.y = block * 64
		block += 1

func gain_status():
	$boostsound.stop()
	if is_final_beat():
		$bigboostsound.play()
	else:
		$boostsound.play()
	next_multiplier += 1

func rest():
	$restsound.stop()
	$restsound.play()

func end_turn():
	yield(self, "newturn")
	if active_turn:
		new_turn()

func new_turn():
	for c in $CurrentHand.get_children():
		discard.append(c.held_card)
	for i in range(4):
		#$PreviousHand.get_children()[i].pop()
		#$PreviousHand.get_children()[i].fill($CurrentHand.get_children()[i].pop())
		$CurrentHand.get_children()[i].pop()
		$CurrentHand.get_children()[i].fill($NextHand.get_children()[i].pop())
		if deck.empty():
			discard.shuffle()
			while discard.size() > 0:
				deck.append(discard.pop_front())
		$NextHand.get_children()[i].fill(deck.pop_front())
	
	for d in $PreviousDamageDisplay.get_children():
		$PreviousDamageDisplay.remove_child(d)
	for d in $DamageDisplay.get_children():
		$DamageDisplay.remove_child(d)
		$PreviousDamageDisplay.add_child(d)
		if (block > 0):
			block -= 1
		else:
			$damagesound.play()
			$PlayerHP.value -= 1
	#$Path.modulate.a = 1.0 * $PlayerHP.value / $PlayerHP.max_value
	for d in $NextDamageDisplay.get_children():
		$NextDamageDisplay.remove_child(d)
		$DamageDisplay.add_child(d)
	for i in range(randi()%2 + randi()%2 + randi()%2):
		var new_dmg = UI_damage.instance()
		$NextDamageDisplay.add_child(new_dmg)
		new_dmg.position.y = i * 64
		
	$AnimationPlayer.play("turn_transition")
	$Viewport/Combat3dPath/AnimationPlayer.play("next turn")
	
	for b in $BlockDisplay.get_children():
		b.queue_free()
	block = 0
	
	active_turn = false
