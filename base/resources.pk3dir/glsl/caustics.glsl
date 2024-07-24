//======= Copyright (c) 2015-2022 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Scrolling shader for patches that get blended on top of existing geometry
// with vertex colors defining fading out
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
		vec3 diffuse_f = texture2D( s_diffuse, tex1_c ).rgb * vex_color.a;
		diffuse_f *= texture2D( s_diffuse, tex2_c ).rgb * vex_color.a;

		gl_FragColor = vec4(diffuse_f, 1.0);
	}
#endif

