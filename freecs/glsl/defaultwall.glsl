!!ver 110
!!samps diffuse lightmap
!!cvardf gl_fake16bit=0

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
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
		vec3 light = texture2D(s_lightmap, lm_c).rgb;
		
		if (light.r > 1.0f) {
			light.r = 1.0f;
		}
		if (light.g > 1.0f) {
			light.g = 1.0f;
		}
		if (light.b > 1.0f) {
			light.b = 1.0f;
		}

		if (diffuse_f.a < 0.5) {
			discard;
		}

		diffuse_f.rgb *= light.rgb;
		diffuse_f *= e_colourident;

#if gl_fake16bit == 1
		diffuse_f.rgb = floor(diffuse_f.rgb * vec3(32,64,32))/vec3(32,64,32);
#endif
		gl_FragColor = diffuse_f;
	}
#endif
