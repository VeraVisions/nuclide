//======= Copyright (c) 2023 Vera Visions LLC. All rights reserved. =======
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
	vec4 d_f = vec4(1.0, 1.0, 1.0, 1.0) - texture2D( s_diffuse, tex_c );

	if (d_f.a > 0.5) {
		discard;
	}

	gl_FragColor = fog4( d_f );
}
#endif
