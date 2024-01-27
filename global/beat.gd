extends CanvasLayer

enum JUDGEMENT {
	TOO_EARLY = -2,
	EARLY = -1,
	PERFECT = 0,
	LATE = 1,
	TOO_LATE = 2
}

class Baby: # take
	var key: int
	var beat: float
	func _init(key: int, beat: float):
		self.key = key
		self.beat = beat
	func _draw(c: CanvasItem):
		var texture = preload("res://icon.svg")
		c.draw_indicator(texture,beat,OS.get_keycode_string(key))
		pass

var bpm: float = 142
var current_beat: float = 0.0
var last_frame_beat: float = 0.0
var playing: bool = false
var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
var indicators: CanvasItem
var indicator_speed: float = 300.0
var babies: Array[Baby] = []


var flashbang: ColorRect = ColorRect.new()

func _ready():
	for i in 100:
		babies.append(Baby.new([KEY_SPACE,KEY_A,KEY_S,KEY_D,KEY_F][randi()%5],i*1.5))
	add_child(flashbang)
	flashbang.anchors_preset = 15
	add_child(audio_player)
	start_song(preload("res://music/gospodipomiluj.ogg"))

func _process(delta):
	if playing:
		current_beat += bpm*delta/60.0
		if abs(audio_player.get_playback_position()-current_beat/bpm*60.0) < 0.02:
			current_beat = audio_player.get_playback_position()
		if fmod(last_frame_beat,2.0) > fmod(current_beat,2.0):
			flashbang.color = Color.WHITE
			# print("BEAT " + str(current_beat))
		else:
			flashbang.color = Color(1.0,1.0,1.0,0.0)
		last_frame_beat = current_beat
		
		_process_babies(delta)
		
		indicators.queue_redraw()

func draw_babies():
	for baby in babies:
		baby._draw(indicators)

func _process_babies(delta):
	if babies.size() > 0:
		if beat_to_time(current_beat - babies[0].beat) > 0.3:
			babies.pop_front()
			print("zakasnila beba 2 ⏰⏰")


func start_song(song: AudioStream):
	current_beat = 0.0
	audio_player.stream = song
	audio_player.play(0.0)
	playing = true

func _unhandled_input(event):
	if not event.is_pressed(): return
	if babies.size() == 0: return
	if event is InputEventKey:
		print(OS.get_keycode_string(event.keycode))
		if event.keycode != babies[0].key:
			if babies[0].beat - current_beat < 0.3:
				babies.pop_front() # fail state 🤯
				print("pogresna beba 👶❌")
		elif babies[0].beat - current_beat < 0.3:
			babies.pop_front()
			print("prerana beba ⏮")
		else:
			var judgement = handle_judgement(babies[0])
			print(judgement)
			if judgement in [JUDGEMENT.EARLY, JUDGEMENT.PERFECT, JUDGEMENT.LATE]:
				print("krstena ⛪🤞➕✝☦ beba")
				babies.pop_front()
			elif judgement == JUDGEMENT.TOO_EARLY:
				print("previse rano")
			elif judgement == JUDGEMENT.TOO_LATE:
				print("zakasnila beba ⏰")
				babies.pop_front() # fail state 🤯


func handle_judgement(baby: Baby):
	var difference = beat_to_time(current_beat - baby.beat)
	if difference < -0.3: return JUDGEMENT.TOO_EARLY
	elif difference < -0.15: return JUDGEMENT.EARLY
	elif difference <= 0.15: return JUDGEMENT.PERFECT
	elif difference > 0.15: return JUDGEMENT.LATE
	elif difference > 0.3: return JUDGEMENT.TOO_LATE
	print(difference)
	
func beat_to_time(beat: float):
	return beat/bpm*60.0

func time_to_beat(time: float):
	return time*bpm/60.0
