# SceneManager.gd
extends Node

@export var plans: Dictionary = {
	"room": preload("res://plans/Room.tscn"),
	#"under_table": preload("res://plans/PlanUnderTable.tscn")
}

var current_plan: Node2D = null
@onready var camera: Camera2D

func _ready():
	camera = get_node('/root/MainScene/Camera')
	change_plan("room")
	GameState.scene_switched.connect(change_plan)

func change_zoom(x, y):
	camera.zoom = Vector2(x, y)

func change_offset(x, y):
	camera.offset = Vector2(x, y)

func change_plan(plan_id: String):
	if current_plan:
		current_plan.queue_free()
	
	change_zoom(1, 1)
	change_offset(0, 0)
	
	current_plan = plans[plan_id].instantiate()
	add_child(current_plan)
