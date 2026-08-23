extends Node

# выбранные улики
var ChosenClues: Array[String] = []

# Limit per scene
@export var max_clues_per_scene: int = 5

# --- SIGNALS ---
signal clue_clicked(clue_id: String)
signal display_text(text: String, character_id: String)
signal scene_switched(scene_id: PackedScene)
signal added_text(text: String)



@export var remaining_clues: int = 1000

# --- METHODS ---
# вызывается когда игрок кликает на предмет.
func clicked(clue_id: String) -> void:
	if remaining_clues <= 0:
		return
		# текст дела

	if clue_id in ChosenClues:
		# TODO: дать ворнинг игроку
		print("Already clicked this clue.")
		return

	ChosenClues.append(clue_id)
	clue_clicked.emit(clue_id)
	print("Clue clicked: ", clue_id, " | Remaining: ", remaining_clues)

# дисплей диалога
func display(txt: String, character_id: String) -> void:
	display_text.emit(txt, character_id)

func addText(text: String) -> void:
	added_text.emit(text)

# 4. Switch the scene/plan
func switch_scene(id: String) -> void:
	scene_switched.emit(id)
	print("Switching scene to: ", id)

# TODO: update this accordingly
func reset_scene_interactions() -> void:
	ChosenClues.clear()
	
