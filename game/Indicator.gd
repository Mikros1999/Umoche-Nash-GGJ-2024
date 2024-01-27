extends Node2D

@onready var p = get_parent()

const rotations = {
	KEY_UP: PI/2.0,
	KEY_DOWN: -PI/2.0,
	KEY_LEFT: 0.0,
	KEY_RIGHT: PI
}

var h: float = 0.0



func _process(delta):
	h += delta
	if Beat.tiles.size() == 0: return
	var state = p.state
	global_position = get_node("../Markers/Marker" + str((state)%(p.State.size()-1))).global_position
	rotation = rotations[Beat.tiles[0].key]
	var diff = Beat.beat_to_time(Beat.current_beat-Beat.tiles[0].beat)
	$Outline.scale = Vector2.ONE*clamp(-diff,0.0,10000.0)
	$Outline.modulate.a = clamp(pow(1.0+diff,2.0),0.0,1.0)
	$Arrow.modulate = Color.from_hsv(fmod(h,1.0),1.0,1.0,1.0)
	$Arrow.modulate.a = 1.0-clamp(-diff,0.0,1.0)
	$Arrow.scale = Vector2.ONE * 0.1 * (1.0-clamp(-diff,0.0,1.0))

