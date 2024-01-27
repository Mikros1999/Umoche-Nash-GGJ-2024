extends PointLight2D

func _ready():
	Beat.hit_success.connect(on_success)

func on_success():
	color = Color.from_hsv(randf(),1.0,1.0,1.0) 
