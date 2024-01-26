extends CanvasLayer

class Baby: # take
	var key: int
	var beats: float  	
	func _init(key: int, beat: float):
		self.key = key
		self.beat = beat

var bpm: float = 142.5
var current_beat: float = 0.0
var last_frame_beat: float = 0.0
var playing: bool = false
var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()


var flashbang: ColorRect = ColorRect.new()

func _ready():
	add_child(flashbang)
	flashbang.anchors_preset = 15
	add_child(audio_player)
	start_song(preload("res://music/gospodipomiluj.ogg"))

func _process(delta):
	if playing:
		current_beat += bpm*delta/60.0
		if abs(audio_player.get_playback_position()-current_beat/bpm*60.0) < 0.02:
			current_beat = audio_player.get_playback_position() 
		if fmod(last_frame_beat,1.0) > fmod(current_beat,1.0):
			flashbang.color = Color.WHITE
			print("BEAT " + str(current_beat))
		else:
			flashbang.color = Color(1.0,1.0,1.0,0.0)
		last_frame_beat = current_beat

func start_song(song: AudioStream):
	current_beat = 0.0
	audio_player.stream = song 
	audio_player.play(0.0)
	playing = true

func _unhandled_input(event):
	handle_judgement(Baby.new(0,ceil(current_beat)))


func handle_judgement(baby: Baby):
	var difference = beat_to_time(current_beat - baby.beat)
	print(difference)
	
func beat_to_time(beat: float):
	return beat/bpm*60.0

func time_to_beat(time: float):
	return time*bpm/60.0
