shader_type canvas_item;

group_uniforms code_set_parameters;
uniform vec2 mouse_position;
uniform vec2 sprite_position;

group_uniforms shake_settings;
uniform bool shake_enabled = false; // Toggle for shake effect
uniform float shake_intensity : hint_range(0, 10) = 1.0; // Intensity of the shake
uniform float shake_speed : hint_range(0, 10) = 1.0; // Speed of the shake
uniform float offset = 0; // Random offset for each instance

group_uniforms mouse_looker;
uniform float fov : hint_range(1, 179) = 90;
uniform bool cull_back = true;
//uniform float y_rot : hint_range(-180, 180) = 0.0; From original shader -- https://godotshaders.com/shader/2d-perspective/
//uniform float x_rot : hint_range(-180, 180) = 0.0;
//Amount to inset the image by, a higher value means the image is smaller but less likely to go outside of the "bounds" of the original sprite size.
uniform float inset : hint_range(0, 1) = 0.0;
//Max tilt. 2 means the sprite goes all the way to one side, and the plane is parrelel to the 2d camera.
uniform float max_tilt : hint_range(0,3.0) = 1.0;
varying flat vec2 o;
varying vec3 p;
uniform float tilt_amplitude = 30.0;
uniform float max_distance = 500.0;

group_uniforms foil_uniforms;
//The color of the foil.
uniform vec3 foilcolor : source_color;
uniform float threshold = 0.1;
uniform float period = 1;
uniform float scroll = 1;
uniform float sin_threshold = 1.0;
uniform float foil_threshold = 0.1;
uniform float normal_strength = .1;
uniform float effect_alpha_mult : hint_range(0,1) = 1.0;
uniform float direction : hint_range(0,1) = 0.5;

uniform sampler2D foil_mask;
uniform sampler2D gradient;
uniform sampler2D noise;
uniform sampler2D normal_map;

varying smooth vec2 direction_to;
varying smooth vec2 passthrough;

float inverse_lerp(float v, float a, float b){
	return (v - a) / (b - a);
}

mat2 to_rotated(float angle){
	return mat2(vec2(cos(angle),-sin(angle)),
				vec2(sin(angle),cos(angle)));
}

vec3 rotate_vector(vec3 v, float angleX, float angleY, float magnitude) {
	// Create rotation matrices for X and Y axes.
	mat3 rotX = mat3(
		vec3(1.0, 0.0, 0.0),
		vec3(0.0, cos(angleX), -sin(angleX)),
		vec3(0.0, sin(angleX), cos(angleX))
	);
	mat3 rotY = mat3(
		vec3(cos(angleY), 0.0, sin(angleY)),
		vec3(0.0, 1.0, 0.0),
		vec3(-sin(angleY), 0.0, cos(angleY))
	);
	// Combine the rotations. Order matters! Y then X is common.
	mat3 combinedRotation = rotX * rotY; // Apply Y rotation first, then X.
	// Rotate the vector.
	vec3 rotatedVector = combinedRotation * v;
	// Apply magnitude
	rotatedVector = normalize(rotatedVector) * magnitude;
	return rotatedVector;
}

void vertex() {
    // Apply shake effect to mouse_position if enabled
    vec2 shaken_mouse_position = mouse_position;
    if (shake_enabled) {
        float time_factor = TIME * shake_speed + offset;
        shaken_mouse_position.x += sin(time_factor) * shake_intensity;
        shaken_mouse_position.y += cos(time_factor) * shake_intensity;
    }

    direction_to = shaken_mouse_position - sprite_position;
    float d = length(direction_to);
    float magnitude = min(max_tilt, d / max_distance);
    float angle = atan(direction_to.x, direction_to.y);
    float x_rota = abs(angle) / PI;
    float y_rota = abs(atan(direction_to.y, direction_to.x)) / PI;

    float sin_b = sin((-y_rota + .5) * magnitude * (PI / 2.0));
    float cos_b = cos((-y_rota + .5) * magnitude * (PI / 2.0));
    float sin_c = sin((x_rota - .5) * magnitude * (PI / 2.0));
    float cos_c = cos((x_rota - .5) * magnitude * (PI / 2.0));

    mat3 inv_rot_mat;
    inv_rot_mat[0][0] = cos_b;
    inv_rot_mat[0][1] = 0.0;
    inv_rot_mat[0][2] = -sin_b;

    inv_rot_mat[1][0] = sin_b * sin_c;
    inv_rot_mat[1][1] = cos_c;
    inv_rot_mat[1][2] = cos_b * sin_c;

    inv_rot_mat[2][0] = sin_b * cos_c;
    inv_rot_mat[2][1] = -sin_c;
    inv_rot_mat[2][2] = cos_b * cos_c;

    float t = tan(fov / 360.0 * PI);
    p = inv_rot_mat * vec3((UV - 0.5), 0.5 / t);
    float v = (0.5 / t) + 0.5;
    p.xy *= v * inv_rot_mat[2].z;
    o = v * inv_rot_mat[2].xy;

    VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * t * (1.0 - inset);
}

void fragment() {
	//culls the back somehow
	if (cull_back && p.z <= 0.0) discard;
	//get the UV from based on the tilt from the vertex function
	vec2 uv = (p.xy / p.z).xy - o;
	vec2 adjusted_uv = uv + 0.5;
	//get the color texture
	vec4 albedo_tex = texture(TEXTURE, adjusted_uv);
	COLOR = albedo_tex;
	vec4 mask = texture(foil_mask,adjusted_uv);
	float d = length( direction_to );
	float magnitude = min( max_tilt , d / max_distance);
	float angle = atan(direction_to.x,direction_to.y);
	float x_rota = abs(angle) / PI;
	float y_rota = abs(atan(direction_to.y,direction_to.x)) / PI;
	vec3 normal_map_tex = texture(normal_map,adjusted_uv).rgb * 2.0 - 1.0;
	vec3 normal = rotate_vector(vec3(1.0,1.0,1.0),x_rota,y_rota,magnitude * magnitude);
	normal *= dot(normal_map_tex,vec3(x_rota,y_rota,0.0)) * normal_strength;
	//normal *= normal_map_tex * normal_strength;
	vec4 noise_tex = texture(noise,adjusted_uv);
	vec2 gradiant_sample = vec2((0.25+(normal.y*direction*2.0-normal.x*(1.0-direction)*2.0)/2.0+(uv.y*direction+uv.x*(1.0-direction))/2.0), 0.0);
	gradiant_sample += vec2(magnitude,0.0) * scroll;
	gradiant_sample = mod((gradiant_sample+adjusted_uv) * period,1.0);
	vec4 gradient_tex = texture(gradient, gradiant_sample);
	float strength = effect_alpha_mult * mask.r * (1.0 - length(foilcolor - albedo_tex.rgb) * foil_threshold);
	COLOR.rgb = mix(albedo_tex.rgb, gradient_tex.rgb*(noise_tex.rgb*2.0), strength);//(effect_alpha_mult-length(albedo_tex))*gradient_tex.a*effect_alpha_mult);
	COLOR.a *= step(max(abs(uv.x), abs(uv.y)), 0.5);
}