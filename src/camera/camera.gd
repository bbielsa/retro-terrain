extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _input(event):
	if not event is InputEventMouseButton:
		return
	
	if event.pressed:
		return
	
	var ray_length = 1000
	var pos = event.position
	var from = self.project_ray_origin(event.position)
	var to = from + self.project_ray_normal(event.position) * ray_length
	
	print(to)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
