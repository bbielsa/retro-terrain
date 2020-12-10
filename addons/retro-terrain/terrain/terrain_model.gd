tool

extends Spatial

signal terrain_changed(vertex_map)

onready var terrain_controller = get_node("..")
onready var map_dimension = terrain_controller.map_size # number of tiles, vertices will be map_dimension + 1

var vertex_height = []

# The maximum height can be from -16 to 16 units

func _ready():
#	var camera = get_node("../../Camera")
#	camera.connect("map_pressed", self, "_map_pressed")
	initialize_vertex_array()
	pass
	
func get_vertex_in_map(x, y):
	return x <= map_dimension and x >= 0 and y <= map_dimension and y >= 0

func get_vertex_height(x, y):
	return vertex_height[y][x]

func get_vertex_relative(x, y, dx, dy):
	if dx == 0 and dy == 0:
		return 0
		
	var height = vertex_height[y][x]
	
	if get_vertex_in_map(x + dx, y + dy):
		return vertex_height[y + dy][x + dx] - height
	else:
		return 0

func get_absolute_vertex_relative(x, y, dx, dy):
	return abs(get_vertex_relative(x, y, dx, dy))

func deform(x, y, delta_height):
	var modified_vertices = {}
	var direction = 1 if delta_height > 0 else -1
	var times = abs(delta_height)
	
	_append_unique_vertex(x, y, modified_vertices)
	
	for i in range(times):
		var height = vertex_height[y][x]
		vertex_height[y][x] = height + direction
		normalize_terrain(x, y, direction, modified_vertices)
	
	var unique_modified_vertices = modified_vertices.values()
	
	emit_signal("terrain_changed", vertex_height, unique_modified_vertices)

func _append_unique_vertex(x, y, dict):
	var key = str(x) + "," + str(y)
	dict[key] = Vector2(x, y)

func normalize_terrain(x, y, direction, modified_vertices):
# called after some terrain vertex was modified
# this ensures that the constraints on terrain are held
# namely: neighboring verticies in cardinal directions
# can only differ in height by, at most, 1 unit height
	
	# north vertex
	if get_absolute_vertex_relative(x, y, 0, -1) > 1:
		var height = vertex_height[y - 1][x]
		vertex_height[y - 1][x] = height + direction
		_append_unique_vertex(x, y - 1, modified_vertices)
		normalize_terrain(x, y - 1, direction, modified_vertices)
	
	# south vertex
	if get_absolute_vertex_relative(x, y, 0, 1) > 1:
		var height = vertex_height[y + 1][x]
		vertex_height[y + 1][x] = height + direction
		_append_unique_vertex(x, y + 1, modified_vertices)
		normalize_terrain(x, y + 1, direction, modified_vertices)
		
	# east vertex
	if get_absolute_vertex_relative(x, y, 1, 0) > 1:
		var height = vertex_height[y][x + 1]
		vertex_height[y][x + 1] = height + direction
		_append_unique_vertex(x + 1, y, modified_vertices)
		normalize_terrain(x + 1, y, direction, modified_vertices)
		
	#west vertex
	if get_absolute_vertex_relative(x, y, -1, 0) > 1:
		var height = vertex_height[y][x - 1]
		vertex_height[y][x - 1] = height + direction
		_append_unique_vertex(x - 1, y, modified_vertices)
		normalize_terrain(x - 1, y, direction, modified_vertices)

func initialize_vertex_array():
	for y in range(map_dimension + 1):
		vertex_height.append([])
		for x in range(map_dimension + 1):
			vertex_height[y].append(0)

	emit_signal("terrain_changed", vertex_height)
			
func print_map():
	print("---------------------")
	for y in range(map_dimension + 1):
		var row = ""
		for x in range(map_dimension + 1):
			var height = vertex_height[y][x]
			row = row + str(height) + " "
		print(row)

func grid_to_map(pos):
	var half_dimension = map_dimension / 2
	
	return pos + Vector2(half_dimension, half_dimension)
#
#func _map_pressed(pos):
#	var coord_2d = Vector2(pos.x, pos.z)
#	var map_coord = grid_to_map(coord_2d)
#
#	deform(map_coord.x, map_coord.y, 1)
#
#	print_map()

