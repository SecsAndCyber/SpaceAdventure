extends CharacterBody2D

# Define movement variables
var speed = ProjectSettings.get_setting_with_override("application/config/game/speed")
	# Adjust the movement speed as needed
var width = 0
var height = 0

# Read player input from D-pad
var input_vector = Vector2(0, 0)

func _ready():
	$AnimationPlayer.play("Walk_Down")
	width = $CollisionShape2D.shape.size.x
	height = $CollisionShape2D.shape.size.y

func _input(event):
	if event.is_pressed() or event.is_echo():
		if event.is_action("ui_up"):
			$AnimationPlayer.play("Walk_Up")
			input_vector.y -= 1
		if event.is_action("ui_down"):
			$AnimationPlayer.play("Walk_Down")
			input_vector.y += 1
		if event.is_action("ui_left"):
			$AnimationPlayer.play("Walk_Left")
			input_vector.x -= 1
		if event.is_action("ui_right"):
			$AnimationPlayer.play("Walk_Right")
			input_vector.x += 1
	
func _physics_process(delta):
	input_vector = input_vector.normalized()  # Normalize to ensure consistent speed in all directions

	# Calculate the character's velocity
	velocity = input_vector * speed
	input_vector = Vector2(0, 0)

	# Apply the velocity to move the character
	if velocity:
		var movement = velocity
		var collided = move_and_slide()
		
		if collided:
			print("Collision!")
			# Get the number of slide collisions
			var collision_count = get_slide_collision_count()
			# Loop through indexes up to collision_count
			for i in range(collision_count):
				# Access the collision at index i
				var collision = get_slide_collision(i)
				print("Collided with: ", collision.get_collider().name)
				
				if collision.get_collider() == $"../Bounds/TopBound":
					if movement.y < 0:
						position.y *= -1
						position.y -= height
				if collision.get_collider() == $"../Bounds/BottomBound":
					if movement.y > 0:
						position.y *= -1
						position.y += height
				if collision.get_collider() == $"../Bounds/LeftBound":
					if movement.x < 0:
						position.x *= -1
						position.x -= width
				if collision.get_collider() == $"../Bounds/RightBound":
					if movement.x > 0:
						position.x *= -1
						position.x += width

	# Play animations or other character-specific logic here
