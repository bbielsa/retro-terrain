extends Camera


var should_trace = true
var mouse_pos = null

func _ready():
	pass

func _physics_process(delta):
	if not should_trace || not mouse_pos:
		return
	
	var ray_length = 1000

	var from = self.project_ray_origin(mouse_pos)
	var to = from + self.project_ray_normal(mouse_pos) * ray_length

	print(from, " -> ", to)
	
	should_trace = false

func _input(event):
	if not event is InputEventMouseButton:
		return
	
	if event.pressed:
		return
	
	mouse_pos = event.position
	should_trace = true
