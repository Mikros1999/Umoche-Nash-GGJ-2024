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

var completed_babies: int = 0
var failed_babies: int = 0
var baby_streak: int = 0

@export var completed_label_path: NodePath
@onready var completed_label: Label = get_node(completed_label_path)
@export var failed_label_path: NodePath
@onready var failed_label: Label = get_node(failed_label_path)

func _ready():
	# throw_baby()
	Beat.hit_success.connect(on_success)
	Beat.hit_fail.connect(on_fail)
	#Beat.on_beat.connect(on_beat)
	$Pop/HoldBeba.visible = false
	$Pop/HoldBeba2.visible = false
	$Pop/DipBeba.visible = false

var h: float = 0.0

func _process(delta):
	if baby_streak >= 2:
		h += delta
		$Pop/Brada.modulate = Color.from_hsv(fmod(h,1.0),0.8,0.8,1.0);
	else:
		$Pop/Brada.modulate = Color.WHITE

func _physics_process(delta): # smesnoo je
	if Beat.silly_mode and randi()%500 == 1:
		var s2 = duplicate()
		global_position.x -= 100
		get_parent().add_child(s2)
		s2.global_position.x += 100
	
func on_success():
	print("on success")
	self.state = (state + 1 + (1 if state == State.FAIL else 0)) % (State.size()-1)
	var old_scale = $Pop.scale
	$Pop.scale = old_scale*0.97
	var tween = create_tween()
	tween.tween_property($Pop,"scale" ,old_scale,0.1)

func on_fail():
	baby_streak = 0
	self.state = State.FAIL

func set_state(value: int):
	state = value
	$"../Label".text = State.keys()[state]
	$Pop.texture = textures[state+1]
	match state:
		State.TAKE: 
			on_baby_pickup()
		State.HOLD1:
			$Pop/HoldBeba.visible = true
			baby_material.set("shader_parameter/t",0.0)
		State.DIP:
			on_baby_dip()
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

func on_baby_dip():
	$Umocilica/DipParticles.emitting = true
	Global.play_sound(preload("res://audio/voda.ogg"),6.5)
	if Beat.silly_mode:
		var tween = create_tween()
		scale = Vector2(0.9,0.9)
		tween.tween_property(self,"scale",Vector2.ONE,0.12)

func on_baby_put():
	completed_babies += 1
	baby_streak += 1
	if baby_streak == 5:
		start_streak()
	completed_label.text = str(completed_babies)
	holding_baby = false
	baby2_material.set("shader_parameter/t",1.0)
	var tween = create_tween()
	tween.tween_property(baby2_material,"shader_parameter/t",0.0,Beat.beat_to_time(2.0))
	spawn_baby()

func start_streak():
	pass

func spawn_baby():
	baby_material.set("shader_parameter/t",0.0)
	var tween = create_tween()
	tween.tween_property(baby_material,"shader_parameter/t",1.0,Beat.beat_to_time(0.49))

func throw_baby():
	var p = $Pop/BabyThrowPos.global_position
	var baby = preload("res://game/thrownbaby/thrownbaby.tscn").instantiate()
	baby.velocity = Vector2.UP.rotated((randf()*0.2+0.8)*(randi()%2*2-1)*0.3)*900.0
	add_child(baby)
	baby.global_position = p
	holding_baby = false
	failed_babies += 1
	failed_label.text = str(failed_babies)
	$Pop/HoldBeba.visible = false
	$Pop/HoldBeba2.visible = false
	$Pop/DipBeba.visible = false
	spawn_baby()
	
	
	
