shader_type canvas_item;
uniform float t: hint_range(0.0,1.0) = 0.0;
uniform sampler2D noise;
void vertex() {
	VERTEX.x *= t*t;
	VERTEX.y *= pow(t,6.0);
}

void fragment() {
	COLOR.a = (1.0-step(texture(noise,UV*2.0).r+(pow(t,4.0)*1.4-0.4),1.0))*COLOR.a;
}
