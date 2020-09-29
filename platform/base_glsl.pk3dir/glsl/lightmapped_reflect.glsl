//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Lightmapped surface that effectively acts as a mirror.
// Alpha channel of the diffusemap is referenced for reflectivity.
//==============================================================================

!!ver 110
!!permu FOG
!!permu BUMP
!!permu DELUXE
!!samps diffuse lightmap deluxemap reflection

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

#include "sys/defs.h"

varying vec2 tex_c;
varying mat3 invsurface;
varying vec4 tf;

varying vec2 lm0;
#ifdef LIGHTSTYLED
varying vec2 lm1, lm2, lm3;
#endif

#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

#ifdef VERTEX_SHADER
	void lightmapped_init(void)
	{
		lm0 = v_lmcoord;
		#ifdef LIGHTSTYLED
		lm1 = v_lmcoord2;
		lm2 = v_lmcoord3;
		lm3 = v_lmcoord4;
		#endif
	}

	void main (void)
	{
		lightmapped_init();
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;

		tf = ftetransform();
		tex_c = v_texcoord;
		gl_Position = tf;
		
		#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
		#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

	#define s_reflect s_t0

	vec3 lightmap_fragment()
	{
		vec3 lightmaps;

#ifdef LIGHTSTYLED
		lightmaps  = texture2D(s_lightmap0, lm0).rgb * e_lmscale[0].rgb;
		lightmaps += texture2D(s_lightmap1, lm1).rgb * e_lmscale[1].rgb;
		lightmaps += texture2D(s_lightmap2, lm2).rgb * e_lmscale[2].rgb;
		lightmaps += texture2D(s_lightmap3, lm3).rgb * e_lmscale[3].rgb;
#else
		lightmaps  = texture2D(s_lightmap, lm0).rgb * e_lmscale.rgb;
#endif
		return lightmaps;
	}

	vec3 lightmap_fragment (vec3 normal_f)
	{
		vec3 lightmaps;

#ifdef LIGHTSTYLED
		lightmaps  = texture2D(s_lightmap0, lm0).rgb * e_lmscale[0].rgb * dot(normal_f, (texture2D(s_deluxemap0, lm0).rgb - 0.5) * 2.0);
		lightmaps += texture2D(s_lightmap1, lm1).rgb * e_lmscale[1].rgb * dot(normal_f, (texture2D(s_deluxemap1, lm1).rgb - 0.5) * 2.0);
		lightmaps += texture2D(s_lightmap2, lm2).rgb * e_lmscale[2].rgb * dot(normal_f, (texture2D(s_deluxemap2, lm2).rgb - 0.5) * 2.0);
		lightmaps += texture2D(s_lightmap3, lm3).rgb * e_lmscale[3].rgb * dot(normal_f, (texture2D(s_deluxemap3, lm3).rgb - 0.5) * 2.0);
#else
		lightmaps  = texture2D(s_lightmap, lm0).rgb * e_lmscale.rgb * dot(normal_f, (texture2D(s_deluxemap, lm0).rgb - 0.5) * 2.0);
#endif
		return lightmaps;
	}

	void main (void)
	{
		vec2 stc;
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
		vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5);

		/* modulate the final pixel with the lightmap value */
		if (float(dev_skipnormal) == 1.0) {
			diffuse_f.rgb *= lightmap_fragment();
		} else {
			diffuse_f.rgb *= lightmap_fragment(normal_f);
		}

		/* map the reflection buffer onto the surface */
		stc = (1.0 + (tf.xy / tf.w)) * 0.5;
		stc.t -= 1.5* invsurface[2].z / 1080.0;

		diffuse_f.rgb = mix(texture2D(s_reflection, stc).rgb, diffuse_f.rgb, diffuse_f.a);
		diffuse_f.a = 1.0;

		#ifdef FAKESHADOWS
		diffuse_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
		#endif

		gl_FragColor = fog4(diffuse_f);
	}
#endif
