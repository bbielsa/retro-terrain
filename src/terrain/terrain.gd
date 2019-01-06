extends MeshInstance

export(ShaderMaterial) var terrain_material = null

onready var terrain_model = get_node("TerrainModel")
onready var terrain_shader = mesh.material

func _ready():
	terrain_model.connect("terrain_changed", self, "_terrain_changed")
	terrain_model.deform(4, 4, 1)

	terrain_model.print_map()
	
func _terrain_changed(height_map):
	print("_terrain_changed called, generating data texture")
	
	var height_map_texture = generate_height_map_texture(height_map)
	var shader = terrain_shader.shader
	
	set_texture_param(shader, "height_map", height_map_texture)
	
func set_texture_param(shader, name, texture):
	shader.set_default_texture_param(name, texture)	
	
func height_to_pixel(height):
	return Color(height / 255.0, 0, 0)
	
func generate_height_map_texture(height_map):
	var image_data = generate_height_map_image_data(height_map)
	var texture = ImageTexture.new()
	
	texture.create_from_image(image_data, 0)

	return texture
	
func generate_height_map_image_data(height_map):
	var map_dimension_vertices = terrain_model.map_dimension + 1
	var image_data = Image.new()
	
	image_data.create(map_dimension_vertices, map_dimension_vertices, false, 2)
	image_data.lock()
	
	for y in range(map_dimension_vertices):
		for x in range(map_dimension_vertices):
			var height = terrain_model.get_vertex_height(x, y)
			var pixel = height_to_pixel(height)
			
			image_data.set_pixel(x, y, pixel)
			
	image_data.unlock()
	
	return image_data