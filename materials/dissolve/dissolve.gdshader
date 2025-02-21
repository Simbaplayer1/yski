shader_type canvas_item;

uniform float time:hint_range(0.0, 1.0, 0.001) = 1.0; // Adjusted range to 0.0 to 1.0
uniform float resolution_scale:hint_range(0.0, 4.0, 0.5) = 2;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,96.233))) * 43758.5453);
}

void fragment()
{
    vec2 within_texture_pixel = vec2(floor(UV * vec2(384,216) * vec2(resolution_scale, resolution_scale)));
    vec4 color = texture(TEXTURE, UV);

    // Use time directly since it now ranges from 1.0 to 0.0
    if (time > rand(within_texture_pixel))
        COLOR = color;
    else
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
}