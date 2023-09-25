class_name GameSceneObj extends "res://scripts/LoadableScene.gd"

@export var AlienSpeedMultiplier = 1.0
@export var NextLevel = "res://MenuScene.tscn"
@export var SingleScreen = false

@export var EscapeCost = 3
var EscapeProgress = 0
signal escape_progress(escape_progress)
signal escape_begin()
var parent_node = null

func _ready():
	parent_node = get_parent()
	$LilDude/UiHud.visible = true
	if SingleScreen:
		$LilDude/UiHud.FreezeCamera()
	else:
		var sprite_dimensions = Vector2($LilDude.width,$LilDude.height)
		$Bounds/TopBound.transform.origin.y -= sprite_dimensions.y
		$Bounds/BottomBound.transform.origin.y += sprite_dimensions.y
		$Bounds/LeftBound.transform.origin.x -= sprite_dimensions.x
		$Bounds/RightBound.transform.origin.x += sprite_dimensions.x
		
		var object = $Viewable/WorldSpace
		var duplication_size = object.texture.get_size ( )
		for i in [Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1),
				  Vector2(-1, 0),Vector2(0, 0),Vector2(1, 0),
				  Vector2(-1, 1),Vector2(0, 1),Vector2(1, 1)]:
			if i.x or i.y:
				var child = object.duplicate()
				object.add_child(child)
				child.transform.origin.x += i.x * duplication_size.x
				child.transform.origin.y += i.y * duplication_size.y

func _input(event):
	if event is InputEvent:
		# Handle key events
		if event.is_action_pressed("ui_cancel"):
			print("ui_cancel")
			get_tree().quit()

func _on_Play_Sound(sound_resource, interrupt):
	if not interrupt and $SfxStreamPlayer.is_playing(): return
	if not $SfxStreamPlayer.stream == load(sound_resource):
		$SfxStreamPlayer.stream = load(sound_resource)
		$SfxStreamPlayer.play()

func _on_Enemy_Death():
	EscapeProgress += 1
	emit_signal("escape_progress", EscapeProgress)
	if EscapeCost <= EscapeProgress:
		emit_signal("escape_begin")
		

func _on_Player_Death():
	$LilDude.visible = false
	$LilDude/UiHud.visible = true
	queue_free()
	parent_node.add_child(load("res://MenuScene.tscn").instantiate())
		

func _on_Player_Escaped():
	$LilDude.visible = false
	$LilDude/UiHud.visible = false
	name = "Unloading"
	queue_free()
	parent_node.add_child(load(NextLevel).instantiate())
