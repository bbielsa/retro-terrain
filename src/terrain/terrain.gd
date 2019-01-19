extends MeshInstance

export(ShaderMaterial) var terrain_material = null

onready var terrain_model = get_node("TerrainModel")
var terrain_shader

func _ready():
	generate_terrain()
	
	terrain_model.connect("terrain_changed", self, "_terrain_changed")
	terrain_model.deform(4, 4, 3)
	terrain_model.deform(4, 4, -2)

	terrain_model.print_map()
	
func generate_terrain():
	var surface = SurfaceTool.new()
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for y in range(terrain_model.map_dimension):
		for x in range(terrain_model.map_dimension):
			add_tile(surface, x, y)
			
	surface.generate_normals()
	surface.index()
	surface.set_material(terrain_material)
	
	set_mesh(surface.commit())
	
func add_tile(surface, x, y):
	var offset = Vector3(x, 0, y)
	
	var a = offset
	var b = offset + Vector3(1, 0, 0)
	var c = offset + Vector3(1, 0, 1)
	var d = offset + Vector3(0, 0, 1)
	var e = offset + Vector3(0.5, 0, 0.5)
	
	var outer = Vector2(0, 0)
	var inner = Vector2(1, 1)
	
#	abe, bce, cde, dae
	surface.add_uv2(outer)
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_uv2(inner)
	surface.add_vertex(e)
	
#	surface.add_uv(Vector2(1, 0))
	surface.add_uv2(outer)
	surface.add_vertex(b)
	surface.add_vertex(c)
	surface.add_uv2(inner)
	surface.add_vertex(e)
	
#	surface.add_uv(Vector2(0, 1))
	surface.add_uv2(outer)
	surface.add_vertex(c)
	surface.add_vertex(d)
	surface.add_uv2(inner)
	surface.add_vertex(e)
	
#	surface.add_uv(Vector2(1, 1))
	surface.add_uv2(outer)
	surface.add_vertex(d)
	surface.add_vertex(a)
	surface.add_uv2(inner)
	surface.add_vertex(e)
	
func _terrain_changed(height_map):
	print("_terrain_changed called, generating data texture")
	
	var height_map_texture = generate_height_map_texture(height_map)
	var shader = terrain_material.shader
	
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