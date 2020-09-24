//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Trisoup whose diffusemap multiplies against the glColor values.
//==============================================================================

!!ver 110
!!samps diffuse

#include "sys/defs.h"

varying vec2 tex_c;
varying vec4 vex_color;

#ifdef VERTEX_SHADER
	void main ()
	{
		tex_c = v_texcoord;
		tex_c.y -= e_time;
		vex_color = v_colour;
		gl_Position = ftetransform();
	}
#endif

#ifdef FRAGMENT_SHADER
	void main ()
	{
		vec4 diffuse_f = vex_color;
		diffuse_f.rgb *= diffuse_f.a;
		diffuse_f *= texture2D(s_diffuse, tex_c);
		gl_FragColor = diffuse_f;
	}
#endif
