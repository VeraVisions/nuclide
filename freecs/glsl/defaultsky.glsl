!!ver 110

#ifdef VERTEX_SHADER
void main ()
{
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
void main ()
{
	discard;
}
#endif
