extends Camera


export var forward_action = "ui_up"
export var backward_action = "ui_down"
export var left_action = "ui_left"
export var right_action = "ui_right"

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pan_direction = Vector2(0, 0)
	
	if Input.is_action_pressed(forward_action):
		pan_direction
		
	if Input.is_action_pressed(forward_action):
		pan_direction.y -= 1
		
	var dir = Vector3(pan_direction.x, 0, pan_direction.y)
	translate(dir)
