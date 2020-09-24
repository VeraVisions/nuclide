//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Water shader (normalmap only) where there's only refraction.
//==============================================================================

!!ver 110
!!permu FOG
!!samps 2 diffuse normalmap reflectcube

#include "sys/defs.h"

varying vec2 tex_c;
varying vec2 lm_c;
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


		tf_c = ftetransform();
		tf_c.z += 0.1;
		shift1 = v_texcoord + vec2( e_time * 0.025, 0.0 );
		shift2 = v_texcoord - vec2( 0, e_time * -0.025 );
		tex_c = v_texcoord;
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
		norm_f -= 1.0 - ( 4.0 / 1024.0 );
		norm_f = normalize( norm_f ) * 0.1;

		// Reflection/View coordinates
		refl_c = ( 1.0 + ( tf_c.xy / tf_c.w ) ) * 0.5;
		refl_c.t -= 1.5 * invsurface[2].z / 1080.0;

			// Load reflection and refraction based on our new coords
		refl_f = texture2D( s_t0, refl_c).rgb;
		refr_f = texture2D( s_t1, refl_c + ( norm_f.st * 0.1 ) ).rgb;

		fres = pow( 1.0 - abs( dot( norm_f, normalize( eyeminusvertex ) ) ), 5.0 );
		out_f.rgb = refr_f;

		gl_FragColor = fog4(out_f);
	}
#endif
