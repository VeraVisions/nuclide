!!ver 110
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG
!!samps diffuse

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 light;

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	float hl( vec3 normal, vec3 dir ) {
		return ( dot( normal, dir ) * 0.5 ) + 0.5;
	}

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		tex_c = v_texcoord;
		light = ( hl( n, e_light_dir ) * e_light_mul ) + e_light_ambient;
	}
#endif


#ifdef FRAGMENT_SHADER
	void main ()
	{
		vec4 diffuse_f = texture2D( s_diffuse, tex_c );
		diffuse_f.rgb *= light;
		gl_FragColor = diffuse_f * e_colourident;
	}
#endif
