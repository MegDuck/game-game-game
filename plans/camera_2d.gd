extends Camera2D

@export var sprite_to_capture: Sprite2D
@export var padding: float = 0.0 # Add padding (in pixels) if you want a border

func _ready():
	fit_to_sprite()

func fit_to_sprite():
	if not sprite_to_capture or not sprite_to_capture.texture:
		return
		
	# Wait for the viewport to be ready so we get accurate screen sizes
	await get_tree().process_frame
	
	# 1. Get the screen size
	var viewport_size = get_viewport_rect().size
	
	# 2. Get the sprite's actual size (accounts for region edits if enabled)
	var sprite_rect = sprite_to_capture.get_rect()
	var sprite_world_size = sprite_rect.size * sprite_to_capture.get_global_transform_with_canvas().get_scale()
	
	# 3. Calculate the required zoom to fit the sprite
	# We divide viewport size by sprite size to see how much we need to zoom in/out
	var zoom_x = viewport_size.x / (sprite_world_size.x + (padding * 2))
	var zoom_y = viewport_size.y / (sprite_world_size.y + (padding * 2))
	
	# 4. Use the MINIMUM zoom so the whole sprite fits inside the screen
	var final_zoom = min(zoom_x, zoom_y)
	
	# Apply the zoom
	zoom = Vector2(final_zoom, final_zoom)
	
	# 5. Center the camera on the sprite
	# We use the global position plus the offset of the rect
	var sprite_center = sprite_to_capture.global_position + sprite_to_capture.offset.rotated(sprite_to_capture.global_rotation)
	global_position = sprite_center
