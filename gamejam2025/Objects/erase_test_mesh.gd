extends MeshInstance3D

var mask_image: Image
var mask_texture: ImageTexture
var player : Player

func _ready():
	self.player = self.get_tree().get_first_node_in_group("Player")
	
	var width = 2048
	var height = 2048
	mask_image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color(1, 1, 1, 1))
	mask_texture = ImageTexture.create_from_image(mask_image)

	material_overlay.set("shader_param/mask_texture", mask_texture)

func _process(delta):
	if player.current_state == player.States.GROUNDED:
		var player_position = player.global_position
		erase_dirt(player_position)

func erase_dirt(position: Vector3):
	var uv_position = world_to_texture_coords(position)
	var radius = 5
	var radius_sq = radius * radius
	
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			if x*x + y*y <= radius_sq:
				var pixel_pos = uv_position + Vector2(x, y)
				if pixel_pos.x >= 0 && pixel_pos.x < mask_image.get_width() && pixel_pos.y >= 0 && pixel_pos.y < mask_image.get_height():
					mask_image.set_pixel(pixel_pos.x, pixel_pos.y, Color(0, 0, 0, 0))
	
	mask_texture.update(mask_image)
	
func world_to_texture_coords(world_position: Vector3) -> Vector2:
	var mesh_scale = global_transform.basis.get_scale()
	var local_position = to_local(world_position) / mesh_scale
	
	var uv_x = (local_position.x / 450.0 * 0.6) + 0.3035
	var uv_y = (local_position.z / 450.0 * 0.6) + 0.6965
	
	print(uv_x)
	print(uv_y)
	
	
	uv_x *= mask_image.get_width()
	uv_y *= mask_image.get_height()
	
	return Vector2(uv_x, uv_y)
