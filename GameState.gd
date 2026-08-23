extends Node

# выбранные улики
var ChosenClues: Array[String] = []

# Limit per scene
@export var max_clues_per_scene: int = 5

# --- SIGNALS ---
signal _clue_clicked(clue_id: String)
signal _display_text(text: Array[String], character_id: String)
signal _scene_switched(scene_id: String)
signal _added_text(text: String)
signal _no_clues()



@export var remaining_clues: int = 1000

# --- METHODS ---
# вызывается когда игрок кликает на предмет.
func clicked(clue_id: String) -> void:
	print('hello')
	if remaining_clues <= 0:
		
		return
		# текст дела

	if clue_id in ChosenClues:
		# TODO: дать ворнинг игроку
		print("Already clicked this clue.")
		return

	ChosenClues.append(clue_id)
	_clue_clicked.emit(clue_id)
	remaining_clues -= 1
	if remaining_clues == 0:
		_no_clues.emit()
	print("Clue clicked: ", clue_id, " | Remaining: ", remaining_clues)



# дисплей диалога
func display(txt: Array[String], character_id: String) -> void:
	_display_text.emit(txt, character_id)

func addText(text: String) -> void:
	_added_text.emit(text)

# 4. Switch the scene/plan
func switch_scene(id: String) -> void:
	_scene_switched.emit(id)
	print("Switching scene to: ", id)

# TODO: update this accordingly
func reset_scene_interactions() -> void:
	ChosenClues.clear()
	
