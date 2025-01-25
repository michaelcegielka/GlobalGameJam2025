extends MeshInstance3D

@export var player: Player

var mask_image: Image
var mask_texture: ImageTexture
@export var default_mask_path: String = "res://Objects/Bathtub/bath_mask.png"

func _ready():
	self.player = self.get_tree().get_first_node_in_group("Player")
	
	mask_image = Image.load_from_file(default_mask_path)
	mask_texture = ImageTexture.create_from_image(mask_image)

	material_overlay.set("shader_param/mask_texture", mask_texture)


func _process(delta):
	if player.current_state == player.States.GROUNDED:
		var player_position = player.global_position
		erase_dirt(player_position)

func erase_dirt(position: Vector3):
	var uv_position = world_to_texture_coords(position)
	var radius = 8
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
	
	var uv_x = (local_position.x / 400.0) + 0.504
	var uv_y = (local_position.z / 400.0) + 0.497	
	
	uv_x *= mask_image.get_width()
	uv_y *= mask_image.get_height()
	
	return Vector2(uv_x, uv_y)
