//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Basic water shader, No diffuse texture, just pure normalmap + refraction
//==============================================================================

!!ver 110
!!permu FOG
!!samps 2 normalmap reflectcube

#include "sys/defs.h"

varying mat3 invsurface;
varying vec4 tf_c;
varying vec3 eyeminusvertex;
varying vec3 eyevector;
varying vec2 shift1;
varying vec2 shift2;

#ifdef VERTEX_SHADER
	void main ()
	{
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
		eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot( eyeminusvertex, v_svector.xyz );
		eyevector.y = dot( eyeminusvertex, v_tvector.xyz );
		eyevector.z = dot( eyeminusvertex, v_normal.xyz );
		tf_c = ftetransform();
		tf_c.z += 0.1; /* hack to get rid of refraction artifacts */
		shift1 = v_texcoord + vec2( e_time * 0.1, 0.0 );
		shift2 = v_texcoord - vec2( 0, e_time * -0.01 );
		gl_Position = tf_c;
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	void main ( void )
	{
		float fres;
		vec2 refl_c;
		vec3 refl_f;
		vec3 refr_f;
		vec3 norm_f;
		vec4 out_f = vec4( 1.0, 1.0, 1.0, 1.0 );

		// Use the normalmap to shift the refraction
		norm_f = ( texture2D( s_normalmap, shift1 ).xyz);
		norm_f += ( texture2D( s_normalmap, shift2 ).xyz);
		norm_f -= 1.0 - ( 4.0 / 256.0 );
		norm_f = normalize( norm_f ) * 0.05;

		// Reflection/View coordinates
		refl_c = ( 1.0 + ( tf_c.xy / tf_c.w ) ) * 0.5;
		refl_c.t -= 1.5 * invsurface[2].z / 1080.0;

		vec3 cube_c = reflect( normalize( -eyevector ), texture2D( s_normalmap, shift2).rgb * 0.35 );
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = ( m_model * vec4( cube_c.xyz, 0.0 ) ).xyz;
		refl_f = textureCube( s_reflectcube, cube_c ).rgb;
		refr_f = texture2D( s_t1, refl_c + ( norm_f.st * 0.1 ) ).rgb;
		fres = pow( 1.0 - abs( dot( norm_f, normalize( eyeminusvertex ) ) ), 5.0 );
		out_f.rgb = mix( refr_f, refl_f, fres * 0.25 );

		gl_FragColor = fog4( out_f );
	}
#endif
