!!ver 110
!!samps diffuse lightmap reflectcube normalmap
!!cvardf gl_fake16bit=0
!!cvardf gl_monochrome=0
!!cvardf gl_brighten=0

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
		vec3 light = texture2D(s_lightmap, lm_c).rgb;

		if (diffuse_f.rgb == vec3(0,0,1)) {
			diffuse_f.rgb = vec3(0,0,0);
			discard;
		}

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
		diffuse_f.rgb *= light.rgb * e_lmscale.rgb;

		cube_c = reflect( normalize(-eyevector), normal_f);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = ( m_model * vec4(cube_c.xyz, 0.0)).xyz;
		out_f.rgb = mix( textureCube(s_reflectcube, cube_c ).rgb, diffuse_f.rgb, diffuse_f.a);
		diffuse_f = out_f;
#else
		diffuse_f.rgb *= light.rgb;
		if (diffuse_f.a < 0.5) {
			discard;
		}
#endif
		diffuse_f *= e_colourident;

#if gl_brighten == 1
		diffuse_f.rgb += vec3(0.1f,0.1f,0.1f) * 0.9f;
#endif

#if gl_fake16bit == 1
		diffuse_f.rgb = floor(diffuse_f.rgb * vec3(32,64,32))/vec3(32,64,32);
#endif

#if gl_monochrome == 1
		float m = (diffuse_f.r + diffuse_f.g + diffuse_f.b) / 3.0f;
		diffuse_f.rgb = vec3(m,m,m);
#endif
		gl_FragColor = diffuse_f;
		
	}
#endif
