extends Control

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	HARDER,
	HARDEST
}

var difficulty: int = Difficulty.EASY

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		print("a")
		get_window().mode = Window.MODE_FULLSCREEN if get_window().mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED

func play_sound(sound: AudioStream, volume_db: float):
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sound
	audio_player.volume_db = volume_db
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)
	return audio_player
