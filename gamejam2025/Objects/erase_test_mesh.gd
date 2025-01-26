extends MeshInstance3D

const WhitePixelsTotal := 1282207

@export var player: Player

var mask_image: Image
var mask_texture: ImageTexture
const default_mask_path: String = "res://Objects/Bathtub/bath_mask.png"

func _ready():
	self.player = self.get_tree().get_first_node_in_group("Player")

	var mask_image_resource = preload(default_mask_path)
	mask_image = mask_image_resource.get_image()
	mask_texture = ImageTexture.create_from_image(mask_image)

	material_overlay.set("shader_param/mask_texture", mask_texture)
	PlayerStats.connect("compute_score", self.compute_clean_score)
	GlobalSignals.connect("reset_bathub", self.reset)
	GlobalSignals.connect("put_dirt_local", self.add_dirt)

func _process(_delta):
	if player.current_state == player.States.GROUNDED:
		var player_position = player.global_position
		erase_dirt(player_position)
		

@warning_ignore("shadowed_variable_base_class")
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

func add_dirt(dirt_position: Vector3):
	var uv_position = world_to_texture_coords(dirt_position)
	var radius = 32
	var radius_sq = radius * radius
	
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			if x*x + y*y <= radius_sq:
				var pixel_pos = uv_position + Vector2(x, y)
				if pixel_pos.x >= 0 && pixel_pos.x < mask_image.get_width() && pixel_pos.y >= 0 && pixel_pos.y < mask_image.get_height():
					mask_image.set_pixel(pixel_pos.x, pixel_pos.y, Color(1.0, 1.0, 1.0, 1.0))
	
	mask_texture.update(mask_image)

func world_to_texture_coords(world_position: Vector3) -> Vector2:
	var mesh_scale = global_transform.basis.get_scale()
	var local_position = to_local(world_position) / mesh_scale
	
	var uv_x = (local_position.x / 400.0) + 0.504
	var uv_y = (local_position.z / 400.0) + 0.497	
	
	uv_x *= mask_image.get_width()
	uv_y *= mask_image.get_height()
	
	return Vector2(uv_x, uv_y)


func compute_clean_score():
	var total_score = 0 
	for i in range(self.mask_image.get_width()):
		for j in range(self.mask_image.get_height()):
			total_score += int(self.mask_image.get_pixel(i, j).r >= 0.99)
	PlayerStats.current_score = (self.WhitePixelsTotal - total_score) / 100.0

func reset():
	mask_image = Image.load_from_file(default_mask_path)
	mask_texture = ImageTexture.create_from_image(mask_image)
	
	material_overlay.set("shader_param/mask_texture", mask_texture)
