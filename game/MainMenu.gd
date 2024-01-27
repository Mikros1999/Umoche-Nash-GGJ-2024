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
