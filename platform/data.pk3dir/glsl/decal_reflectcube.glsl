//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// The diffusemap (monochrome) decides the reflectivity of a surface.
// Using a cube environmentmap as a source for reflectivity.
//==============================================================================

!!ver 110
!!permu FOG
!!permu BUMP
!!permu DELUXE
!!samps diffuse normalmap reflectcube

#include "sys/defs.h"

varying vec2 tex_c;
varying vec3 eyevector;
varying mat3 invsurface;
varying vec2 wat_c;

#ifdef VERTEX_SHADER
	void main (void)
	{
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;

		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot(eyeminusvertex, v_svector.xyz);
		eyevector.y = dot(eyeminusvertex, v_tvector.xyz);
		eyevector.z = dot(eyeminusvertex, v_normal.xyz);

		tex_c = v_texcoord;
		wat_c = tex_c + vec2(e_time * 0.01, sin(e_time) * 0.005);
		gl_Position = ftetransform();
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	void main (void)
	{
		vec3 cube_c;
		vec4 out_f = vec4(1.0, 1.0, 1.0, 1.0);
		vec4 diffuse_f = texture2D(s_diffuse, tex_c);
		cube_c = reflect(normalize(-eyevector), texture2D(s_normalmap, wat_c).rgb * 0.35);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;
		out_f.rgb = textureCube(s_reflectcube, cube_c).rgb;
		out_f.rgb *= diffuse_f.r + diffuse_f.b + diffuse_f.g / 3.0;

		// Add fog to the final fragment
		gl_FragColor = fog4(out_f);
	}
#endif
