extends Spatial

export(ShaderMaterial) var terrain_material = null

onready var terrain_model = get_node("TerrainModel")
var multi_mesh_instance
var theta = 0
var loaded = false
var test_tile_mesh

func _ready():
#	terrain_model.deform(4, 4, -1)
#	terrain_model.deform(4, 4, 2)
#	terrain_model.deform(4, 4, -3)
#	terrain_model.deform(4, 4, 2)
#	terrain_model.deform(4, 4, 1)
#	terrain_model.deform(4, 5, 1)
	terrain_model.deform(0, 0, 1)
	terrain_model.deform(4, 4, 2)
	terrain_model.deform(4, 4, -2)
	terrain_model.print_map()
#	terrain_model.deform(5, 4, 1)
#	terrain_model.deform(5, 5, 1)
#	terrain_model.deform(6, 6, 1)
	test_tile_mesh = generate_terrain(10, 10)
	#generate_terrain_fast(tile, 10, 10)
	
func _process(delta):
	var mesh = test_tile_mesh.mesh
	var faces = mesh.get_faces()
	print(faces[0])
#	if not loaded: 
#		return
#
#	var instance_id = 50
#	var multi_mesh = multi_mesh_instance.multimesh
#	theta += delta
#
#	var new_pos = Vector3(0, abs(sin(theta)), 5)
#	var new_transform = Transform(Basis(), new_pos)
#
#	multi_mesh.set_instance_transform(instance_id, new_transform)

func generate_terrain_fast(tile_mesh, width, height):
	var multi_mesh = MultiMesh.new()
	
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.instance_count = width * height
	#multi_mesh.mesh = preload("res://block.obj")
	
	for y in range(height):
		for x in range(width):
			var pos = Vector3(x, 0, y)
			var instance_id = x + y * width
			var transform = Transform(Basis(), pos)
			
			multi_mesh.set_instance_transform(instance_id, transform)
			
	multi_mesh_instance = MultiMeshInstance.new()
	multi_mesh_instance.multimesh = multi_mesh
	loaded = true
	
	add_child(multi_mesh_instance)
			

func generate_terrain(width, height):
	var surface = SurfaceTool.new()
	var mesh = MeshInstance.new()
	
	var material = terrain_material

	mesh.set_name("terrain")
	add_child(mesh)
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for y in range(height):
		for x in range(width):
			add_tile(surface, x, y)
			
	surface.generate_normals()
	surface.index()
	
	surface.set_material(material)
	mesh.set_mesh(surface.commit())
	
	return mesh
	
	
func get_raised_vertices(x, y):
	var north_height = terrain_model.get_vertex_relative(x, y, 0, 0)
	var east_height = terrain_model.get_vertex_relative(x, y, 1, 0)
	var west_height = terrain_model.get_vertex_relative(x, y, 0, 1)
	var south_height = terrain_model.get_vertex_relative(x, y, 1, 1)

	var sum = north_height + east_height + west_height + south_height
	
	if sum == 1 || sum == -3:
		return 1
	elif sum == 2:
		return 2
	elif sum == -1 || sum == 3:
		return 3	
	return 0

func get_min_tile_height(x, y):
	var north_height = terrain_model.get_vertex_height(x, y)
	var east_height = terrain_model.get_vertex_height(x + 1, y)
	var west_height = terrain_model.get_vertex_height(x, y + 1)
	var south_height = terrain_model.get_vertex_height(x + 1, y + 1)
	
	return min(min(north_height, south_height), min(east_height, west_height))

func get_max_tile_height(tile_x, tile_y):	
	var north = terrain_model.get_vertex_height(tile_x, tile_y)
	var south = terrain_model.get_vertex_height(tile_x + 1, tile_y + 1)
	var west = terrain_model.get_vertex_height(tile_x + 1, tile_y)
	var east = terrain_model.get_vertex_height(tile_x, tile_y + 1)
	
	return max(max(north, south), max(east, west))

func get_middle_vertex_height(x, y):
	var min_tile_height = get_min_tile_height(x, y)
	var max_tile_height = get_max_tile_height(x, y)
	var height_midpoint = (max_tile_height + min_tile_height) / 2.0
	var raised_vertices = get_raised_vertices(x, y)

	if raised_vertices == 1:
		height_midpoint = min_tile_height
	elif raised_vertices == 3:
		height_midpoint = max_tile_height

	return height_midpoint
	
func get_middle_vertex(x, y):
	return Vector3(0, get_middle_vertex_height(x, y), 0) / 4

func calculate_normal(vertex_1, vertex_2, vertex_3):
	var edge_1 = vertex_2 - vertex_1
	var edge_2 = vertex_3 - vertex_1
	var normal = edge_1.cross(edge_2).normalized().abs()
	
	return normal

func get_vertex_height(x, y):		
	return Vector3(0, terrain_model.get_vertex_height(x, y), 0) / 4

func add_tile(surface, x, y):
	var offset = Vector3(x, 0, y)
	
	var grass_color = Color(39/ 256.0, 174/ 256.0, 96/ 256.0)
	surface.add_color(grass_color)
	
	var a = get_vertex_height(x + 0, y + 0) + offset
	var b = get_vertex_height(x + 1, y + 0) + offset + Vector3(1, 0, 0)
	var c = get_vertex_height(x + 1, y + 1) + offset + Vector3(1, 0, 1)
	var d = get_vertex_height(x + 0, y + 1) + offset + Vector3(0, 0, 1)
	var e = get_middle_vertex(x, y) + offset + Vector3(0.5, 0, 0.5)
	
	var outer = Vector2(0, 0)
	var inner = Vector2(1, 1)
	
#	abe, bce, cde, dae
	
	surface.add_normal(calculate_normal(e, b, a))
	surface.add_uv2(outer)
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_uv2(inner)
	surface.add_vertex(e)
	
	
	surface.add_normal(calculate_normal(e, b, c))
	surface.add_uv2(outer)
	surface.add_vertex(b)
	surface.add_vertex(c)
	surface.add_uv2(inner)
	surface.add_vertex(e)
	
	surface.add_normal(calculate_normal(e, c, d))
	surface.add_uv2(outer)
	surface.add_vertex(c)
	surface.add_vertex(d)
	surface.add_uv2(inner)
	surface.add_vertex(e)
	
	surface.add_normal(calculate_normal(e, d, a))
	surface.add_uv2(outer)
	surface.add_vertex(d)
	surface.add_vertex(a)
	surface.add_uv2(inner)
	surface.add_vertex(e)
