!!ver 110
!!samps diffuse lightmap reflectcube normalmap

#include "sys/defs.h"

varying vec2 tex_c;
varying vec2 lm_c;

#ifdef REFLECTCUBE
varying vec3 eyevector;
varying mat3 invsurface;
#endif

#ifdef VERTEX_SHADER
	void main ()
	{
		tex_c = v_texcoord;
		lm_c = v_lmcoord;
		gl_Position = ftetransform();
		
#ifdef REFLECTCUBE
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot( eyeminusvertex, v_svector.xyz );
		eyevector.y = dot( eyeminusvertex, v_tvector.xyz );
		eyevector.z = dot( eyeminusvertex, v_normal.xyz );
#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	void main ( void )
	{
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
		vec3 light = texture2D(s_lightmap, lm_c).rgb * e_lmscale.rgb;

#ifdef REFLECTCUBE
	#ifdef BUMP
		#ifndef FLATTENNORM
			vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5);
		#else
			// For very flat surfaces and gentle surface distortions, the 8-bit precision per channel in the normalmap
			// can be insufficient. This is a hack to instead have very wobbly normalmaps that make use of the 8 bits
			// and then scale the wobblyness back once in the floating-point domain.
			vec3 normal_f = texture2D(s_normalmap, tex_c).rgb - 0.5;
			normal_f.x *= 0.0625;
			normal_f.y *= 0.0625;
			normal_f = normalize(normal_f);
		#endif
	#else
			vec3 normal_f = vec3(0, 0, 1);
	#endif
		vec3 cube_c;
		vec4 out_f = vec4( 1.0, 1.0, 1.0, 1.0 );
		diffuse_f.rgb *= light.rgb;

		cube_c = reflect( normalize(-eyevector), normal_f);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = ( m_model * vec4(cube_c.xyz, 0.0)).xyz;
		out_f.rgb = mix( textureCube(s_reflectcube, cube_c ).rgb, diffuse_f.rgb, diffuse_f.a);
		diffuse_f = out_f;
#else
		diffuse_f.rgb *= light.rgb;
#ifdef MASK
		if (diffuse_f.a < e_colourident.a) {
			discard;
		}
#endif
#endif
		diffuse_f *= e_colourident;

		gl_FragColor = diffuse_f;
		
	}
#endif
