extends CharacterBody2D

# Define movement variables
var speed = ProjectSettings.get_setting_with_override("application/config/game/speed")
	# Adjust the movement speed as needed
var width = 0
var height = 0

var health = 300
var FlyAway = null
var Camera = null
var is_cutscene = false
var GameScene = null

# Read player input from D-pad
var input_vector = Vector2(0, 0)

signal shook_free(player_position)
signal step(player_position)
signal attacked(attack_area2d)
signal player_death()
signal player_escaped()
signal play_sound(sound_resource, interrupt)

func _ready():
	GameScene = $".."
	self.player_death.connect(GameScene._on_Player_Death.bind())
	self.player_escaped.connect(GameScene._on_Player_Escaped.bind())
	self.play_sound.connect(GameScene._on_Play_Sound.bind())
	GameScene.escape_begin.connect(_on_Player_Escape.bind())
	FlyAway = $UiHud.get_node("Control/EscapeDisplay")
	Camera = $UiHud
	
	$AnimationPlayer.play("Walk_Down")
	width = $CollisionShape2D.shape.size.x
	height = $CollisionShape2D.shape.size.y
	melee_attack_stop()

func melee_attack_stop():
	$Line2D.visible=false

var facing = 0
func _input(event):
	if is_cutscene: return
	if event is InputEventJoypadMotion: return
	if event is InputEventMouseMotion: return
	if event.is_echo(): return
	print("Input:", event, " ", input_vector)
	if event.is_pressed():
		melee_attack_stop()
		if event.is_action("ui_up"):
			input_vector.y -= 1
		if event.is_action("ui_down"):
			input_vector.y += 1
		if event.is_action("ui_left"):
			input_vector.x -= 1
		if event.is_action("ui_right"):
			input_vector.x += 1
		if event.is_action("GB_Button_A"):
			if facing == 0:
				$AnimationPlayer.play("Attack_Down")
				emit_signal("attacked", $AttackBoxes/AttackBoxDown)
			if facing == 1:
				$AnimationPlayer.play("Attack_Up")
				emit_signal("attacked", $AttackBoxes/AttackBoxUp)
			if facing == 2:
				$AnimationPlayer.play("Attack_Right")
				emit_signal("attacked", $AttackBoxes/AttackBoxRight)
			if facing == 3:
				$AnimationPlayer.play("Attack_Left")
				emit_signal("attacked", $AttackBoxes/AttackBoxLeft)
	if not event.is_pressed():
		if event.is_action("ui_up") or event.is_action("ui_down"):
			input_vector.y = 0
		if event.is_action("ui_left") or event.is_action("ui_right"):
			input_vector.x = 0
			

func _physics_process(_delta):
	$Sprite.modulate = Color(1,1,1,1)
	if is_cutscene: return
	
	# Normalize to ensure consistent speed in all directions
	# Calculate the character's velocity
	if abs(input_vector.x) > abs(input_vector.y) and input_vector.x > 0:
		if not facing == 2:
			$AnimationPlayer.play("Walk_Right")
		facing = 2
	if abs(input_vector.x) > abs(input_vector.y) and input_vector.x < 0:
		if not facing == 3:
			$AnimationPlayer.play("Walk_Left")
		facing = 3
	if abs(input_vector.x) <= abs(input_vector.y) and input_vector.y < 0:
		if not facing == 1:
			$AnimationPlayer.play("Walk_Up")
		facing = 1
	if abs(input_vector.x) <= abs(input_vector.y) and input_vector.y > 0:
		if not facing == 0:
			$AnimationPlayer.play("Walk_Down")
		facing = 0
	velocity = input_vector.normalized() * speed
	#input_vector = Vector2(0, 0)
	move_player()
	
	# Apply the velocity to move the character
func move_player():
	if velocity:
		var movement = velocity
		emit_signal("step", position)
		var collided = move_and_slide()
		
		if collided:
			# Get the number of slide collisions
			var collision_count = get_slide_collision_count()
			print("Collision!", collision_count)
			# Loop through indexes up to collision_count
			for i in range(collision_count):
				# Access the collision at index i
				var collision = get_slide_collision(i)
				print("Collided with: ", collision.get_collider().name)
				if not GameScene.SingleScreen:
					var adjustment = Vector2(0,0)
					if collision.get_collider() == $"../Bounds/TopBound":
						if movement.y < 0:
							position.y *= -1
							adjustment =  Vector2(0, -height)
					if collision.get_collider() == $"../Bounds/BottomBound":
						if movement.y > 0:
							position.y *= -1
							adjustment =  Vector2(0, height)
					if collision.get_collider() == $"../Bounds/LeftBound":
						if movement.x < 0:
							position.x *= -1
							adjustment =  Vector2(-width, 0)
					if collision.get_collider() == $"../Bounds/RightBound":
						if movement.x > 0:
							position.x *= -1
							adjustment =  Vector2(width, 0)
					if adjustment:
						emit_signal("shook_free", position, adjustment)
						position += adjustment
						return
				if "AlienDude" in collision.get_collider().name:
					_on_Player_bumped(collision.get_collider())

	# Play animations or other character-specific logic here

func _on_Player_bumped(body):
	var attack_vector = (body.global_position - global_position)
	var attack_direction = attack_vector.normalized()
	print(body, " attacked player! ", attack_vector.length())
	if attack_vector.length() > body.speed:
		print(body, " distance attacked player! ",  attack_vector.length_squared())
	var bounce_velocity = -100 * attack_direction
	global_position -= attack_direction
	velocity = bounce_velocity
	move_player()
	health -= 20
	emit_signal("play_sound", "res://assets/Sounds/dwah.wav", true)
	if health <= 0:
		emit_signal("player_death")
	$Sprite.modulate = Color(100,100,100,100)

func _on_attack_box_body_entered(_body):
	pass #print("Target:", body)

func _on_Player_Escape():
	print("Winner!")
	is_cutscene = true
	CutScene_Escape()
	
func CutScene_Escape():
	var CameraPos = Camera.global_position
	await get_tree().create_timer(.25).timeout
	emit_signal("play_sound", "res://assets/Sounds/preparing_for_launch.wav", true)
	$AnimationPlayer.play("Walk_Down")
	melee_attack_stop()
	await get_tree().create_timer(.5).timeout
	
	while global_position.y < FlyAway.global_position.y:
		await get_tree().create_timer(.1).timeout
		global_position.y += 4
		Camera.global_position = CameraPos
	$AnimationPlayer.play("Walk_Right")
	while global_position.x < FlyAway.global_position.x:
		await get_tree().create_timer(.1).timeout
		global_position.x += 5
		Camera.global_position = CameraPos
	$Sprite.visible = false
	emit_signal("play_sound", "res://assets/Sounds/rocket.wav", true)
	while FlyAway.rotation_degrees > -90:
		await get_tree().create_timer(.25).timeout
		FlyAway.rotation_degrees -= 5
	await get_tree().create_timer(.25).timeout
		
	while $"../Bounds/TopBound".transform.origin.y < FlyAway.global_position.y:
		await get_tree().create_timer(.05).timeout
		FlyAway.global_position.y -= 2
	emit_signal("player_escaped")
