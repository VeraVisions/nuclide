//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Dirty water shader (diffuse and normalmap only) where a refraction-ish effect
// is applied onto the diffusemap itself.
//==============================================================================

!!ver 110
!!permu FOG
!!samps diffuse normalmap

#include "sys/defs.h"

varying vec2 tex_c;
varying vec2 lm_c;
varying vec3 invsurface;
varying vec4 tf_c;
varying vec3 eyeminusvertex;
varying vec2 wat1_c;
varying vec2 wat2_c;

#ifdef VERTEX_SHADER
	void main(void)
	{
		invsurface = v_normal;
		eyeminusvertex = e_eyepos - v_position.xyz;

		tf_c = ftetransform();
		tex_c = v_texcoord;
		gl_Position = tf_c;
		
		wat1_c = tex_c + vec2(e_time * 0.05, 0.0);
		wat2_c = tex_c - vec2(0, e_time * 0.05);
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	void main(void)
	{
		vec3 norm_f;
		vec4 out_f = vec4(1.0, 1.0, 1.0, 1.0);
		vec2 wat3_c;

		// Use the normalmap to shift the refraction
		norm_f = (texture2D(s_normalmap, wat1_c).xyz);
		norm_f += (texture2D(s_normalmap, wat2_c).xyz);
		norm_f -= 1.0 - (4.0 / 256.0);
		norm_f = normalize(norm_f);

		wat3_c = tex_c + (norm_f.st * 0.025) + vec2(sin(e_time * 0.1), 0);

		// Load reflection and refraction based on our new coords
		out_f.rgb = texture2D(s_diffuse, wat3_c).rgb;

		gl_FragColor = fog4(out_f);
	}
#endif
