//======= Copyright (c) 2015-2021 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Skinned objects, aka rigged objects are handled here.
// Skeletal operations are performed on the GPU (hopefully) and we don't care
// about lightmaps, but query the engine for a dir + ambient term which may
// come from the lightgrid or not exist at all. At that point it should be
// the rtlight shader doing the major work though.
//==============================================================================

!!ver 100 150

!!permu FOG
!!permu BUMP
!!permu DELUXE
!!permu SPECULAR
!!permu FULLBRIGHT
!!permu FAKESHADOWS
!!permu OFFSETMAPPING
!!permu SKELETAL
!!permu UPPERLOWER

!!samps diffuse
!!samps =BUMP normalmap
!!samps =SPECULAR specular reflectcube
!!samps =FULLBRIGHT fullbright
!!samps =UPPERLOWER upper lower
!!samps =FAKESHADOWS shadowmap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvarf r_glsl_offsetmapping_scale
!!cvarf gl_specular

#ifndef FRESNEL
#define FRESNEL 0.25f
#endif

#include "sys/defs.h"

// always required
varying vec2 tc;
varying vec3 lightvector;
varying vec3 light;

// from this point forth, if we check for SPECULAR this means we're in PBR territory
#ifdef BUMP
varying vec3 eyevector;
varying mat3 invsurface;
#define PBR
#endif

// r_shadows 2
#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

// our basic vertex shader
#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	float lambert( vec3 normal, vec3 dir ) {
		return dot( normal, dir );
	}
	float halflambert( vec3 normal, vec3 dir ) {
		return ( dot( normal, dir ) * 0.5 ) + 0.5;
	}

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);

	#ifdef PBR
		vec3 eyeminusvertex = e_eyepos - w.xyz;
		eyevector.x = dot(eyeminusvertex, s.xyz);
		eyevector.y = dot(eyeminusvertex, t.xyz);
		eyevector.z = dot(eyeminusvertex, n.xyz);
		invsurface[0] = s;
		invsurface[1] = t;
		invsurface[2] = n;
	#endif

		light = e_light_ambient + (e_light_mul * lambert(n, e_light_dir));

		tc = v_texcoord;
		lightvector.x = dot(e_light_dir, s.xyz);
		lightvector.y = dot(e_light_dir, t.xyz);
		lightvector.z = dot(e_light_dir, n.xyz);
		
	#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
	#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"

	#if defined(SPECULAR)
	uniform float cvar_gl_specular;
	#endif

	#ifdef FAKESHADOWS
	#include "sys/pcf.h"
	#endif

	#ifdef OFFSETMAPPING
	#include "sys/offsetmapping.h"
	#endif

	float LightingFuncGGX(vec3 N, vec3 V, vec3 L, float roughness, float F0)
	{
		float alpha = roughness*roughness;

		vec3 H = normalize(V+L);

		float dotNL = clamp(dot(N,L), 0.0, 1.0);
		float dotLH = clamp(dot(L,H), 0.0, 1.0);
		float dotNH = clamp(dot(N,H), 0.0, 1.0);

		float F, D, vis;

		// D
		float alphaSqr = alpha*alpha;
		float pi = 3.14159f;
		float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
		D = alphaSqr/(pi * denom * denom);

		// F
		float dotLH5 = pow(1.0f-dotLH,5);
		F = F0 + (1.0-F0)*(dotLH5);

		// V
		float k = alpha/2.0f;
		float k2 = k*k;
		float invK2 = 1.0f-k2;
		vis = 1.0/(dotLH*dotLH*invK2 + k2);

		float specular = dotNL * D * F * vis;
		return specular;
	}

	void main ()
	{
	#ifdef OFFSETMAPPING
		vec2 tcoffsetmap = offsetmap(s_normalmap, tc, eyevector);
		#define tc tcoffsetmap
	#endif

		vec4 albedo_f = texture2D(s_diffuse, tc);

	#ifdef BUMP
		vec3 normal_f = normalize(texture2D(s_normalmap, tc).rgb - 0.5);
	#else
		vec3 normal_f = vec3(0.0, 0.0, 1.0);
	#endif

	#ifdef UPPER
		vec4 uc = texture2D(s_upper, tc);
		albedo_f.rgb += uc.rgb * e_uppercolour * uc.a;
	#endif

	#ifdef LOWER
		vec4 lc = texture2D(s_lower, tc);
		albedo_f.rgb += lc.rgb * e_lowercolour * lc.a;
	#endif

	#ifdef PBR
		float metalness_f = texture2D(s_specular, tc).r;
		float roughness_f = texture2D(s_specular, tc).g;
		float ao = texture2D(s_specular, tc).b;

		/* coords */
		vec3 cube_c;

		/* calculate cubemap texcoords */
		cube_c = reflect(-normalize(eyevector), normal_f.rgb);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;

		/* do PBR reflection using cubemap */
		gl_FragColor = albedo_f + (metalness_f * textureCube(s_reflectcube, cube_c));

		/* do PBR specular using our handy function */
		gl_FragColor += (LightingFuncGGX(normal_f, normalize(eyevector), normalize(lightvector), roughness_f, FRESNEL) * gl_FragColor);
	#else
		gl_FragColor = albedo_f;
	#endif

		/* this isn't necessary if we're not doing lightgrid terms */
		gl_FragColor.rgb *= light;

		/* r_shadows 2 */
	#ifdef FAKESHADOWS
		gl_FragColor.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

	#ifdef PBR
		gl_FragColor.rgb *= ao;
	#endif

	#ifdef FULLBRIGHT
		vec4 fb = texture2D(s_fullbright, tc);
		gl_FragColor.rgb += fb.rgb * fb.a * e_glowmod.rgb;
	#endif

		gl_FragColor = fog4(gl_FragColor * e_colourident);
	}
#endif
