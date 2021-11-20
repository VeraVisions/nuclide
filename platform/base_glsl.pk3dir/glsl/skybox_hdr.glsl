//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Basic skybox shader with two clouds rendered on top using a dodge filter.
//==============================================================================

!!ver 110
!!permu FOG
!!samps hdr_40:samplerCube=0 hdr_250:samplerCube=1 hdr_1600:samplerCube=2 cloudA=3 cloudB=4
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
void main ()
{
	float hdr_scale;
	vec3 sky_out;
	vec3 skybox_40 = textureCube( s_hdr_40, boxpos ).rgb;
	vec3 skybox_250 = textureCube( s_hdr_250, boxpos ).rgb;
	vec3 skybox_1600 = textureCube( s_hdr_1600, boxpos ).rgb;
	hdr_scale = (e_lmscale.r + e_lmscale.g + e_lmscale.b) / 3.0;

	if (hdr_scale > 1.0) {
		sky_out = mix(skybox_250, skybox_40, hdr_scale - 1.0);
	} else {
		sky_out = mix(skybox_1600, skybox_250, hdr_scale);
	}

	/* the cloud bits */
	vec2 tccoord;
	vec3 dir = cloudpos - e_eyepos;
	dir.z *= 3.0;
	dir.xy /= 0.5 * length( dir );
	tccoord = ( dir.xy + e_time * 0.015 );
	vec4 cloud1_f = texture2D( s_cloudA, tccoord );
	tccoord = ( dir.xy + e_time * 0.02 );
	vec4 cloud2_f = texture2D( s_cloudB, tccoord );

	vec3 dodged1 = vec3(1.0,1.0,1.0) - (cloud1_f.rgb * vec3(cloud1_f.a, cloud1_f.a, cloud1_f.a));
	vec3 dodged2 = vec3(1.0,1.0,1.0) - (cloud2_f.rgb * vec3(cloud2_f.a, cloud2_f.a, cloud2_f.a));

	gl_FragColor.rgb = sky_out / dodged1;
	gl_FragColor.rgb = gl_FragColor.rgb / dodged2;
	//gl_FragColor *= e_lmscale;
}
#endif
 
