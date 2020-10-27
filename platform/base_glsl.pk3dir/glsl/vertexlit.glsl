//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Basic lightgrid-lit surface. Also supports a fullbrightmap.
//==============================================================================

!!ver 110
!!permu FRAMEBLEND
!!permu BUMP
!!permu FOG
!!permu SKELETAL
!!samps diffuse fullbright normalmap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipDiffuse

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 norm;

#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	void main (void)
	{
		vec3 n, s, t, w;
		tex_c = v_texcoord;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		norm = n;
		
		#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
		#endif
	}
#endif


#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

	float lambert(vec3 normal, vec3 dir)
	{
		return max(dot(normal, dir), 0.0);
	}

	float halflambert(vec3 normal, vec3 dir)
	{
		return (lambert(normal, dir) * 0.5) + 0.5;
	}

	void main (void)
	{
		vec4 diff_f = texture2D(s_diffuse, tex_c);
		vec4 fb_f = texture2D(s_fullbright, tex_c);
		vec3 light;

		if (diff_f.a < 0.5) {
			discard;
		}

	#ifdef HALFLAMBERT
		light = e_light_ambient + (e_light_mul * halflambert(norm, e_light_dir));
	#else
		light = e_light_ambient + (e_light_mul * lambert(norm, e_light_dir));
	#endif

		diff_f.rgb *= light;
		diff_f.rgb += fb_f.rgb;

	#ifdef FAKESHADOWS
		diff_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

		gl_FragColor = fog4(diff_f * e_colourident) * e_lmscale;
	}
#endif
