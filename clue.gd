class_name Clue
extends Area2D

@export var id: String = ""

func _ready() -> void:
	input_pickable = true

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not GameState.ClickedClues.has(id):
			GameState.ClickedClues.append(id)
			
			input_pickable = false
			GameState.clicked(id)
			
			print("hello1 - ID: ", id)
