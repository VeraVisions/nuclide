//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Lightmapped surface that will use its normalmap alpha for both specularity
// as well as environment cube reflectivity.
//==============================================================================

!!ver 110
!!permu FOG
!!permu BUMP
!!permu DELUXE
!!samps diffuse normalmap lightmap deluxemap reflectcube

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipNormal
!!cvardf r_skipSpecular

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 eyevector;
varying mat3 invsurface;

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

		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot(eyeminusvertex, v_svector.xyz);
		eyevector.y = dot(eyeminusvertex, v_tvector.xyz);
		eyevector.z = dot(eyeminusvertex, v_normal.xyz);

		tex_c = v_texcoord;
		gl_Position = ftetransform();
		
		#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
		#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

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

#if r_skipNormal==0
	vec3 lightmap_fragment(vec3 normal_f)
	{
#ifndef DELUXE
		return lightmap_fragment();
#else
		vec3 lightmaps;

	#if defined(LIGHTSTYLED)
		lightmaps  = texture2D(s_lightmap0, lm0).rgb * e_lmscale[0].rgb * dot(normal_f, (texture2D(s_deluxemap0, lm0).rgb - 0.5) * 2.0);
		lightmaps += texture2D(s_lightmap1, lm1).rgb * e_lmscale[1].rgb * dot(normal_f, (texture2D(s_deluxemap1, lm1).rgb - 0.5) * 2.0);
		lightmaps += texture2D(s_lightmap2, lm2).rgb * e_lmscale[2].rgb * dot(normal_f, (texture2D(s_deluxemap2, lm2).rgb - 0.5) * 2.0);
		lightmaps += texture2D(s_lightmap3, lm3).rgb * e_lmscale[3].rgb * dot(normal_f, (texture2D(s_deluxemap3, lm3).rgb - 0.5) * 2.0);
	#else 
		lightmaps  = texture2D(s_lightmap, lm0).rgb * e_lmscale.rgb * dot(normal_f, (texture2D(s_deluxemap, lm0).rgb - 0.5) * 2.0);
	#endif

		return lightmaps;
#endif
	}
#endif

	void main (void)
	{
		vec3 cube_c;
		vec4 out_f = vec4(1.0, 1.0, 1.0, 1.0);

	#if r_skipDiffuse==0
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
	#else
		#define diffuse_f vec4(1.0, 1.0, 1.0, 1.0)
	#endif

	#if r_skipNormal==1
		vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5);
	#else
		#define normal_f vec3(0.0,0.0,0.5)
	#endif

		float gloss = texture2D(s_normalmap, tex_c).a;
		float spec;

		vec3 halfdir = normalize(normalize(eyevector) - e_light_dir);
		spec = pow(max(dot(halfdir, normal_f), 0.0), FTE_SPECULAR_EXPONENT);
		spec *= (gloss * 0.1);

	#if r_skipNormal==1
		diffuse_f.rgb *= lightmap_fragment();
	#else
		diffuse_f.rgb *= lightmap_fragment(normal_f);
	#endif

	#ifdef FAKESHADOWS
		diffuse_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

	#if r_skipSpecular==0
		cube_c = reflect(normalize(-eyevector), normal_f.rgb);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;
		out_f.rgb = mix(textureCube(s_reflectcube, cube_c).rgb, diffuse_f.rgb, gloss);
	#endif

		out_f.rgb += spec;

		gl_FragColor = fog4(out_f);
	}
#endif
