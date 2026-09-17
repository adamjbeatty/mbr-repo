shader_type canvas_item;



vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	float hue = (-SCREEN_UV.x+SCREEN_UV.y) * 1.0 + mod(TIME * 0.1, 1.0);
	//float hue = -SCREEN_UV.x * 1.0 + mod(TIME * 0.25, 1.0);
	COLOR.rgb *= hsv2rgb(vec3(hue,.75, .75));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
