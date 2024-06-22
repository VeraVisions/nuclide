//======= Copyright (c) 2015-2022 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Alternate version of caustics that's practically inverted for subtract blends
//==============================================================================

!!ver 110
!!samps diffuse

#include "sys/defs.h"

varying vec2 tex1_c;
varying vec2 tex2_c;
varying vec4 vex_color;

#ifdef VERTEX_SHADER
	void main ( void )
	{
		tex1_c = v_texcoord + vec2(e_time * 0.25, e_time * 0.25);
		tex2_c = v_texcoord * 0.5 + vec2(e_time * 0.1, e_time * 0.2);
		vex_color = v_colour;

		gl_Position = ftetransform();
	}
#endif

#ifdef FRAGMENT_SHADER
	void main ( void )
	{
		vec3 diffuse_f = texture2D( s_diffuse, tex1_c ).rgb;
		diffuse_f *= texture2D( s_diffuse, tex2_c ).rgb;
		
		diffuse_f = mix(diffuse_f, vec3(1.0,1.0,1.0), 1.0 - vex_color.a);

		gl_FragColor = vec4(diffuse_f, 1.0);
	}
#endif

