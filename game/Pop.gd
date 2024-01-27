extends Node2D

enum State {
	IDLE = 0,
	TAKE = 1,
	HOLD1 = 2,
	DIP = 3,
	HOLD2 = 4,
	PUT = 5,
	FAIL = -1
}

var textures: Array[Texture] = [
	preload("res://textures/POP BACA.png"),
	preload("res://textures/pop.png"),
	preload("res://textures/POP_UZIMA.png"),
	preload("res://textures/pop.png"),
	preload("res://textures/POP UMACE.png"),
	preload("res://textures/pop.png"),
	preload("res://textures/POP STAVLJA.png"),
]


var state: int = State.IDLE : set = set_state

func _ready():
	Beat.hit_success.connect(on_success)
	Beat.hit_fail.connect(on_fail)
	$Pop/HoldBeba.visible = false
	$Pop/HoldBeba2.visible = false
	$Pop/DipBeba.visible = false
	
func on_success():
	print("on success")
	self.state = (state + 1 + (1 if state == State.FAIL else 0)) % (State.size()-1)

func on_fail():
	print("on fail")
	self.state = State.FAIL

func set_state(value: int):
	state = value
	$"../Label".text = State.keys()[state]
	$Pop.texture = textures[state+1]
	match state:
		State.HOLD1: 
			on_baby_pickup()
			$Pop/HoldBeba.visible = true
		State.DIP:
			$Pop/HoldBeba.visible = false
			$Pop/DipBeba.visible = true
		State.HOLD2:
			$Pop/HoldBeba.visible = true
			$Pop/DipBeba.visible = false
		State.PUT:
			$Pop/HoldBeba.visible = false
			$Pop/HoldBeba2.visible = false
			on_baby_put()
		State.FAIL:
			if holding_baby:
				throw_baby()
				
var holding_baby: bool = false
@onready var baby_material: Material = $Sto/Beba.material
@onready var baby2_material: Material = $Sto2/Beba.material
func on_baby_pickup():
	holding_baby = true
	baby_material.set("shader_parameter/t",0.0)
	var tween = create_tween()
	tween.tween_property(baby_material,"shader_parameter/t",1.0,Beat.beat_to_time(0.49))
	
func on_baby_put():
	holding_baby = false
	baby2_material.set("shader_parameter/t",1.0)
	var tween = create_tween()
	tween.tween_property(baby2_material,"shader_parameter/t",0.0,Beat.beat_to_time(2.0))

func throw_baby():
	var p = $Pop/BabyThrowPos.global_position
	var baby = preload("res://game/thrownbaby/thrownbaby.tscn").instantiate()
	add_child(baby)
	baby.global_position = p
	baby.velocity = Vector2.UP.rotated((randf()*0.2+0.8)*(randi()%2*2-1)*0.3)*1000.0
	holding_baby = false
	$Pop/HoldBeba.visible = false
	$Pop/HoldBeba2.visible = false
	$Pop/DipBeba.visible = false
	
	
	
