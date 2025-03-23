shader_type spatial;
render_mode cull_disabled;

uniform vec4 albedo1 : source_color;
uniform vec4 albedo2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;

uniform vec3 player_pos[10];
uniform float interact_power = 0.5;
uniform float radius = 1.0;

varying vec3 world_vert;

void vertex() {
	world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	for (int i = 0; i < player_pos.length(); i++) {
		if(player_pos[i] == vec3(0,0,0)){
			continue;
		}
		vec3 direction = world_vert - player_pos[i];
		direction.y = 0.0;
		direction = normalize(direction);
		float dist = distance(player_pos[i], world_vert);
		float power = smoothstep(radius, 0.0, dist);
		direction = (vec4(direction, 1.0) * MODEL_MATRIX).xyz;
		VERTEX += direction * power * interact_power * (1.0 - UV.y);
	}
}

void fragment() {
	vec3 noiseLevel = texture(noise,world_vert.xz / noiseScale).rgb;
	ALBEDO = mix(albedo1.rgb,albedo2.rgb,UV.y) * mix(albedo1.rgb,albedo2.rgb, noiseLevel.r);
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}