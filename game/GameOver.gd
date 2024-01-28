extends Control


func _ready():
	visible = false
	Beat.on_song_end.connect(on_song_end)

func on_song_end():
	visible = true


func _on_home_pressed():
	Global.on_home.emit()
	$"../MainMenu".visible = true
	visible = false
	


func _on_retry_pressed():
	Beat.start_song(Beat.song)
	visible = false
