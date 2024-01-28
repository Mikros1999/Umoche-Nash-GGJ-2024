extends Node2D

@onready var p = get_parent()

const rotations = {
	KEY_UP: PI/2.0,
	KEY_DOWN: -PI/2.0,
	KEY_LEFT: 0.0,
	KEY_RIGHT: PI
}

func _ready():
	Beat.hit_success.connect(on_success)
	Beat.hit_fail.connect(on_fail)
	Beat.on_song_start.connect(set_visible.bind(true))
	Beat.on_song_end.connect(set_visible.bind(false))

func on_success():
	var o = $Outline.duplicate()
	o.modulate = Color(0.0,1.0,0.0,1.0)
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(o,"scale",Vector2.ONE*1.3,3.0) 
	tween.tween_property(o,"modulate",Color(0.0,1.0,0.0,0.0),0.2) 
	get_parent().add_child(o)
	o.global_position = global_position
	o.rotation = rotation

func on_fail():
	var o = $Outline.duplicate()
	o.modulate = Color(1.0,0.0,0.0,1.0)
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(o,"scale",Vector2.ONE*1.3,3.0) 
	tween.tween_property(o,"modulate",Color(1.0,0.0,0.0,0.0),0.2) 
	get_parent().add_child(o)
	o.global_position = global_position
	o.rotation = rotation
	
var h: float = 0.0

func _process(delta):
	h += delta
	if Beat.tiles.size() == 0: return
	var state = p.state
	if Global.difficulty >= Global.Difficulty.HARD:
		global_position = get_node("../Markers/Marker" + str((state)%(p.State.size()-1))).global_position
	else:
		global_position = get_node("../Markers/Marker0").global_position
	rotation = rotations[Beat.tiles[0].key]
	var diff = Beat.beat_to_time(Beat.current_beat-Beat.tiles[0].beat)
	$Outline.scale = Vector2.ONE*clamp(-diff,0.0,10000.0)
	$Outline.modulate.a = clamp(pow(1.0+diff,2.0),0.0,1.0)
	$Arrow.modulate = Color.from_hsv(fmod(h,1.0),1.0,1.0,1.0)
	$Arrow.modulate.a = 1.0-clamp(-diff,0.0,1.0)
	$Arrow.scale = Vector2.ONE * 0.1 * (1.0-clamp(-diff,0.0,1.0))
