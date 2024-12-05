//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// A skybox cube with two cloud layers, which get occluded by a blended
// second skybox cube.
//==============================================================================

!!ver 110
!!permu FOG
!!samps cloudA=0 cloudB=1 box:samplerCube=2 mountains:samplerCube=3
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
	vec4 mountains = textureCube( s_mountains, boxpos );
	vec4 box = textureCube( s_box, boxpos );
	vec2 tccoord;
	vec3 dir = cloudpos - e_eyepos;
	dir.z *= 3.0;
	dir.xy /= 0.5 * length( dir );
	tccoord = ( dir.xy + e_time * 0.015 );
	vec4 cloud1_f = texture2D( s_cloudA, tccoord );
	tccoord = ( dir.xy + e_time * 0.02 );
	vec4 cloud2_f = texture2D( s_cloudA, tccoord );

	gl_FragColor.rgb = mix( box.rgb, cloud1_f.rgb, cloud1_f.a );
	gl_FragColor = vec4( mix( gl_FragColor.rgb, cloud2_f.rgb, cloud2_f.a ), 1.0 );
	
	if (mountains.a > 0.9) {
		gl_FragColor.rgb = mix( gl_FragColor.rgb, mountains.rgb, mountains.a);
	}

	gl_FragColor *= e_lmscale;

#ifdef FOGGED
	gl_FragColor.rgb = fog3(gl_FragColor.rgb);
#endif
}
#endif
 
