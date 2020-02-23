extends Spatial


onready var _shape_rid = PhysicsServer.shape_create(PhysicsServer.SHAPE_HEIGHTMAP)
onready var _body_rid = PhysicsServer.body_create(PhysicsServer.BODY_MODE_STATIC)
onready var terrain_model = get_node("../TerrainMeshInstance/TerrainModel")
onready var terrain_instance = get_node("../TerrainMeshInstance")

func _ready():
	# Physics
	PhysicsServer.body_set_collision_layer(_body_rid, 1)
	PhysicsServer.body_set_collision_mask(_body_rid, 1)
	
	# PhysicsServer.body_set_ray_pickable(_body_rid, false)
	
	_init_default_terrain_data()
	
	PhysicsServer.body_add_shape(_body_rid, _shape_rid)
	PhysicsServer.body_attach_object_instance_id(_body_rid, terrain_instance.get_instance_id())
	# Terrain signal
	terrain_model.connect("terrain_changed", self, "_on_terrain_changed")

	# PhysicsServer.body_set_space(_body_rid, RID())

	pass

func _init_default_terrain_data():
	PhysicsServer.shape_set_data(_shape_rid, {
		"width": 1,
		"depth": 1,
		"heights": PoolRealArray([0]),
		"min_height": -1,
		"max_height": 1
	})
	
func _get_terrain_data():
	var height_map = terrain_instance.vertex_array
	var dim = terrain_model.map_dimension + 1
	var width = dim
	var height = dim
	var mesh_aabb = terrain_instance.get_aabb()
	var min_height = mesh_aabb.end.y
	var max_height = mesh_aabb.position.y
	
	var shape_data = {
		"width": width,
		"depth": height,
		"heights": height_map,
		"min_height": min_height,
		"max_height": max_height	
	}
	
	return shape_data

func _on_terrain_changed(vertex_heights):
	var shape_data = _get_terrain_data()
	
	_body_set_shape(shape_data)
	_update_transform()

func _body_set_shape(data):
	PhysicsServer.shape_set_data(_shape_rid, data)

func _update_transform():
	var shape_data = _get_terrain_data()
	var aabb = terrain_instance.get_aabb()

	var width = shape_data["width"]
	var depth = shape_data["depth"]
	var height = aabb.size.y

	#_terrain_transform
	var terrain_transform = terrain_instance.transform

	# Bullet centers the shape to its overall AABB so we need to move it to match the visuals
	var trans = Transform(Basis(), 0.5 * Vector3(width, height, depth) + Vector3(0, aabb.position.y, 0))

	# And then apply the terrain transform
	trans = terrain_transform * trans

	PhysicsServer.body_set_shape_transform(_body_rid, 0, trans)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		print("Destroy HTerrainCollider")
		PhysicsServer.free_rid(_body_rid)
		# The shape needs to be freed after the body, otherwise the engine crashes
		PhysicsServer.free_rid(_shape_rid)
		

