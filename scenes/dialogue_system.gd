extends Control

@onready var main_body: RichTextLabel = $VBoxContainer/Dialogue/MainBody

var typing_speed: float = 0.05 / 3        # seconds per normal character
var comma_pause: float = 0.05             # extra delay on , ; :
var sentence_pause: float = 0.1           # tiny delay before waiting for input

var _waiting_for_input: bool = false
var _skip_requested: bool = false
var _is_active: bool = false

var auto: bool = false

# The queue to hold incoming dialogue requests
var _dialogue_queue: Array = []

func _ready() -> void:
	print('Dialogue system init')
	GameState._display_text.connect(_on_display_text)
	main_body.text = ""
	main_body.visible_characters = 0

# Called externally. Instead of running immediately, it adds to the queue.
func _on_display_text(text_lines: Array[String], character_id: String) -> void:
	_dialogue_queue.append({
		"lines": text_lines,
		"id": character_id
	})
	
	# If nothing is currently typing, start processing the queue
	if not _is_active:
		_process_queue()

# Processes dialogue requests one by one
func _process_queue() -> void:
	_is_active = true
	
	while _dialogue_queue.size() > 0:
		var item = _dialogue_queue.pop_front()
		await _play_dialogue(item.lines, item.id)
		
	_is_active = false

# Types out a single dialogue event
func _play_dialogue(text_lines: Array[String], character_id: String) -> void:
	$"VBoxContainer/Dialogue".show()
	
	for txt in text_lines:
		# 1. CLEAR AT THE START OF THE LOOP
		# clear() empties the text box, and we manually reset the typewriter counter
		main_body.clear()
		main_body.visible_characters = 0
		
		var formatted_text = txt
		if character_id != "narrator" and character_id != "":
			formatted_text = "[" + character_id + "] " + txt

		# We no longer need to check for "\n\n" because we are clearing the box every time
		main_body.append_text(formatted_text)
		
		# Wait one frame so the RichTextLabel can parse the newly appended text
		await get_tree().process_frame

		var parsed := main_body.get_parsed_text()
		var total := parsed.length()

		# 2. ALWAYS START AT 0
		var i := 0 
		while i < total:
			i += 1
			main_body.visible_characters = i

			# If the player clicks/presses space while typing, skip to the end of the line
			if _skip_requested:
				_skip_requested = false
				main_body.visible_characters = total
				break

			var ch: String = parsed[i - 1]

			# Stop on sentence-ending punctuation
			if ch == "." or ch == "!" or ch == "?":
				await get_tree().create_timer(sentence_pause).timeout
				if not _skip_requested:
					await _wait_for_input()
			# Slow down on commas
			elif ch == "," or ch == ";" or ch == ":":
				await get_tree().create_timer(comma_pause).timeout
			else:
				await get_tree().create_timer(typing_speed).timeout
				
		# Ensure we wait for input at the end of each string in the array
		if not _skip_requested:
			await _wait_for_input()
		else:
			_skip_requested = false
			
		# (Removed main_body.text = "" from here)
	
	$"VBoxContainer/Dialogue".hide()

# Waits until the player clicks, presses spacebar, OR auto-mode timer runs out
func _wait_for_input() -> void:
	_waiting_for_input = true
	var auto_timer := 0.0
	var auto_delay := 2.0 # Seconds before auto-advancing
	
	while _waiting_for_input:
		await get_tree().process_frame
		
		# If auto mode is on, count up. If it reaches 2 seconds, break the loop and continue.
		if auto:
			auto_timer += get_process_delta_time()
			if auto_timer >= auto_delay:
				_waiting_for_input = false

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return

	var input_pressed := false
	
	# Spacebar or Enter
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			input_pressed = true
			
	# Mouse click (left button)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			input_pressed = true

	if input_pressed:
		if _waiting_for_input:
			# If we are waiting, resume (this works even if auto is on)
			_waiting_for_input = false
		else:
			# If we are currently typing, request a skip
			_skip_requested = true
			
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	pass


func _on_skip_button_up() -> void:
	pass # Replace with function body.


func _on_auto_button_up() -> void:
	auto = !auto
