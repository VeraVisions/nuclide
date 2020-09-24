//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Shader used for fading out surfaces after a certain distance.
// It only has a diffuse map.
//==============================================================================

!!ver 110
!!permu FOG
!!samps diffuse=0

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 tex_c;
varying float eyedist;

#ifdef VERTEX_SHADER
void main ()
{
	tex_c = v_texcoord;
	eyedist = abs( length( e_eyepos - v_position.xyz ) ) / 2048.0;

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
	vec4 diffuse_f = texture2D(s_diffuse, tex_c);
	gl_FragColor = vec4( diffuse_f.rgb, (1.0 - eyedist) * diffuse_f.a);
}
#endif
