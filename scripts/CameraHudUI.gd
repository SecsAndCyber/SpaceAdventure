extends RemoteTransform2D

var WorldMap = null
var PlayerObject = null
var LifeDisplay = null
var ProgressDisplay = null
var update = false

var resolution = Vector2(160,144)

var GameScene = null
func FindGameScene(_node):
	if not _node:
		_node = get_node("/root")
	for child_node in _node.get_children():
		if "GameScene" in child_node.name:
			return child_node
		var recursive = FindGameScene(child_node)
		if recursive:
			return recursive
			
# Called when the node enters the scene tree for the first time.
func _ready():
	# Scene References
	PlayerObject = $".."
	WorldMap = $"../../Viewable/WorldSpace"
	GameScene = FindGameScene(null)
	
	# Signal listeners
	GameScene.escape_progress.connect(_on_escape_progress.bind())
	
	LifeDisplay = $Control/HealthDisplay
	LifeDisplay.max_value = PlayerObject.health
	
	ProgressDisplay = $Control/EscapeDisplay
	ProgressDisplay.max_value = GameScene.EscapeCost
	
	var MapSize = WorldMap.texture.get_size ( )
	$Camera2D.limit_top = -((MapSize.y / 2) + resolution.y)
	$Camera2D.limit_bottom = (MapSize.y / 2) + resolution.y
	$Camera2D.limit_right = (MapSize.x / 2) + resolution.x
	$Camera2D.limit_left = -((MapSize.x / 2) + resolution.x)
	
	update = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not update: return
	LifeDisplay.set_value(PlayerObject.health)
	
func _on_escape_progress(escape_progress):
	ProgressDisplay.value = escape_progress
	
