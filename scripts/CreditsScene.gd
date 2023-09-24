extends Node2D

var parent_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_node = get_parent()

func activate_menu_selection():
	parent_node.add_child(load("res://MenuScene.tscn").instantiate())
	queue_free()
		
func _input(event):
	if not parent_node: return
	# ignoring echos lets the code behave the same
	# for keyboards and for controllers
	if event.is_echo(): return
	
	if event.is_pressed():
		if event.is_action("GB_Button_B") or \
			event.is_action("GB_Button_A"):
			activate_menu_selection()
			return
