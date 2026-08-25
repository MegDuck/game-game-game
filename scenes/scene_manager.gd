extends Node

@export var plans: Dictionary = {
	"room": preload("res://plans/Indoors.tscn"),
	#"under_table": preload("res://plans/PlanUnderTable.tscn")
}

var current_plan: Node2D = null
@onready var camera: Camera2D

func _ready():
	#camera = get_node('/root/MainScene/Camera')
	
	# Only connect if not already connected
	if not GameState._scene_switched.is_connected(change_plan):
		GameState._scene_switched.connect(change_plan)
		
	change_plan("room")

func change_zoom(x, y):
	pass
	#camera.zoom = Vector2(x, y)

func change_offset(x, y):
	pass
	#camera.offset = Vector2(x, y)

func change_plan(plan_id: String):
	# 1. Stop if we are trying to load the exact same plan we are already on
	if current_plan and current_plan.name == plan_id:
		return
		
	if current_plan:
		current_plan.queue_free()
	
	change_zoom(1, 1)
	change_offset(0, 0)
	
	var new_plan = plans[plan_id].instantiate()
	# 2. Name the instance the same as the plan_id so the check above works!
	new_plan.name = plan_id 
	
	add_child(new_plan)
	current_plan = new_plan
