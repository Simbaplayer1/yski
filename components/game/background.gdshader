shader_type canvas_item;

// Adjustable parameters
uniform int NUM_RECTS = 15;
uniform float SPEED = 0.8;
uniform float GLOW_WIDTH = 0.015;
uniform float MAX_SIZE = 0.4;
uniform float SPAWN_INTERVAL = 3.0;
uniform vec4 COLOR1 = vec4(0.2, 0.8, 1.0, 1.0); // Cyan
uniform vec4 COLOR2 = vec4(1.0, 0.2, 0.8, 1.0); // Pink

float hash(float seed) {
    return fract(sin(seed) * 43758.5453);
}

void fragment() {
    vec2 uv = UV * 2.0 - 1.0; // Center coordinates [-1, 1]
    vec4 final_color = vec4(0.0);

    for(int i = 0; i < NUM_RECTS; i++) {
        // Generate unique seed for each rectangle
        float seed = float(i);

        // Random position
        float pos_x = hash(seed * 126.1) * 2.0 - 1.0;
        float pos_y = hash(seed * 937.5) * 2.0 - 1.0;

        // Random time offset and color mix
        float time_offset = hash(seed * 453.2) * SPAWN_INTERVAL;
        float color_mix = hash(seed * 671.3);

        // Calculate growing size
        float t = mod(TIME * SPEED + time_offset, SPAWN_INTERVAL);
        float size = (t / SPAWN_INTERVAL) * MAX_SIZE;

        // Rectangle dimensions
        vec2 center = vec2(pos_x, pos_y);
        vec2 half_size = vec2(size) / 2.0;

        // Signed Distance Field calculation
        vec2 d = abs(uv - center) - half_size;
        float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 1.0);

        // Glow effect calculation
        float glow = 1.02 - smoothstep(0.0, GLOW_WIDTH, abs(dist));
        vec4 rect_color = mix(COLOR1, COLOR2, color_mix) * glow;

        // Additive blending
        final_color += rect_color;
    }

    // Apply alpha and output
    final_color.a = 0.5;
    COLOR = final_color;
}