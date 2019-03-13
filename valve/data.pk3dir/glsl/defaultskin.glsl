!!ver 130
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG
!!samps diffuse
!!cvardf gl_affinemodels=0
!!cvardf gl_fake16bit=0
!!cvardf gl_monochrome=0
!!cvardf gl_brighten=0

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

#ifdef CHROME
	/* Rotate Light Vector */
	vec3 rlv(vec3 axis, vec3 origin, vec3 lightpoint)
	{
		vec3 offs;
		vec3 result;
		offs[0] = lightpoint[0] - origin[0];
		offs[1] = lightpoint[1] - origin[1];
		offs[2] = lightpoint[2] - origin[2];
		result[0] = dot(offs[0], axis[0]);
		result[1] = dot(offs[1], axis[1]);
		result[2] = dot(offs[2], axis[2]);
		return result;
	}
#endif

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		tex_c = v_texcoord;
		light = e_light_ambient + (e_light_mul * dot(n, e_light_dir));

#ifdef CHROME
		vec3 rorg = rlv(vec3(0,0,0), w, e_light_dir);
		vec3 viewc = normalize(rorg - w);
		float d = dot(n, viewc);
		vec3 reflected;
		reflected.x = n.x * 2 * d - viewc.x;
		reflected.y = n.y * 2 * d - viewc.y;
		reflected.z = n.z * 2 * d - viewc.z;
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

		gl_FragColor = diffuse_f * e_colourident;
	}
#endif
