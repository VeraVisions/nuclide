//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Default post-processing shader for the framebuffer.
// Does a 'dodge' filter onto the final scene.
//==============================================================================

!!samps screen=0

#ifdef VERTEX_SHADER
attribute vec2 v_texcoord;
varying vec2 texcoord;

void main()
{
	texcoord = v_texcoord.xy;
	texcoord.y = 1.0 - texcoord.y;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
varying vec2 texcoord;
void main()
{
	vec4 colortint = vec4(COLOR);
	vec3 dodged = vec3(1.0,1.0,1.0) - (colortint.rgb * colortint.a);
	gl_FragColor.rgb = texture2D(s_screen, texcoord).rgb / dodged;
}
#endif
