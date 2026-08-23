extends Control

@onready var main_body: RichTextLabel = $MainBody
@export var typing_speed: float = 0.02


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState._display_text.connect(_on_display_text)
	#main_body.text = ""

# This is the function that handles the Array of Strings
func _on_display_text(text_lines: Array[String], character_id: String) -> void:
	# Process each string in the array one by one
	for txt in text_lines:
		print(txt)
		
		var formatted_text = txt
		if character_id != "narrator" and character_id != "":
			formatted_text = "[" + character_id + "] " + txt
			
		if main_body.text != "":
			formatted_text = "\n\n" + formatted_text
			
		main_body.append_text(formatted_text)
		
		var start_chars = main_body.visible_characters
		var end_chars = main_body.get_total_character_count()
		
		main_body.visible_characters = start_chars
		
		var tween = create_tween()
		tween.tween_property(main_body, "visible_characters", end_chars, (end_chars - start_chars) * typing_speed)
		
		await tween.finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
