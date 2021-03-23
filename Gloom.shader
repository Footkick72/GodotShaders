shader_type canvas_item;

// Copyright 2021 Daniel Long
// This file is availiable under the MIT License
// Rain technique inspired by https://www.youtube.com/watch?v=s0uVDYjnrWY

uniform sampler2D noise_tex;
uniform float intensity: hint_range(0.0,1.0) = 1.0;
uniform vec2 player_pos;
uniform vec2 viewport_scale;
uniform float vignette_strength: hint_range(0.0, 1.0);

void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	
	vec2 direction = vec2(-0.03, 0.2);
	float movement = TIME * 4.0;
	direction *= movement;
	direction += player_pos * SCREEN_PIXEL_SIZE * viewport_scale;
	vec4 displacement = texture(noise_tex, fract(UV - direction));
	float displacement_length = length(displacement.rgb);
	vec2 uv = SCREEN_UV + displacement.rg * intensity * displacement_length * 0.05;
	vec4 rain = vec4(texture(SCREEN_TEXTURE, uv).rgb, 1.0);
	
	color = rain;
	
	float distance_to_center = pow(length(UV - vec2(0.5)), (2.0-intensity) + 0.5 - vignette_strength/2.0) - 0.0;
	color.rgb = mix(color.rgb, -vec3(color.r/length(color.rgb), color.g/length(color.rgb), color.b/length(color.rgb)) * 1.2, distance_to_center);
	
	COLOR = color;
}
