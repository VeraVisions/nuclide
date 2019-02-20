!!permu FOG
!!samps 1
!!cvardf gl_fake16bit=0
!!cvardf gl_monochrome=0
//used by both particles and sprites.
//note the fog blending mode is all that differs from defaultadditivesprite

#include "sys/fog.h"
#ifdef VERTEX_SHADER
attribute vec2 v_texcoord;
attribute vec4 v_colour;
varying vec2 tc;
varying vec4 vc;
void main ()
{
	tc = v_texcoord;
	vc = v_colour;
	gl_Position = ftetransform();
}
#endif
#ifdef FRAGMENT_SHADER
varying vec2 tc;
varying vec4 vc;
uniform vec4 e_colourident;
uniform vec4 e_vlscale;
void main ()
{
	vec4 col = texture2D(s_t0, tc);

#ifdef MASK
	if (col.a < float(MASK))
		discard;
#endif

	col = fog4blend(col * vc * e_colourident * e_vlscale);

#if gl_fake16bit == 1
	col.rgb = floor(col.rgb * vec3(32,64,32))/vec3(32,64,32);
#endif

#if gl_monochrome == 1
		float m = (col.r + col.g + col.b) / 3.0f;
		col.rgb = vec3(m,m,m);
#endif

	gl_FragColor = col;
}
#endif
