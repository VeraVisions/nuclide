//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Lightmapped surface with specular highlighting. It'll assume a base value 
// for specularity... this is if you want to save VRAM but really want a glow.
//==============================================================================

!!ver 110
!!permu FOG
!!permu BUMP
!!permu DELUXE
!!samps diffuse normalmap lightmap deluxemap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipNormal
!!cvardf r_skipSpecular
!!cvardf r_skipLightmap

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 eyevector;

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

	void main ()
	{
		lightmapped_init();
		tex_c = v_texcoord;

		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot(eyeminusvertex, v_svector.xyz);
		eyevector.y = dot(eyeminusvertex, v_tvector.xyz);
		eyevector.z = dot(eyeminusvertex, v_normal.xyz);
		
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

	void main (void)
	{
		float gloss = texture2D(s_normalmap, tex_c).a * 0.1;
		float spec;

	#if r_skipDiffuse==0
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
	#else
		#define diffuse_f vec4(1.0, 1.0, 1.0, 1.0)
	#endif

	#if r_skipNormal==0
		vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5);
	#else
		#define normal_f vec3(0.0,0.0,0.5)
	#endif

		if (diffuse_f.a < 0.5) {
			discard;
		}

	#ifdef FAKESHADOWS
		diffuse_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

	#if r_skipNormal==1
		diffuse_f.rgb *= lightmap_fragment();
	#else
		diffuse_f.rgb *= lightmap_fragment(normal_f);
	#endif

	#if r_skipSpecular==0
		vec3 halfdir = normalize(normalize(eyevector) - e_light_dir);
		spec = pow(max(dot(halfdir, normal_f), 0.0), FTE_SPECULAR_EXPONENT);
		spec *= 0.05;
		diffuse_f.rgb += spec;
	#endif

		gl_FragColor = fog4(diffuse_f);
	}
#endif
