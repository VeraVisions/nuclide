!!permu FOG
!!samps 1
!!cvardf gl_fake16bit=0
!!cvardf gl_monochrome=0
!!cvardf gl_brighten=0

//meant to be used for additive stuff. presumably particles and sprites. though actually its only flashblend effects that use this at the time of writing.
//includes fog, apparently.

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
void main ()
{
	vec4 diffuse_f = texture2D(s_t0, tc);
	

#if gl_brighten == 1
		diffuse_f.rgb += vec3(0.1f,0.1f,0.1f) * 0.9f;
#endif

#if gl_fake16bit == 1
	diffuse_f.rgb = floor(diffuse_f.rgb * vec3(32,64,32))/vec3(32,64,32);
#endif

#if gl_monochrome == 1
		float m = (diffuse_f.r + diffuse_f.g + diffuse_f.b) / 3.0f;
		diffuse_f.rgb = vec3(m,m,m);
#endif

	gl_FragColor = fog4additive(diffuse_f * vc * e_colourident);
}
#endif
