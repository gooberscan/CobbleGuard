module ssao;

static const uint SSAO_KERNEL_SIZE = 16;

// determines how much larger slopes within objects are tolerated 
static const float k_depth_delta = 0.0078125;

struct SSAOInput {
    float4x4 view;
    float4x4 projection;
    float3 samples[SSAO_KERNEL_SIZE];
    float ssao_intensity;
    float ssao_bias;
    float ssao_radius;

    Sampler2D position_texture;
    Sampler2D normal_texture;
    Sampler2D noise_texture;
}

[shader("fragment")]
float4 ssao(float2 uv_coords: UV, ParameterBlock<SSAOInput> ssao_block) {
	// in view-space
	float3 gbuffer_position = mul(ssao_block.view, ssao_block.position_texture.Sample(uv_coords.xy)).xyz;
	float3 gbuffer_normal = normalize(ssao_block.normal_texture.Sample(uv_coords.xy).rgb);

	int2 gbuffer_size;
	int2 noise_size;

    ssao_block.position_texture.GetDimensions(gbuffer_size.x, gbuffer_size.y);
    ssao_block.noise_texture.GetDimensions(noise_size.x, noise_size.y);

	// mapping gbuffer uv coords to noise uv coords
	// (0.5, 0.75) -> (960, 810) / (512, 512) = (1.875, 1.58)
	// noise texture repeats
	float2 gbuffer_pixel = gbuffer_size * uv_coords.xy;
	float2 noise_uv = gbuffer_pixel / float2(4, 4);

    // Get a random vector using a noise lookup
    // ([0, 1), [0, 1), [0, 1))
    float3 random_vector = float3(ssao_block.noise_texture.Sample(noise_uv).xy, 0);

	// random vector is now ([-1, 1), [-1, 1))
	random_vector.xy = (2.0 * random_vector.xy) - 1;
	random_vector.xy = normalize(random_vector.xy);

	// construct a TBN matrix from our random_vector projecting our random vector onto the normal vector
	// using graham schdmit
	float3 tangent = normalize(random_vector - (gbuffer_normal * dot(random_vector, gbuffer_normal)));
	float3 bitangent = cross(tangent, gbuffer_normal);
	float3x3 tbn_matrix = float3x3(tangent, bitangent, gbuffer_normal);

	float occlusion_sum = 0.0f;
	for(int i = 0; SSAO_KERNEL_SIZE > i; ++i) {
		float3 base_sample_pos = mul(tbn_matrix, ssao_block.samples[i]);
		float3 sample_pos = gbuffer_position + (ssao_block.ssao_radius * base_sample_pos);
		
		// this should be a vector, oriented by some rotated normal
		float4 texture_offset = float4(sample_pos, 1.0);

		texture_offset = mul(ssao_block.projection, texture_offset);
		texture_offset.xyz /= texture_offset.w;
		texture_offset.xyz = (texture_offset.xyz * 0.5) + 0.5;

		float sampled_depth = mul(ssao_block.view, ssao_block.position_texture.Sample(texture_offset.xy)).z;
		float range_check = smoothstep(0, 1, ssao_block.ssao_radius / abs(gbuffer_position.z - sampled_depth));
		
		// if we see that our sample's depth is occluded, then we are occluded
		occlusion_sum += (sampled_depth >= (sample_pos.z + ssao_block.ssao_bias) ? 1 : 0) * range_check;
	}

	float weighted_occlusion = occlusion_sum / SSAO_KERNEL_SIZE;
	float visibility = max(1 - (ssao_block.ssao_intensity * weighted_occlusion), 0);

	return float4(visibility, float3(0));
}
