!!ver 110
!!permu FOG
!!samps reflection=0 refraction=1 normalmap=2

#include "sys/defs.h"

varying vec2 tex_c;
varying mat3 invsurface;
varying vec4 tf_c;
varying vec3 eyeminusvertex;

#ifdef VERTEX_SHADER
	void main ()
	{
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
		eyeminusvertex = e_eyepos - v_position.xyz;
		tf_c = ftetransform();
		tf_c.z += 0.1; /* hack to get rid of refraction artifacts */
		tex_c = v_texcoord;
		gl_Position = tf_c;
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	void main ( void )
	{
		float fres;
		vec2 refl_c;
		vec3 refl_f;
		vec3 refr_f;
		vec3 norm_f;
		vec4 out_f = vec4( 1.0, 1.0, 1.0, 1.0 );

		norm_f = ( texture2D( s_normalmap, tex_c + vec2( e_time * 0.01, 0.0 ) ).xyz);
		norm_f += ( texture2D( s_normalmap, tex_c - vec2( 0, e_time * 0.01 ) ).xyz);
		norm_f -= 1.0 - ( 4.0 / 256.0 );
		norm_f = normalize( norm_f );

		// Reflection/View coordinates
		refl_c = ( 1.0 + ( tf_c.xy / tf_c.w ) ) * 0.5;
		refl_c.t -= 1.5 * invsurface[2].z / 1080.0;

		refl_f = texture2D( s_reflection, refl_c ).rgb;
		refr_f = texture2D( s_refraction, refl_c + ( norm_f.st) ).rgb;

		fres = pow( 1.0 - abs( dot( norm_f, normalize( eyeminusvertex ) ) ), 5.0 );
		out_f.rgb = mix( refr_f, refl_f, fres );

		gl_FragColor = fog4( out_f );
	}
#endif
