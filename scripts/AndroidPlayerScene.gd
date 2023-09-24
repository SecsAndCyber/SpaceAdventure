extends Node2D

var ButtonState = {
	'JOY_BUTTON_B' : 0,
	'JOY_BUTTON_A' : 0,
	'JOY_BUTTON_DPAD_UP' : 0,
	'JOY_BUTTON_DPAD_DOWN' : 0,
	'JOY_BUTTON_DPAD_RIGHT' : 0,
	'JOY_BUTTON_DPAD_LEFT' : 0,
	'JOY_BUTTON_START' : 0,
	'JOY_BUTTON_BACK' : 0,
}
var process_input = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport = $ScreenDisplayLocation/SubViewportContainer/SubViewport
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	process_input = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not process_input: return
	if $TouchScreenButtonB.is_pressed():
		if not ButtonState['JOY_BUTTON_B']:
			ButtonState['JOY_BUTTON_B'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "GB_Button_B"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_B']:
		ButtonState['JOY_BUTTON_B'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "GB_Button_B"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)

	if $TouchScreenButtonA.is_pressed():
		if not ButtonState['JOY_BUTTON_A']:
			ButtonState['JOY_BUTTON_A'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "GB_Button_A"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_A']:
		ButtonState['JOY_BUTTON_A'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "GB_Button_A"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)

	if $TouchScreenButtonUP.is_pressed():
		if not ButtonState['JOY_BUTTON_DPAD_UP']:
			ButtonState['JOY_BUTTON_DPAD_UP'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "ui_up"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_DPAD_UP']:
		ButtonState['JOY_BUTTON_DPAD_UP'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "ui_up"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)
		
	if $TouchScreenButtonDOWN.is_pressed():
		if not ButtonState['JOY_BUTTON_DPAD_DOWN']:
			ButtonState['JOY_BUTTON_DPAD_DOWN'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "ui_down"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_DPAD_DOWN']:
		ButtonState['JOY_BUTTON_DPAD_DOWN'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "ui_down"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)

	if $TouchScreenButtonRIGHT.is_pressed():
		if not ButtonState['JOY_BUTTON_DPAD_RIGHT']:
			ButtonState['JOY_BUTTON_DPAD_RIGHT'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "ui_right"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_DPAD_RIGHT']:
		ButtonState['JOY_BUTTON_DPAD_RIGHT'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "ui_right"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)

	if $TouchScreenButtonLEFT.is_pressed():
		if not ButtonState['JOY_BUTTON_DPAD_LEFT']:
			ButtonState['JOY_BUTTON_DPAD_LEFT'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "ui_left"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_DPAD_LEFT']:
		ButtonState['JOY_BUTTON_DPAD_LEFT'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "ui_left"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)

	if $TouchScreenButtonSTART.is_pressed():
		if not ButtonState['JOY_BUTTON_START']:
			ButtonState['JOY_BUTTON_START'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "ui_cancel"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_START']:
		ButtonState['JOY_BUTTON_START'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "ui_cancel"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)

	if $TouchScreenButtonSELECT.is_pressed():
		if not ButtonState['JOY_BUTTON_BACK']:
			ButtonState['JOY_BUTTON_BACK'] = 1
			make_beep()
			var accept_event = InputEventAction.new()
			accept_event.action = "ui_cancel"
			accept_event.pressed = true
			Input.parse_input_event(accept_event)
	elif ButtonState['JOY_BUTTON_BACK']:
		ButtonState['JOY_BUTTON_BACK'] = 0
		var accept_event = InputEventAction.new()
		accept_event.action = "ui_cancel"
		accept_event.pressed = false
		Input.parse_input_event(accept_event)

func beep():
	if OS.is_debug_build():
		printraw (PackedByteArray([0x07]).get_string_from_ascii())
	else:
		make_beep()

func make_beep():
	if !get_node_or_null("beep"):
		var node = AudioStreamPlayer.new()
		node.name = "beep"
		node.volume_db = -12.0
		add_child(node, true)
	
		var a = AudioStreamWAV.new()
		a.format = a.FORMAT_8_BITS
		a.mix_rate = 44100
	
		var data = PackedByteArray([])
		var length = a.mix_rate * 0.2  #200ms
		var phase = 0.0
		var DING_FREQUENCY = 800.0  #Windows ding.wav frequency lol
		var increment = 1.0/(a.mix_rate/DING_FREQUENCY)
	
		for i in range(length):
			var percent = i/length
			var LFO = increment*-sin(percent*TAU)*10 + phase
	
			var byte = (128.0*pow(1-percent, 4) * sin(TAU*LFO) ) 
			phase = fmod(phase+increment, 1.0)
			
			data.append( byte )
			
		a.data = data
		node.stream = a 
	
	get_node("beep").play()
