extends Area2D

var shape = null
var true_parent = null

func _ready():
	shape = $CollisionPolygon2D
	var _node = get_parent()
	while not "global_position" in _node:
		_node = _node.get_parent()
	true_parent = _node
	
func _process(_delta):
	pass #transform.origin += true_parent.global_position

func _draw():
	if ProjectSettings.get_setting_with_override("application/config/game/draw_colliders"):
		draw_collision_shape()

func draw_collision_shape():
	if shape is CollisionPolygon2D:
		var colors = PackedColorArray([Color(0, 1, 0, 0.5)])
		draw_polygon(shape.polygon, colors)
