//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Lightmapped surface.
//
// diffusemap = albedo (rgba)
// normalmap = normal (rgb), reflectmask (a)
//==============================================================================

!!ver 110
!!permu FOG

!!permu BUMP
!!permu DELUXE
!!permu LIGHTSTYLED
!!permu FULLBRIGHT
!!samps diffuse 

!!samps lightmap
!!samps =BUMP normalmap reflectcube
!!samps =LIGHTSTYLED lightmap1 lightmap2 lightmap3
!!samps =DELUXE deluxemap
!!samps =LIGHTSTYLED =DELUXE deluxemap1 deluxemap2 deluxemap3
!!samps =FULLBRIGHT fullbright

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!cvardf r_fullbright
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipDiffuse
!!cvardf r_skipFullbright
!!cvardf r_skipNormal
!!cvardf r_skipEnvmap
!!cvardf r_skipLightmap

#include "sys/defs.h"

// basics
varying vec2 tex_c;
varying vec2 lm0;

// unfortunately we do support lightstyles
#if defined(LIGHTSTYLED)
varying vec2 lm1, lm2, lm3;
#endif

// useful for terrain blending
varying vec4 vex_color;

// dynamic shadows
#ifdef FAKESHADOWS
varying vec4 vtexprojcoord;
#endif

#ifdef BUMP
varying vec3 eyevector;
varying mat3 invsurface;
#endif

#ifdef VERTEX_SHADER
	void lightmapped_init(void)
	{
		lm0 = v_lmcoord;
	#if defined(LIGHTSTYLED)
		lm1 = v_lmcoord2;
		lm2 = v_lmcoord3;
		lm3 = v_lmcoord4;
	#endif
	}

	void main ()
	{
		lightmapped_init();
		tex_c = v_texcoord;
		vex_color = v_colour;
		gl_Position = ftetransform();
		
	#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
	#endif

	#ifdef BUMP
		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot(eyeminusvertex, v_svector.xyz);
		eyevector.y = dot(eyeminusvertex, v_tvector.xyz);
		eyevector.z = dot(eyeminusvertex, v_normal.xyz);
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
	#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

	#if defined(LIGHTSTYLED)
		#define LIGHTMAP0 texture2D(s_lightmap0, lm0).rgb
		#define LIGHTMAP1 texture2D(s_lightmap1, lm1).rgb
		#define LIGHTMAP2 texture2D(s_lightmap2, lm2).rgb
		#define LIGHTMAP3 texture2D(s_lightmap3, lm3).rgb
	#else
		#define LIGHTMAP texture2D(s_lightmap, lm0).rgb 
	#endif

#if r_skipLightmap == 0
	vec3 lightmap_fragment()
	{
		vec3 lightmaps;

#if defined(LIGHTSTYLED)
		lightmaps  = LIGHTMAP0 * e_lmscale[0].rgb;
		lightmaps += LIGHTMAP1 * e_lmscale[1].rgb;
		lightmaps += LIGHTMAP2 * e_lmscale[2].rgb;
		lightmaps += LIGHTMAP3 * e_lmscale[3].rgb;
#else
		lightmaps  = LIGHTMAP * e_lmscale.rgb;
#endif
		return (r_fullbright == 1) ? vec3(1.0, 1.0, 1.0) : lightmaps;
	}

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

		return (r_fullbright == 1) ? vec3(1.0, 1.0, 1.0) : lightmaps;
#endif
	}
#else
	vec3 lightmap_fragment()
	{
		return vec3(1.0,1.0,1.0);
	}
	vec3 lightmap_fragment(vec3 normal_f)
	{
		return vec3(1.0,1.0,1.0);
	}
#endif

	void main (void)
	{
		vec4 diffuse_f;
		float alpha;

		#if r_skipDiffuse == 0
			diffuse_f = texture2D(s_diffuse, tex_c);
		#else
			diffuse_f = vec4(1.0, 1.0, 1.0, 1.0);
		#endif

#ifdef MASK
		// alpha-testing happens here
		if (diffuse_f.a < MASK)
			discard;
#endif

		#ifdef FAKESHADOWS
			diffuse_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
		#endif

		// the lighting stage for the world
		#if defined(BUMP)

			// whether to respect our bump, or to act flat
			#if r_skipNormal == 0
				vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5);
				diffuse_f.rgb *= lightmap_fragment(normal_f);
			#else
				vec3 normal_f = vec3(0.0, 0.0, 1.0);
				diffuse_f.rgb *= lightmap_fragment();
			#endif

			// environment mapping happens here
			#if r_skipEnvmap == 0
				vec3 cube_c;
				vec3 env_f;
				float refl = texture2D(s_normalmap, tex_c).a;
				cube_c = reflect(normalize(-eyevector), normal_f.rgb);
				cube_c = cube_c.x * invsurface[0] + 
						 cube_c.y * invsurface[1] + 
						 cube_c.z * invsurface[2];
				cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;
				env_f = textureCube(s_reflectcube, cube_c).rgb * (e_lmscale.rgb * 0.25);
				diffuse_f.rgb = mix(env_f, diffuse_f.rgb, refl);
			#endif
		#else
			diffuse_f.rgb *= lightmap_fragment();
		#endif

		#if defined(FULLBRIGHT) && r_skipFullbright == 0
			diffuse_f.rgb += texture2D(s_fullbright, tex_c).rgb;
		#endif

		// start blend at half-way point
		alpha = vex_color.a * 1.5;

		if (alpha > 1.0)
			alpha = 1.0;

		gl_FragColor = vec4(fog3(diffuse_f.rgb), alpha);
	}
#endif
