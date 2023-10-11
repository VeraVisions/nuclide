//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Lightgrid-lit surface, normalmap's alpha contains environment cube reflec-
// tivity.
//==============================================================================

!!ver 110
!!permu FRAMEBLEND
!!permu FULLBRIGHT
!!permu FOG
!!permu BUMP
!!permu SKELETAL
!!samps diffuse
!!samps =BUMP normalmap reflectcube
!!samps =FULLBRIGHT fullbright

!!cvardf r_skipDiffuse
!!cvardf r_skipFullbright
!!cvardf r_skipNormal
!!cvardf r_skipEnvmap
!!cvardf r_skipLightmap
!!cvardf r_showEnvCubemap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!cvardf r_fullbright
!!cvardf r_lambertscale
!!samps =FAKESHADOWS shadowmap

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 norm;

#ifdef BUMP
varying vec3 eyevector;
varying mat3 invsurface;
#endif

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

		#ifdef BUMP
		/* normalmap */
		invsurface = mat3(s, t, n);

		/* reflect */
		vec3 eyeminusvertex = e_eyepos - w.xyz;
		eyevector.x = dot(eyeminusvertex, s.xyz);
		eyevector.y = dot(eyeminusvertex, t.xyz);
		eyevector.z = dot(eyeminusvertex, n.xyz);
		#endif

		#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
		#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

#ifdef HALFLAMBERT
	float lambert(vec3 normal, vec3 dir)
	{
		return (lambert(normal, dir) * 0.5) + 0.5;
	}
#else
	float lambert(vec3 normal, vec3 dir)
	{
		return max(dot(normal, dir), 0.0);
	}
#endif

	void main (void)
	{
		vec4 diff_f = vec4(1.0, 1.0, 1.0, 1.0);
		vec3 light = vec3(0.0, 0.0, 0.0);

		#if r_skipDiffuse == 0
			diff_f = texture2D(s_diffuse, tex_c);
		#endif

		// bump goes here
		#if r_skipNormal==0 || defined(BUMP)
			vec3 normal_f = (texture2D(s_normalmap, tex_c).rgb - 0.5) * 2.0;
		#else
			vec3 normal_f = vec3(0.0, 0.0, 1.0);
		#endif

		#ifdef MASK
		if (diff_f.a < MASK) {
			discard;
		}
		#endif

		/* directional light */
		light += (e_light_mul * lambert(norm, e_light_dir)) * 2.0;
		light += (e_light_ambient * lambert(norm, reflect(norm, e_light_dir))) * 0.5;
		light += (e_light_mul * dot(normal_f, e_light_dir));

	#ifdef FAKESHADOWS
		diff_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif
		diff_f.rgb *= light;
	
	#if defined(BUMP) && r_skipEnvmap==0
		vec3 cube_c;
		#if r_showEnvCubemap == 0
			float refl = 1.0 - texture2D(s_normalmap, tex_c).a;
		#else
			float refl = 1.0;
		#endif
		cube_c = reflect(normalize(eyevector), normal_f.rgb);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;
		diff_f.rgb += textureCube(s_reflectcube, cube_c).rgb * refl;
	#endif

	#if defined(FULLBRIGHT) && r_skipFullbright==0
		diff_f.rgb += texture2D(s_fullbright, tex_c).rgb;
	#endif

		gl_FragColor = fog4(diff_f * e_colourident) * e_lmscale;
	}
#endif
