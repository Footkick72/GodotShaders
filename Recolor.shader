shader_type canvas_item;

// Copyright 2021 Daniel Long
// This file is availiable under the MIT Liscence

uniform float grey_amount: hint_range(0,1) = 0.25;

void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	
	vec3 greyscale = vec3((color.r + color.g + color.b)/3.0);
	color.rgb = mix(greyscale, color.rgb, grey_amount);
	
	COLOR = color;
}
