extends CharacterBody2D

# Define movement variables
var speed = ProjectSettings.get_setting_with_override("application/config/game/speed")

signal attack(_self)
signal enemy_death(_self)
signal play_sound(sound_resource, interrupt)

var LilDude = null
@onready var navigation_agent = $NavigationAgent2D
@onready var default_location = global_position

var GameScene = null
func FindGameScene(_node):
	if not _node:
		_node = get_node("/root")
	for child_node in _node.get_children():
		if "GameScene" in child_node.name:
			return child_node as GameSceneObj
		var recursive = FindGameScene(child_node)
		if recursive:
			return recursive
			
var navigation_ready = false
func _ready():
	await get_tree().process_frame
	GameScene = FindGameScene(null)
	self.enemy_death.connect(GameScene._on_Enemy_Death.bind())
	self.play_sound.connect(GameScene._on_Play_Sound.bind())
	speed *= GameScene.AlienSpeedMultiplier
	
	navigation_ready = true
	navigation_agent.set_navigation_map (get_world_2d().get_navigation_map())
	navigation_agent.set_target_position(default_location)
	$AnimationPlayer.play("Walk_Down")
	
	for N in GameScene.get_children():
		if "LilDude" in N.name:
			LilDude = N
			N.step.connect(_on_Player_step.bind())
			N.shook_free.connect(_on_Player_shook_free.bind())
			N.attacked.connect(_on_Player_attacked.bind())
			self.attack.connect(N._on_Player_bumped.bind())

func _physics_process(_delta):
	if not navigation_ready:
		return
	var current_agent_position: Vector2 = global_position
	if $VisibleOnScreenNotifier2D.is_on_screen():
		navigation_agent.set_target_position(LilDude.global_position)
	elif not $VisibleOnScreenNotifier2D.is_on_screen() or not LilDude:
		navigation_agent.set_target_position(default_location)

	if navigation_agent.is_navigation_finished ():
		var attack_vector = (LilDude.global_position - global_position)
		if $VisibleOnScreenNotifier2D.is_on_screen():
			if navigation_agent.get_target_position() == LilDude.global_position:
				if attack_vector.length() < speed:
					emit_signal("attack", self)
					return
				else:
					navigation_agent.set_target_position(default_location)
		var return_vector = (global_position - default_location)
		if not return_vector:
			return
		if return_vector.length() < speed or attack_vector.length() > 200:
			global_position = default_location
		return
		
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	velocity = speed * (next_path_position - current_agent_position).normalized()
	
	navigation_agent.set_velocity(velocity)
	
	if $VisibleOnScreenNotifier2D.is_on_screen():
		emit_signal("play_sound", "res://assets/Sounds/gross_alien.wav", false)
	if move_and_slide():
		var collision_count = get_slide_collision_count()
		# Loop through indexes up to collision_count
		for i in range(collision_count):
			# Access the collision at index i
			var collision = get_slide_collision(i)
			if LilDude == collision.get_collider():
				emit_signal("attack", self)
			else:
				var bump_vector = (collision.get_collider().global_position - global_position)
				var bump_direction = bump_vector.normalized()
				global_position -= bump_direction
				print(self, " Collided with: ", collision.get_collider().name)
			
		if (global_position - current_agent_position).length_squared() < 0.0001:
			navigation_agent.set_target_position(default_location)
			# get unstuck
			global_position += Vector2(
				RandomNumberGenerator.new().randf_range(-.5, .5),
				RandomNumberGenerator.new().randf_range(-.5, .5)
				)
	#print(self , $VisibleOnScreenNotifier2D.is_on_screen(), navigation_agent.get_target_position(), velocity)
	
var last_player_position = Vector2(0,0)
func _on_Player_step(player_position):
	if $VisibleOnScreenNotifier2D.is_on_screen():
		last_player_position = player_position
	
func _on_Player_shook_free(player_position, adjustment):
	if $VisibleOnScreenNotifier2D.is_on_screen():
		var offet_from_player = global_position - last_player_position
		global_position = offet_from_player + player_position + adjustment

var AlienSound = preload("res://assets/Sounds/gross_alien.wav")
var CorrectSound = preload("res://assets/Sounds/bumf.wav")
func _on_Player_attacked(attack_area2d: Area2D):
	if $VisibleOnScreenNotifier2D.is_on_screen():
		print(attack_area2d.overlaps_body (self), attack_area2d.get_overlapping_bodies())
		if self in attack_area2d.get_overlapping_bodies():
			emit_signal("play_sound", "res://assets/Sounds/bumf.wav", true)
			self.visible = false
			emit_signal("enemy_death")
			queue_free()
