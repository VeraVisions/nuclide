!!ver 130
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG
!!samps diffuse
!!cvardf gl_affinemodels=0
!!cvardf gl_fake16bit=0

#include "sys/defs.h"

#if gl_affinemodels == 1
	#define affine noperspective
#else
	#define affine
#endif

affine varying vec2 tex_c;
varying vec3 light;

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	/*float hl( vec3 normal, vec3 dir ) {
		return ( dot( normal, dir ) * 0.5 ) + 0.5;
	}*/

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		tex_c = v_texcoord;
		light = e_light_ambient + (e_light_mul * dot(n, e_light_dir));

#ifdef CHROME
		vec3 viewc = normalize(e_eyepos - v_position.xyz);
		float d = dot(n, viewc);
		vec3 reflected = n * 2 * d - viewc;
		tex_c.x = 0.5 + reflected.y * 0.5;
		tex_c.y = 0.5 - reflected.z * 0.5;
#endif

		if (light.r > 1.0f) {
			light.r = 1.0f;
		}
		if (light.g > 1.0f) {
			light.g = 1.0f;
		}
		if (light.b > 1.0f) {
			light.b = 1.0f;
		}
	}
#endif


#ifdef FRAGMENT_SHADER
	void main ()
	{
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
		diffuse_f.rgb *= light;
		diffuse_f *= e_colourident;
#if gl_fake16bit == 1
		diffuse_f.rgb = floor(diffuse_f.rgb * vec3(32,64,32))/vec3(32,64,32);
#endif
		gl_FragColor = diffuse_f * e_colourident;
	}
#endif
