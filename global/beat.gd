extends CanvasLayer

signal hit_success
signal hit_fail
signal on_beat
signal on_song_start
signal on_song_end

enum Judgement {
	TOO_EARLY = -2,
	EARLY = -1,
	PERFECT = 0,
	LATE = 1,
	TOO_LATE = 2
}

class Tile: # take
	var key: int
	var beat: float
	func _init(key: int, beat: float):
		self.key = key
		self.beat = beat
	func _draw(c: CanvasItem):
		c.draw_indicator(beat,key)
		pass

var delay: float = 0.70
var pitch: float = 1.0 : set = _set_pitch
var bpm: float = 95.957
var current_beat: float = 0.0
var last_frame_beat: float = 0.0
var playing: bool = false
var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
var indicators: CanvasItem
var indicator_speed: float = 600.0
var tiles: Array[Tile] = []
var silly_mode: bool = false
var song: AudioStream


func _ready():
	add_child(audio_player)
	audio_player.finished.connect(_on_song_end)
	#tween.tween_interval(3.0)
	#tween.tween_property(self,"pitch",1.0,0.0)

func _on_song_end():
	on_song_end.emit()
	playing = false

func _process(delta):
	if playing:
		current_beat += bpm*delta/60.0*pitch
		_sync_beat()
		_check_if_beat_happened()
		_process_tiles(delta)
		
		last_frame_beat = current_beat

func add_tiles(difficulty: int):
	var get_any_arrow = func(): return [KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT][randi()%4]
	match difficulty:
		Global.Difficulty.EASY:
			for i in range(12,122):
				tiles.append(Tile.new(KEY_UP,i*1.0+beat_to_time(delay)))
		Global.Difficulty.NORMAL,Global.Difficulty.HARD:
			for i in range(12,122):
				tiles.append(Tile.new(get_any_arrow.call(),i*1.0+beat_to_time(delay)))
		_:
			for i in range(12,206):
				tiles.append(Tile.new(get_any_arrow.call(),i*1.0+beat_to_time(delay)))


func _sync_beat():
	if abs(audio_player.get_playback_position()-beat_to_time(current_beat/bpm*60.0)) < 0.02:
		current_beat = time_to_beat(audio_player.get_playback_position())

func _check_if_beat_happened():
	var bd = time_to_beat(delay)
	if fmod(last_frame_beat-bd,1.0) > fmod(current_beat-bd,1.0):
		emit_signal("on_beat")

func _process_tiles(delta):
	if tiles.size() > 0:
		if beat_to_time(current_beat - tiles[0].beat) > 0.3:
			tiles.pop_front()
			print("zakasnio tile ⏰⏰⏰" + str(current_beat))
			emit_signal("hit_fail")
	indicators.queue_redraw()
			
func _set_pitch(value):
	audio_player.pitch_scale = value
	pitch = value

func draw_tiles():
	for tile in tiles:
		tile._draw(indicators)

func start_song(song: AudioStream):
	on_song_start.emit()
	self.pitch = 1
	#if true:
	#	self.pitch = 20.0
	if Global.difficulty in [Global.Difficulty.HARDER,Global.Difficulty.HARDEST]:
		print("ubrzavam se ⏩⏩")
		var tween = create_tween()
		tween.tween_property(self,"pitch",1.4 if Global.difficulty == Global.Difficulty.HARDER else 1.8,110.0)
		on_song_end.connect(tween.stop)
	self.song = song
	current_beat = 0.0
	last_frame_beat = 0.0
	audio_player.pitch_scale = pitch
	audio_player.stream = song
	audio_player.play(0.0)
	playing = true
	Beat.add_tiles(Global.difficulty)

const controller_inputs = {
	JOY_BUTTON_A: KEY_DOWN,
	JOY_BUTTON_B: KEY_RIGHT,
	JOY_BUTTON_X: KEY_LEFT,
	JOY_BUTTON_Y: KEY_UP,
	JOY_BUTTON_DPAD_UP: KEY_UP,
	JOY_BUTTON_DPAD_DOWN: KEY_DOWN,
	JOY_BUTTON_DPAD_LEFT: KEY_LEFT,
	JOY_BUTTON_DPAD_RIGHT: KEY_RIGHT,
}

func _unhandled_input(event):
	if not event.is_pressed(): return
	if tiles.size() == 0: return
	if event is InputEventJoypadButton:
		if event.button_index in controller_inputs:
			handle_input(controller_inputs[event.button_index])
	if event is InputEventKey:
		handle_input(event.keycode)

func handle_input(key):
	var judgement = handle_judgement(tiles[0])
	if key != tiles[0].key: 
		if judgement != Judgement.TOO_EARLY:
			tiles.pop_front()
			print("pogresan input :( 😭❌ ")
			hit_fail.emit()
		#TODO Transmit(FailState)
		return
	if judgement in [Judgement.TOO_EARLY,Judgement.TOO_LATE]: 
		hit_fail.emit()
		return
	tiles.pop_front()
	print("dobar input ✅✅ 🥰")
	hit_success.emit()

func handle_judgement(tile: Tile):
	var difference = beat_to_time(current_beat - tile.beat)
	if difference < -0.5: return Judgement.TOO_EARLY
	elif difference < -0.15: return Judgement.EARLY
	elif difference <= 0.15: return Judgement.PERFECT
	elif difference > 0.15: return Judgement.LATE
	elif difference > 0.3: return Judgement.TOO_LATE
	print(difference)
	
func beat_to_time(beat: float):
	return beat/bpm*60.0

func time_to_beat(time: float):
	return time*bpm/60.0
