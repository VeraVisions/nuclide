//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Terrain shader exclusive to tw_valley. One of the few surfaces that do not
// draw a normalmap as it's too expensive.
//==============================================================================

!!ver 110
!!permu FOG
!!samps 6

!!samps lightmap
!!samps =LIGHTSTYLED lightmap1 lightmap2 lightmap3
!!samps =DELUXE deluxemap
!!samps =LIGHTSTYLED =DELUXE deluxemap1 deluxemap2 deluxemap3

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipDiffuse
!!cvardf r_skipNormal
!!cvardf r_skipLightmap

#include "sys/defs.h"

varying vec2 tex_c;
varying vec2 detail_c;
varying vec4 vex_color;

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

	void main ( void )
	{
		lightmapped_init();
		tex_c = v_texcoord * 2.5;
		detail_c = tex_c * 7.5;
		vex_color = v_colour;
		gl_Position = ftetransform();
		
		#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
		#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

#if r_skipLightmap==0
	#ifdef LIGHTSTYLED
		#define LIGHTMAP0 texture2D(s_lightmap0, lm0).rgb
		#define LIGHTMAP1 texture2D(s_lightmap1, lm1).rgb
		#define LIGHTMAP2 texture2D(s_lightmap2, lm2).rgb
		#define LIGHTMAP3 texture2D(s_lightmap3, lm3).rgb
	#else
		#define LIGHTMAP texture2D(s_lightmap, lm0).rgb 
	#endif
#else
	#ifdef LIGHTSTYLED
		#define LIGHTMAP0 vec3(0.5,0.5,0.5)
		#define LIGHTMAP1 vec3(0.5,0.5,0.5)
		#define LIGHTMAP2 vec3(0.5,0.5,0.5)
		#define LIGHTMAP3 vec3(0.5,0.5,0.5)
	#else
		#define LIGHTMAP vec3(0.5,0.5,0.5)
	#endif
#endif

	vec3 lightmap_fragment()
	{
		vec3 lightmaps;

#ifdef LIGHTSTYLED
		lightmaps  = LIGHTMAP0 * e_lmscale[0].rgb;
		lightmaps += LIGHTMAP1 * e_lmscale[1].rgb;
		lightmaps += LIGHTMAP2 * e_lmscale[2].rgb;
		lightmaps += LIGHTMAP3 * e_lmscale[3].rgb;
#else
		lightmaps  = LIGHTMAP * e_lmscale.rgb;
#endif
		return lightmaps;
	}

#if r_skipNormal==0
	vec3 lightmap_fragment(vec3 normal_f)
	{
#ifndef DELUXE
		return lightmap_fragment();
#else
		vec3 lightmaps;

	#if defined(LIGHTSTYLED)
		lightmaps  = LIGHTMAP0 * e_lmscale[0].rgb * dot(normal_f, (texture2D(s_deluxemap0, lm0).rgb - 0.5) * 2.0);
		lightmaps += LIGHTMAP1 * e_lmscale[1].rgb * dot(normal_f, (texture2D(s_deluxemap1, lm1).rgb - 0.5) * 2.0);
		lightmaps += LIGHTMAP2 * e_lmscale[2].rgb * dot(normal_f, (texture2D(s_deluxemap2, lm2).rgb - 0.5) * 2.0);
		lightmaps += LIGHTMAP3 * e_lmscale[3].rgb * dot(normal_f, (texture2D(s_deluxemap3, lm3).rgb - 0.5) * 2.0);
	#else 
		lightmaps  = LIGHTMAP * e_lmscale.rgb * dot(normal_f, (texture2D(s_deluxemap, lm0).rgb - 0.5) * 2.0);
	#endif

		return lightmaps;
#endif
	}
#endif

	void main ( void )
	{
		vec4 diff1_f = texture2D(s_t0, tex_c);
		vec4 diff2_f = texture2D(s_t1, tex_c);
		vec3 norm1_f = normalize(texture2D(s_t4, tex_c).rgb - 0.5);
		vec3 norm2_f = normalize(texture2D(s_t5, tex_c).rgb - 0.5);

		vec3 d1_f = texture2D(s_t2, detail_c).rgb;
		vec3 d2_f = texture2D(s_t3, detail_c).rgb;
		diff1_f.rgb *= d1_f;
		diff2_f.rgb *= d2_f;

		if (float(r_skipNormal) == 1.0) {
			diff1_f.rgb *= lightmap_fragment();
			diff2_f.rgb *= lightmap_fragment();
		} else {
			diff1_f.rgb *= lightmap_fragment(norm1_f);
			diff2_f.rgb *= lightmap_fragment(norm2_f);
		}

		vec3 output_f = mix( diff1_f.rgb, diff2_f.rgb, vex_color.a );

		#ifdef FAKESHADOWS
		output_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
		#endif

		gl_FragColor = fog4( vec4( output_f.rgb, 1.0 ) );
	}
#endif
