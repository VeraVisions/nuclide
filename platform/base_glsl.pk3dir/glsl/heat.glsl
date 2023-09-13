//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Non-lit surface that predominantly offers environment cube reflection
// modulated by the diffusemap's RGB. This is used for glass, for example.
//==============================================================================

!!ver 110
!!permu FOG
!!samps diffusemap=0 normalmap=1 reflect=2

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 eyevector;
varying mat3 invsurface;
varying vec4 tf;

#ifdef VERTEX_SHADER
void main ()
{
	
	tex_c = v_texcoord;
	invsurface[0] = v_svector;
	invsurface[1] = v_tvector;
	invsurface[2] = v_normal;
	vec3 eyeminusvertex = e_eyepos - v_position.xyz;
	eyevector.x = dot( eyeminusvertex, v_svector.xyz );
	eyevector.y = dot( eyeminusvertex, v_tvector.xyz );
	eyevector.z = dot( eyeminusvertex, v_normal.xyz );
	tf = ftetransform();
	gl_Position = tf;
}
#endif

#ifdef FRAGMENT_SHADER
#include "sys/fog.h"
void main ()
{
	vec2 stc;
	vec3 out_f;
	vec4 diffuse_f = texture2D(s_diffusemap, tex_c);
	vec3 norm_f;

	norm_f = ( texture2D( s_normalmap, tex_c + vec2( e_time * 0.01, 0.0 ) ).xyz);
	norm_f += ( texture2D( s_normalmap, tex_c - vec2( 0, e_time * 0.01 ) ).xyz);
	norm_f -= 1.0 - ( 4.0 / 256.0 );
	norm_f = normalize( norm_f );

	stc = (1.0 + (tf.xy / tf.w)) * 0.5;

	diffuse_f.rgb = texture2D(s_reflect, stc + norm_f.st).rgb;
	gl_FragColor = diffuse_f;
}
#endif
