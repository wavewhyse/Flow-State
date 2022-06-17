extends Node2D
class_name CardSlot

var direction
var enabled
var held_card

func set_direction(setdir):
	direction = setdir

func fill(card_insert):
	if held_card != null:
		printerr("Tried to place a card where there already was one!", held_card)
	held_card = card_insert
	add_child(held_card)
	refresh()

func pop():
	var ret_val = held_card
	remove_child(held_card)
	held_card = null
	return ret_val

func activate():
	enabled = false
	$AnimationPlayer.play("flash")
	held_card.play()

func refresh():
	if (not enabled):
		enabled = true
		$AnimationPlayer.play("restore")
