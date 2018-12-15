!!ver 110
!!samps diffuse lightmap

#include "sys/defs.h"

varying vec2 tex_c;
varying vec2 lm_c;

#ifdef VERTEX_SHADER
	void main ()
	{
		tex_c = v_texcoord;
		lm_c = v_lmcoord;
		gl_Position = ftetransform();
	}
#endif

#ifdef FRAGMENT_SHADER
	void main ( void )
	{
		vec4 diffuse_f = texture2D( s_diffuse, tex_c );

		if ( diffuse_f.a < 0.5 ) {
			discard;
		}

		diffuse_f.rgb *= texture2D( s_lightmap, lm_c ).rgb * e_lmscale.rgb;
		diffuse_f *= e_colourident;

		gl_FragColor = diffuse_f;
	}
#endif
