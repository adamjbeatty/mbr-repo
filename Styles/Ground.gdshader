shader_type canvas_item;
uniform float u_speed = .1; 
uniform int pixelation = 100;

uniform vec4 u_color_low : source_color = vec4(0.374, 0.374, 0.374,1.0);
uniform vec4 u_color_mid_red : source_color = vec4(.8, 0.8, 0.8, 1.0); 
uniform vec4 u_color_high : source_color = vec4(1.0, 1.0, 1.0, 1.0); 



#define iTime (TIME * u_speed)
#define iResolution 1.0/SCREEN_PIXEL_SIZE

const mat2 mtx = mat2( vec2(0.80, -0.60), vec2(0.60, 0.80) );

float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);

    float res = mix(
        mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x),
        mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x), u.y);
        
    return res * res;
}

float fbm( vec2 p )
{
    float f = 0.0;
    
    f += 0.500000 * noise( p + iTime ); p = mtx * p * 2.02;
    f += 0.031250 * noise( p ); p = mtx * p * 2.01;
    f += 0.250000 * noise( p ); p = mtx * p * 2.03;
    f += 0.125000 * noise( p ); p = mtx * p * 2.01;
    f += 0.062500 * noise( p ); p = mtx * p * 2.04;
    f += 0.015625 * noise( p + sin(iTime) );

    return f / 1.0;
}

float pattern( in vec2 p )
{
	return fbm( p + fbm( p + fbm( p ) ) );
}

vec4 colormap(float x) {
    
    if (x < 0.24) { 
        return mix(u_color_low, u_color_mid_red, x / 0.24);
    } 
    else { 
        return mix(u_color_mid_red, u_color_high, (x - 0.24) / 0.76);
    }
}

void fragment()
{
    vec2 screen_size = 0.25 / SCREEN_PIXEL_SIZE;
    vec2 uv = round(SCREEN_UV * float(pixelation)) / float(pixelation); 
   	float shade = pattern(uv);
	
    COLOR.rgba *= colormap(shade);

}