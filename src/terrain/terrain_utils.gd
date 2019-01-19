class TerrainUtils:
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