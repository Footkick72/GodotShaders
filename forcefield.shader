shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float health : hint_range(0.0, 1.0) = 1.0; // shield health
uniform float offset = 0.0; // depth-based edge detection bias
uniform float fresnell_power = 8.0; // strength of fresnell; edge width
uniform vec4 color : hint_color = vec4(0.0, 0.7, 0.9, 1.0); // shield color
uniform float natural_thickness : hint_range(0.0, 1.0) = 0.05; // opacity of center texture
uniform float tex_scroll_speed = 0.1; // border scroll rate
uniform float tex_tile_scale = 0.2; // border texture tiling
uniform float const_brightness_mult : hint_range(0.0, 1.0) = 0.2; // alpha multiplier
uniform float activated: hint_range(0.0, 1.0) = 1.0; // activation animation
uniform sampler2D noise; // center texture noise
uniform sampler2D tex; // border texture

varying float activation_alpha;

void vertex() {
	if (UV.y >= 1.001*activated) {
		activation_alpha = 0.0;
	} else {
		activation_alpha = 1.0;
	}
}

void fragment() {
	// reads from depth texture
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	
	// linearizes depth (read docs aboud DEPTH_TEXTURE for more info)
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	// applies bias to edge detection
	linear_depth -= offset;
	
	// gets fragment depth
	float screen_depth = 1.0/FRAGCOORD.a;
	
	// v proportional to distance between fragment depth and background depth 
	float v = 1.0 - (linear_depth - screen_depth);
	
	// apply color
	ALBEDO = color.xyz * 2.0;
	
	//calulate fresnell effect
	float fresnell = pow((1.0 - dot(normalize(NORMAL), normalize(VIEW))), fresnell_power) * fresnell_power;
	
	// compute final alpha from factors
	//ALPHA = smoothstep(0.0, 1.0, v); //USE THIS LINE INSTEAD IF FOLLOWING LINE DOESN'T WORK FOR YOUR VALUES ITS A HACK TO BETTER BALANCE THE FRESNELL WITH THE EDGE LIGHTING
	ALPHA = pow(smoothstep(0.0, 1.0, v), max(1, fresnell_power * 4.0)) * fresnell_power * 4.0;
	fresnell *= texture(tex, UV * (1.0/tex_tile_scale) + TIME * tex_scroll_speed).r; // overlay border texture
	ALPHA += fresnell; // fresnell 
	ALPHA += natural_thickness * (texture(noise, vec2(UV + TIME * 0.1)).r * 2.0); // fill center
	
	// damage effect
	float damage = (texture(noise, UV + TIME * 0.1).r);
	if (damage > (1.0 - health) * 0.53 + 0.23 && damage < pow((1.0 - health) * 0.53 + 0.23, 0.98)) {
		ALPHA += damage * 5.0; // borders of damage
	}
	if (damage < (1.0 - health) * 0.53 + 0.23) {
		ALPHA = 0.0;
	}
	
	// clamp and scale alpha
	ALPHA = ALPHA * const_brightness_mult;
	ALPHA = clamp(ALPHA, 0.0, 1.0);
	
	ALPHA *= activation_alpha; // activation animation
}