//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Fills any surface with a diffuse texture and applies vertex colors.
//==============================================================================

!!ver 110
!!samps tex=0

varying vec2 tc;
varying vec4 vc;

#ifdef VERTEX_SHADER
attribute vec2 v_texcoord;
attribute vec4 v_colour;
void main ()
{
	tc = v_texcoord;
	vc = v_colour;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
void main ()
{
	vec4 f = vc;
	f.rgb *= f.a;
	f *= texture2D(s_tex, tc);
	gl_FragColor = f;
}
#endif
