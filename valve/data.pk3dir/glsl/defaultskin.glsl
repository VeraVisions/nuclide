!!ver 130
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG
!!samps diffuse reflectcube
!!cvardf gl_affinemodels=0

#include "sys/defs.h"

#if gl_affinemodels == 1
	#define affine noperspective
#else
	#define affine
#endif

#ifdef REFLECTCUBE
varying vec3 eyevector;
varying mat3 invsurface;
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
	
#ifdef REFLECTCUBE
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot( eyeminusvertex, v_svector.xyz );
		eyevector.y = dot( eyeminusvertex, v_tvector.xyz );
		eyevector.z = dot( eyeminusvertex, v_normal.xyz );
#endif
	}
#endif


#ifdef FRAGMENT_SHADER
	void main ()
	{
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
		diffuse_f.rgb *= light;

#ifdef REFLECTCUBE
		vec3 cube_c;
		vec4 out_f = vec4( 1.0, 1.0, 1.0, 1.0 );

		cube_c = reflect( normalize( -eyevector ), vec3( 0, 0, 1 ) );
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = ( m_model * vec4( cube_c.xyz, 0.0 ) ).xyz;
		out_f.rgb = mix( textureCube( s_reflectcube, cube_c ).rgb, diffuse_f.rgb, diffuse_f.a );
		diffuse_f = out_f;
#endif
		diffuse_f *= e_colourident;

		gl_FragColor = diffuse_f * e_colourident;
	}
#endif
