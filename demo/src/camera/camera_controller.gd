extends Camera


export var forward_action = "ui_up"
export var backward_action = "ui_down"
export var left_action = "ui_left"
export var right_action = "ui_right"

func _ready():
	pass # Replace with function body.
	
func _input(event):
	print("input")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
