//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Terrain shader for tw_valley's skyroom.
//==============================================================================

!!ver 110
!!permu FOG
!!samps box:samplerCube=0 cloudA=1 cloudB=2
#include "sys/defs.h"
#include "sys/fog.h"

varying vec3 cloudpos;
varying vec3 boxpos;
#ifdef VERTEX_SHADER
void main ()
{
	boxpos = v_position.xyz - e_eyepos;
	cloudpos = v_position.xyz;
	gl_Position = ftetransform();
}
#endif
#ifdef FRAGMENT_SHADER


#define s_cloud1 s_t0
#define s_cloud2 s_t1
void main ()
{
	vec4 skybox = textureCube( s_box, boxpos );
	vec2 tccoord;
	vec3 dir = cloudpos - e_eyepos;
	dir.z *= 4.0;
	dir.xy /= 0.5 * length( dir );
	tccoord = ( dir.xy + e_time * 0.015 ) * 0.75;
	vec4 cloud1_f = texture2D( s_cloudA, tccoord );
	tccoord = ( dir.xy + e_time * 0.02 ) * 0.75;
	vec4 cloud2_f = texture2D( s_cloudB, tccoord );
	
	vec3 dodged1 = vec3(1.0,1.0,1.0) - (cloud1_f.rgb * vec3(cloud1_f.a, cloud1_f.a, cloud1_f.a));
	vec3 dodged2 = vec3(1.0,1.0,1.0) - (cloud2_f.rgb * vec3(cloud2_f.a, cloud2_f.a, cloud2_f.a));

	gl_FragColor.rgb = skybox.rgb / dodged1;
	gl_FragColor.rgb = gl_FragColor.rgb / dodged2;
	gl_FragColor *= e_lmscale;

#ifdef FOGGED
	gl_FragColor.rgb = fog3(gl_FragColor.rgb);
#endif
}
#endif
 
