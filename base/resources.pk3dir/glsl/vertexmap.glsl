//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Trisoup whose diffusemap multiplies against the glColor values.
//==============================================================================

!!ver 110
!!permu FRAMEBLEND
!!permu FOG
!!samps diffuse

#include "sys/defs.h"

varying vec2 tex_c;
varying vec4 vex_color;

#ifdef VERTEX_SHADER
	void main ()
	{
		tex_c = v_texcoord;
		vex_color = v_colour;
		gl_Position = ftetransform();
	}
#endif


#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	void main ()
	{
		vec4 diffuse_f = texture2D( s_diffuse, tex_c );
		diffuse_f.rgb *= vex_color.rgb;
		gl_FragColor = fog4( diffuse_f );
	}
#endif
