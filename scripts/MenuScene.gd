extends Node2D

signal menu_selection_changed()

var menu_index = 0
var menu_items = []

var parent_node = null
var next_level_resource = preload("res://GameScene.tscn")
var credits_resource = preload("res://CreditsScene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_node = get_parent()
	self.menu_selection_changed.connect(OnMenuSelectionChanged.bind())
	
	menu_items = [$Buttons/Control/Button, $Buttons/Control2/Button2]
	menu_items[menu_index].grab_focus()

func change_menu_selection(index_offset):
	menu_index = (menu_index + index_offset) % len(menu_items)
	emit_signal("menu_selection_changed")
	
func activate_menu_selection():
	if menu_items[menu_index] == $Buttons/Control/Button:
		parent_node.add_child(next_level_resource.instantiate())
		queue_free()
	elif menu_items[menu_index] == $Buttons/Control2/Button2:
		parent_node.add_child(credits_resource.instantiate())
		queue_free()		

func OnMenuSelectionChanged():
	menu_items[menu_index].grab_focus()

func _input(event):
	# ignoring echos lets the code behave the same
	# for keyboards and for controllers
	if event.is_echo(): return
	
	if event.is_pressed():
		if event.is_action("ui_up"):
			change_menu_selection(1)
			return
		if event.is_action("ui_down"):
			change_menu_selection(-1)
			return
		if event.is_action("GB_Button_B") or \
			event.is_action("GB_Button_A"):
			activate_menu_selection()
			return
		if event.is_action_pressed("ui_cancel"):
			print("ui_cancel")
			get_tree().quit()
			return
			
