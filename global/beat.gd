extends CanvasLayer

enum JUDGEMENT {
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
		var texture = preload("res://icon.svg")
		c.draw_indicator(texture,beat,OS.get_keycode_string(key))
		pass

var delay: float = 0.45
var pitch: float = 1.0 : set = _set_pitch
var bpm: float = 96
var current_beat: float = 0.0
var last_frame_beat: float = 0.0
var playing: bool = false
var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
var indicators: CanvasItem
var indicator_speed: float = 500.0
var tiles: Array[Tile] = []


var flashbang: ColorRect = ColorRect.new()

func _ready():
	for i in range(12,100):
		tiles.append(Tile.new([KEY_SPACE,KEY_A,KEY_S,KEY_D,KEY_F][randi()%5],i*1.0+beat_to_time(delay)))
	add_child(flashbang)
	flashbang.anchors_preset = 15
	add_child(audio_player)
	audio_player.pitch_scale = pitch
	start_song(preload("res://music/gospodipomiluj.ogg"))
	var tween = create_tween()
	tween.tween_property(self,"pitch",2.0,75.0)

func _process(delta):
	if playing:
		current_beat += bpm*delta/60.0*pitch
		if abs(audio_player.get_playback_position()-beat_to_time(current_beat/bpm*60.0)) < 0.02:
			current_beat = time_to_beat(audio_player.get_playback_position())
		var bd = time_to_beat(delay)
		if fmod(last_frame_beat+bd,2.0) > fmod(current_beat+bd,2.0):
			flashbang.color = Color.WHITE
		else:
			flashbang.color = Color(1.0,1.0,1.0,0.0)
		last_frame_beat = current_beat
		
		_process_tiles(delta)
		
		indicators.queue_redraw()

func _process_tiles(delta):
	if tiles.size() > 0:
		if beat_to_time(current_beat - tiles[0].beat) > 0.3:
			tiles.pop_front()
			print("zakasnio tile ⏰⏰⏰" + str(current_beat))
			
func _set_pitch(value):
	audio_player.pitch_scale = value
	pitch = value

func draw_tiles():
	for tile in tiles:
		tile._draw(indicators)

  

func start_song(song: AudioStream):
	current_beat = 0.0
	audio_player.stream = song
	audio_player.play(0.0)
	playing = true

func _unhandled_input(event):
	if not event.is_pressed(): return
	if tiles.size() == 0: return
	if event is InputEventKey:
		var judgement = handle_judgement(tiles[0])
		if event.keycode != tiles[0].key: 
			if judgement != JUDGEMENT.TOO_EARLY:
				tiles.pop_front()
				print("pogresan input :( 😭❌ ")
			return
		if judgement in [JUDGEMENT.TOO_EARLY,JUDGEMENT.TOO_LATE]: return
		tiles.pop_front()
		print("dobar input ✅✅ 🥰")


func handle_judgement(tile: Tile):
	var difference = beat_to_time(current_beat - tile.beat)
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
