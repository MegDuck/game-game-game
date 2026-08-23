extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# изменить приближение у камеры
	SceneManager.change_zoom(5, 5)
	# изменить позицию камеры
	SceneManager.change_offset(115, 65)
	# подключить сигнал из GameState к функции данного скрипта clue_clicked
	GameState._clue_clicked.connect(clue_clicked)

func clue_clicked(clue_id: String) -> void:
	if clue_id == "chair2":
		# показать диалог
		GameState.display(['Стул. Обычный стул, неужели преступление было совершено человеком который сидел за данным стулом? Вполне возможно что и да.'], 'me')
		#GameState.display([''], 'me')
		# добавить текст в дело
		GameState.addText('После этого преступник сел именно на этот стул.')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
