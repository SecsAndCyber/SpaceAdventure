extends CollisionShape2D
	
func _draw():
	if ProjectSettings.get_setting_with_override("application/config/game/draw_colliders"):
		draw_collision_shape()

func draw_collision_shape():
	if shape is RectangleShape2D:
		draw_rect(shape.get_rect(), Color(0, 1, 0, 0.5))
