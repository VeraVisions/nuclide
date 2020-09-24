//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Non-lit surface that predominantly offers environment cube reflection
// modulated by the diffusemap's RGB. This is used for glass, for example.
//==============================================================================

!!ver 110
!!permu FOG
!!samps diffusemap=0 normalmap=1 cubemap:samplerCube=2

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 eyevector;
varying mat3 invsurface;

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
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
#include "sys/fog.h"
void main ()
{
	vec3 out_f;
	vec3 diffuse_f = texture2D(s_diffusemap, tex_c).rgb;
	vec3 normal_f = texture2D(s_normalmap, tex_c).rgb - 0.5;
	normal_f.x *= 0.2;
	normal_f.y *= 0.2;
	normal_f = normalize(normal_f);
	vec3 rtc = reflect( normalize( -eyevector ), normal_f );
	rtc = rtc.x * invsurface[0] + rtc.y * invsurface[1] + rtc.z * invsurface[2];
	rtc = ( m_model * vec4( rtc.xyz, 0.0 ) ).xyz;

	diffuse_f = textureCube(s_cubemap, rtc).rgb * (diffuse_f * 2.5);

	gl_FragColor = fog4(vec4( diffuse_f, 1.0 ));
}
#endif
