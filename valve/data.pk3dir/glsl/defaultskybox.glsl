!!ver 110
!!permu FOG
!!samps reflectcube
!!cvardf gl_fake16bit=0
!!cvardf gl_monochrome=0
!!cvardf gl_brighten=0

#include "sys/defs.h"
#include "sys/fog.h"

varying vec3 pos;
#ifdef VERTEX_SHADER
void main ()
{
	pos = v_position.xyz - e_eyepos;
	pos.y = -pos.y;
	gl_Position = ftetransform();
}
#endif
#ifdef FRAGMENT_SHADER
void main ()
{
	vec4 skybox = textureCube(s_reflectcube, pos);

#if gl_brighten == 1
		skybox.rgb += vec3(0.1f,0.1f,0.1f) * 0.9f;
#endif

#if gl_fake16bit == 1
	skybox.rgb = floor(skybox.rgb * vec3(32,64,32))/vec3(32,64,32);
#endif

#if gl_monochrome == 1
		float m = (skybox.r + skybox.g + skybox.b) / 3.0f;
		skybox.rgb = vec3(m,m,m);
#endif

	gl_FragColor = vec4(fog3(skybox.rgb), 1.0);
}
#endif
