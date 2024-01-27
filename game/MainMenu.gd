extends Control

func _ready():
	visible = true
	$"../Gameplay".visible = false

func _on_play_normal_mode_button_pressed():
	#play game
	Beat.start_song(preload("res://music/gospodipomiluj.ogg"))
	visible = false
	$"../Gameplay".visible = true
	$"../GameOver".visible = false
	
func _on_enable_chaos_mode_toggled(toggled_on):
	pass # setSilly mode to toggle_on

func _on_quit_pressed():
	get_tree().quit()


func get_all_children(node: Node):
	var children = [node]
	for child in node.get_children():
		children.append_array(get_all_children(child))
	return children
	

var h = randf()

func _process(delta):
	h += delta
	for child in get_all_children(self):
		if child is Button:
			if child.is_hovered():
				child.self_modulate = Color.from_hsv(fmod(h,1.0),1.0,1.0,1.0)
			else:
				child.self_modulate = Color.WHITE 
