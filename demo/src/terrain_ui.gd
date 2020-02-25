extends Control


onready var terrain_controller = get_node("../Terrain")
onready var indicator = get_node("VertexIndicator")
onready var height_value_label = get_node("CenterContainer/VBoxContainer/HBoxContainer/HeightValueLabel")

func _ready():
	terrain_controller.connect("input_terrain_event", self, "_on_input_terrain")
	
func _on_input_terrain(camera, event, mouse_pos, mouse_normal, shape_idx):
	var height = mouse_pos.y
	var screen_pos = camera.unproject_position(mouse_pos)
	
	indicator.set_position(screen_pos, false)

	height_value_label.text = str(height)
