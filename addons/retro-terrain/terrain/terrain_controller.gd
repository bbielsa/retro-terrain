tool

extends Spatial


signal chunk_changed()
signal input_terrain_event()

onready var terrain_model = get_node("TerrainModel")
onready var terrain_instance = get_node("TerrainStaticBody/TerrainMeshInstance")
onready var TerrainChunk = preload("res://addons/retro-terrain/scene/terrain_chunk.tscn")

var chunk_size = 8
var world_size = 4
var map_size = chunk_size * world_size

onready var chunks = []

func _ready():
	terrain_model.connect("terrain_changed", self, "_on_terrain_changed")
#	terrain_body.connect("input_event", self, "_on_terrain_input")
	
	_init_map()

func _init_map():
	var id = 0
	
	for y in range(world_size):
		for x in range(world_size):
			_init_chunk(id, x, y, chunk_size)
			id += 1
	
func _init_chunk(id, chunk_x, chunk_y, chunk_size):
	var chunk = TerrainChunk.instance()
	var chunk_mesh_instance = chunk.get_node("TerrainMeshInstance")
	
	chunk.chunk_id = id
	
	var origin_x = chunk_x * chunk_size
	var origin_y = chunk_y * chunk_size
	var origin = Vector3(origin_x, 0, origin_y)
	
	chunk.connect("input_event", self, "_on_chunk_input")
	
	add_child(chunk)
	
	chunk.translate(origin)
	
	chunks.push_back(chunk)
	
func _on_chunk_input(camera, event, mouse_pos, mouse_normal, shape_idx):
	_on_terrain_input(camera, event, mouse_pos, mouse_normal, shape_idx)
	
func _on_terrain_input(camera, event, mouse_pos, mouse_normal, shape_idx):
	var x = mouse_pos.x
	var y = mouse_pos.z
	var scale_x = scale.x
	var scale_y = scale.z

#	print(event)

	var vertex_x = round(x / scale_x)
	var vertex_y = round(y / scale_y)
	var vertex_pos = Vector2(vertex_x, vertex_y)
	
#	print("m: " + str(mouse_pos))
#	print("v: " + str(vertex_pos))

	if not event is InputEventMouseButton:
		return
		
	if event.pressed:
		return

	var button_index = event.button_index
	var delta = 1 if button_index == 1 else -1 

	deform(vertex_x, vertex_y, delta)

#	emit_signal("input_terrain_event", camera, event, mouse_pos, mouse_normal, shape_idx, vertex_pos)

func _on_terrain_changed(height_map, modified_vertices):
	var modified_chunks = {}
	
	for vertex in modified_vertices:
		var chunk_x = floor(vertex.x / (chunk_size + 1))
		var chunk_y = floor(vertex.y / (chunk_size + 1))
		var chunk_id = chunk_y * world_size + chunk_x

		modified_chunks[chunk_id] = true
		
		chunk_x = floor(vertex.x / chunk_size)
		chunk_y = floor(vertex.y / chunk_size)
		chunk_id = chunk_y * world_size + chunk_x

		modified_chunks[chunk_id] = true
		
		chunk_x = floor(vertex.x / chunk_size)
		chunk_y = floor(vertex.y / (chunk_size + 1))
		chunk_id = chunk_y * world_size + chunk_x

		modified_chunks[chunk_id] = true
		
		chunk_x = floor(vertex.x / (chunk_size + 1))
		chunk_y = floor(vertex.y / chunk_size)
		chunk_id = chunk_y * world_size + chunk_x

		modified_chunks[chunk_id] = true
		
		print(vertex)

	var unique_modified_chunks = modified_chunks.keys()
	
	print("Updating chunks " + str(unique_modified_chunks))
	
	emit_signal("chunk_changed", unique_modified_chunks, modified_vertices, height_map)
	
func _get_chunk_id(world_x, world_y):
	var chunk_x = floor(world_x / chunk_size)
	var chunk_y = floor(world_y / chunk_size)
	var chunk_id = chunk_y * world_size + chunk_x
	
	return chunk_id
	
	
func set_tile(x, y, tile_id):
	var chunk_id = _get_chunk_id(x, y)
	var local_x = x % chunk_size
	var local_y = y % chunk_size
	
	var chunk = chunks[chunk_id]
	var chunk_mesh = chunk.get_node("TerrainMeshInstance")
	
	chunk_mesh._set_tile(tile_id, local_x, local_y)
	
func deform(x, y, delta_height):
	terrain_model.deform(x, y, delta_height)
