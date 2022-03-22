//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Fades surfaces in with distance. It's the opposite of the clutter shader.
//==============================================================================

!!ver 110
!!samps diffuse=0

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 tex_c;
varying float eyedist;

#ifdef VERTEX_SHADER
void main ()
{
	tex_c = v_texcoord;
	eyedist = abs( length( e_eyepos - v_position.xyz ) ) / 1024.0;

	if (eyedist > 1.0) {
		eyedist = 1.0;
	} else if (eyedist < 0.0) {
		eyedist = 0.0;
	}

	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
void main ()
{
	gl_FragColor = vec4( texture2D( s_diffuse, tex_c ).rgb * eyedist, eyedist );
	gl_FragColor *= e_colourident;
	gl_FragColor *= v_colour;
}
#endif
