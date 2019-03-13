!!ver 100-450
!!cvardf gl_fake16bit=0

#ifdef VERTEX_SHADER
attribute vec4 v_colour;
varying vec4 vc;

void main ()
{
	vc = v_colour;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
varying vec4 vc;
void main ()
{
	gl_FragColor = vc;
}
#endif
