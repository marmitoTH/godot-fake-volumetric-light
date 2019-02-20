shader_type spatial;
render_mode blend_add, cull_disabled, unshaded;

uniform sampler2D dust : hint_albedo;
uniform float dust_speed = 0.03;
uniform vec4 color : hint_color;
uniform float intensity = 2.75;
uniform float softness = 3.0;

// Godot built in distance fade from camera and others geometry
uniform float proximity_fade_distance = .5;
uniform float distance_fade_min = 1;
uniform float distance_fade_max = 2;

varying vec3 obj_vertex; // Model Space Vertex

void vertex ()
{
	obj_vertex = VERTEX; // Take object space vertex position before conversion
}

void fragment ()
{
	// My Stuff
	vec2 dust_uv = vec2(SCREEN_UV.x + dust_speed * TIME, SCREEN_UV.y);
	vec4 dust_overlay = texture(dust, dust_uv);
	float attenuation = clamp(1.0 + obj_vertex.y / intensity, 0, 1.0);
	float soft_edge = clamp(pow(dot(NORMAL, normalize(VERTEX)), softness), 0, 1.0);
	
	ALBEDO = dust_overlay.rgb * color.rgb * attenuation * soft_edge;
	
	// Godot Stuff
	float depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
	world_pos.xyz /= world_pos.w;

	ALPHA *= clamp(1.0 - smoothstep(world_pos.z + proximity_fade_distance, world_pos.z, VERTEX.z), 0.0, 1.0);
	ALPHA *= clamp(smoothstep(distance_fade_min, distance_fade_max, -VERTEX.z), 0.0, 1.0);
}