//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Lightgrid-lit surface, normalmap's alpha contains specularity information.
//==============================================================================

!!ver 110
!!permu FRAMEBLEND
!!permu FOG
!!permu SKELETAL
!!cvarf gl_specular
!!samps diffuse fullbright normalmap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipDiffuse
!!cvardf r_skipSpecular
!!cvardf r_skipNormal

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 eyevector;
varying vec3 norm;
varying mat3 invsurface;

#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"
	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		norm = n;
		n = normalize(n);
		s = normalize(s);
		t = normalize(t);
		tex_c = v_texcoord;

		/* normalmap */
		invsurface = mat3(s, t, n);

		/* reflect */
		eyevector = e_eyepos - w.xyz;
		
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
	
	void main ()
	{
		vec4 fb_f = texture2D(s_fullbright, tex_c);
		vec3 new_e_light_dir = vec3(cos(e_time), sin(e_time), 0);
		vec3 light;

	#if r_skipDiffuse==0
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
	#else
		vec4 diffuse_f = vec4(1.0,1.0,1.0,1.0);
	#endif

	#if r_skipNormal==0
		vec3 normal_f = (texture2D(s_normalmap, tex_c).rgb - 0.5) * 2.0;
		float gloss = texture2D(s_normalmap, tex_c).a;
	#else
		#define normal_f vec3(0.0,0.0,1.0)
		float gloss = texture2D(s_normalmap, tex_c).a;
	#endif

		if (diffuse_f.a < 0.5) {
			discard;
		}

	#ifdef HALFLAMBERT
		light = e_light_ambient + (e_light_mul * halflambert(norm, e_light_dir));
	#else
		light = e_light_ambient + (e_light_mul * lambert(norm, e_light_dir));
	#endif

	#if r_skipSpecular==0
		vec3 halfdir = normalize(normalize(eyevector) + e_light_dir);
		vec3 bumps = normalize(invsurface * (normal_f));
		float spec = pow(max(dot(halfdir, bumps), 0.0), FTE_SPECULAR_EXPONENT);
		spec *= 5.0 * (1.0 - gloss);
		diffuse_f.rgb += spec;
	#endif

		diffuse_f.rgb *= light;
		diffuse_f.rgb += fb_f.rgb;

	#ifdef FAKESHADOWS
		diffuse_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

		gl_FragColor = fog4( diffuse_f * e_colourident ) * e_lmscale;
	}
#endif
