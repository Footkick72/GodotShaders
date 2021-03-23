shader_type canvas_item;

// Copyright 2021 Daniel Long
// This file is availiable under the MIT License

uniform vec2 player_pos;
uniform vec2 viewport_scale;
const float radius = 150.0;

void fragment() {
	vec2 real_player_pos = player_pos * viewport_scale;
	vec4 color = textureLod(TEXTURE, UV, 0.0);
	float dist_to_player = length(FRAGCOORD.xy - real_player_pos) / radius;
	if (dist_to_player < 1.0) {
		color.a = min(color.a, clamp(pow(dist_to_player, 5), 0, 1.0));
	}
	COLOR = color;
}
