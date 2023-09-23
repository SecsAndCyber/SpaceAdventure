extends Node

var static_bodies = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node is StaticBody2D:
			static_bodies.append(node)
	
	
	for sb in static_bodies:
		sb.transform.origin += get_node("..").global_position
