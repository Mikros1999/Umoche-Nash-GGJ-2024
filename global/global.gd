extends Control

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		print("a")
		get_window().mode = Window.MODE_FULLSCREEN if get_window().mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED
