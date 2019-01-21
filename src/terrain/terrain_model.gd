tool

extends Spatial

signal terrain_changed(vertex_map)

var map_dimension = 64 # number of tiles, vertices will be map_dimension + 1
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
	var height = vertex_height[y][x]
	
	if get_vertex_in_map(x + dx, y + dy):
		return vertex_height[y + dy][x + dx] - height
	else:
		return 0

func get_absolute_vertex_relative(x, y, dx, dy):
	return abs(get_vertex_relative(x, y, dx, dy))

func deform(x, y, delta_height):
	var direction = 1 if delta_height > 0 else -1
	var times = abs(delta_height)
	
	for i in range(times):
		var height = vertex_height[y][x]
		vertex_height[y][x] = height + direction
		normalize_terrain(x, y, direction)
	
	emit_signal("terrain_changed", vertex_height)

func normalize_terrain(x, y, direction):
# called after some terrain vertex was modified
# this ensures that the constraints on terrain are held
# namely: neighboring verticies in cardinal directions
# can only differ in height by, at most, 1 unit height
	
	# north vertex
	if get_absolute_vertex_relative(x, y, 0, -1) > 1:
		var height = vertex_height[y - 1][x]
		vertex_height[y - 1][x] = height + direction
		normalize_terrain(x, y - 1, direction)
	
	# south vertex
	if get_absolute_vertex_relative(x, y, 0, 1) > 1:
		var height = vertex_height[y + 1][x]
		vertex_height[y + 1][x] = height + direction
		normalize_terrain(x, y + 1, direction)
		
	# east vertex
	if get_absolute_vertex_relative(x, y, 1, 0) > 1:
		var height = vertex_height[y][x + 1]
		vertex_height[y][x + 1] = height + direction
		normalize_terrain(x + 1, y, direction)
		
	#west vertex
	if get_absolute_vertex_relative(x, y, -1, 0) > 1:
		var height = vertex_height[y][x - 1]
		vertex_height[y][x - 1] = height + direction
		normalize_terrain(x - 1, y, direction)

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

