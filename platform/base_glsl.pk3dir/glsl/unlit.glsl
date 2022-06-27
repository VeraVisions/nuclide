//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Unlit surface.
//==============================================================================

!!ver 110
!!permu FOG
!!samps diffuse

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 tex_c;

#ifdef VERTEX_SHADER
void main ()
{
	tex_c = v_texcoord;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
void main ()
{
	vec4 d_f = texture2D( s_diffuse, tex_c );

#ifdef MASK
		// alpha-testing happens here
		if (d_f.a < MASK)
			discard;
#endif

	gl_FragColor = fog4( d_f );
}
#endif
