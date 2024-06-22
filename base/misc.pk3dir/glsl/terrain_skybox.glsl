//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Terrain shader used for skyroom surfaces.
//==============================================================================

!!ver 110
!!permu FOG
!!permu BUMP
!!permu DELUXE
!!samps 4 diffuse

!!samps lightmap
!!samps =LIGHTSTYLED lightmap1 lightmap2 lightmap3
!!samps =DELUXE deluxemap
!!samps =LIGHTSTYLED =DELUXE deluxemap1 deluxemap2 deluxemap3
!!cvardf r_skipLightmap

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 tex_c;
varying vec4 vex_color;

varying vec2 lm0;
#ifdef LIGHTSTYLED
varying vec2 lm1, lm2, lm3;
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

	void main ()
	{
		tex_c = v_texcoord;
		lm_c = v_lmcoord;
		vex_color = v_colour;
		gl_Position = ftetransform();
	}
#endif

#ifdef FRAGMENT_SHADER
	vec3 lightmap_fragment()
	{
		vec3 lightmaps;

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

	void main ()
	{
		vec4 diff1_f = texture2D( s_t0, tex_c );
		vec4 diff2_f = texture2D( s_t1, tex_c );
		vec3 output_f = mix( diff1_f.rgb, diff2_f.rgb, vex_color.a ) * lightmap_fragment(normal_f);
		gl_FragColor = fog4( vec4( output_f.rgb, 1.0 ) );
	}
#endif
