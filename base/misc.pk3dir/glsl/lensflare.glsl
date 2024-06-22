//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Shader used for fading out surfaces after a certain distance.
// It only has a diffuse map.
//==============================================================================

!!ver 110
!!samps diffuse=0

#include "sys/defs.h"
#include "sys/fog.h"

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
void main ()
{
	vec4 diffuse_f = texture2D(s_diffuse, tex_c) * vex_color.a;
	gl_FragColor = diffuse_f;
}
#endif
