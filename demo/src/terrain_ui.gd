extends Control


onready var terrain_controller = get_node("../Terrain")
onready var indicator = get_node("VertexIndicator")
onready var height_value_label = get_node("CenterContainer/VBoxContainer/HBoxContainer/HeightValueLabel")

func _ready():
	terrain_controller.connect("input_terrain_event", self, "_on_input_terrain")

func _update_gui(camera, mouse_pos, vertex_pos):
	var height = mouse_pos.y
	var screen_pos = camera.unproject_position(mouse_pos)
	
	indicator.set_position(screen_pos, false)

	height_value_label.text = str(height)

func _modify_terrain(camera, event, mouse_pos, vertex_pos):
	var button = event.button_index
	
	if button == BUTTON_LEFT:
		terrain_controller.deform(vertex_pos.x, vertex_pos.y, 1)
	elif button == BUTTON_RIGHT:
		terrain_controller.deform(vertex_pos.x, vertex_pos.y, -1)

func _on_input_terrain(camera, event, mouse_pos, mouse_normal, shape_idx, vertex_pos):
	print("type ", event)
	
	if event is InputEventMouseButton:
		_modify_terrain(camera, event, mouse_pos, vertex_pos)
	elif event is InputEventMouseMotion:
		_update_gui(camera, mouse_pos, vertex_pos)
