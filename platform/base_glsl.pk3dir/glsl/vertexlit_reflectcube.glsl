//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Lightgrid-lit surface, normalmap's alpha contains environment cube reflec-
// tivity.
//==============================================================================

!!ver 110
!!permu FRAMEBLEND
!!permu FOG
!!permu SKELETAL
!!samps diffuse reflectcube normalmap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

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
		vec3 eyeminusvertex = e_eyepos - w.xyz;
		eyevector.x = dot(eyeminusvertex, s.xyz);
		eyevector.y = dot(eyeminusvertex, t.xyz);
		eyevector.z = dot(eyeminusvertex, n.xyz);
		
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
		vec3 cube_c;
		vec4 out_f = vec4(1.0, 1.0, 1.0, 1.0);
		vec4 diff_f = texture2D(s_diffuse, tex_c);
		vec3 light;

	#if r_skipNormal==0
		vec3 normal_f = (texture2D(s_normalmap, tex_c).rgb - 0.5) * 2.0;
		float refl = texture2D(s_normalmap, tex_c).a;
	#else
		#define normal_f vec3(0.0,0.0,1.0)
		float refl = texture2D(s_normalmap, tex_c).a;
	#endif

		if (diff_f.a < 0.5) {
			discard;
		}

	#ifdef HALFLAMBERT
		light = e_light_ambient + (e_light_mul * halflambert(norm, e_light_dir));
	#else
		light = e_light_ambient + (e_light_mul * lambert(norm, e_light_dir));
	#endif

	#if r_skipSpecular==0
		cube_c = reflect(normalize(eyevector), normal_f.rgb);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;
		diff_f.rgb = mix(textureCube(s_reflectcube, cube_c).rgb, diff_f.rgb, diff_f.a);
	#endif

		diff_f.rgb *= light;
		out_f.rgb = mix(textureCube(s_reflectcube, cube_c).rgb, diff_f.rgb, refl);

	#ifdef FAKESHADOWS
		out_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

		gl_FragColor = fog4(out_f * e_colourident) * e_lmscale;
	}
#endif
