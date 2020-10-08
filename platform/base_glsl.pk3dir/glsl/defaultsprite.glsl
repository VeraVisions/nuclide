!!ver 130
!!permu FOG
!!samps 1
!!cvardf gl_mono=0
!!cvardf gl_kdither=0

#include "sys/fog.h"
#ifdef VERTEX_SHADER
attribute vec2 v_texcoord;
attribute vec4 v_colour;
varying vec2 tc;
varying vec4 vc;
void main ()
{
	tc = v_texcoord;
	vc = v_colour;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
varying vec2 tc;
varying vec4 vc;
uniform vec4 e_colourident;
uniform vec4 e_vlscale;

	vec4 kernel_dither(sampler2D targ, vec2 texc)
	{
		int x = int(mod(gl_FragCoord.x, 2.0));
		int y = int(mod(gl_FragCoord.y, 2.0));
		int index = x + y * 2;
		vec2 coord_ofs;
		vec2 size;

		size.x = 1.0 / textureSize(targ, 0).x;
		size.y = 1.0 / textureSize(targ, 0).y;

		if (index == 0)
			coord_ofs = vec2(0.25f, 0.0f);
		else if (index == 1)
			coord_ofs = vec2(0.50f, 0.75f);
		else if (index == 2)
			coord_ofs = vec2(0.75f, 0.50f);
		else if (index == 3)
			coord_ofs = vec2(0.00f, 0.25f);

		return texture2D(targ, texc + coord_ofs * size);
	}

	void main ()
	{
		vec4 col;

		// Arrgh, currently the HUD uses this in HL */
		if (gl_kdither == 1.0)
			col = texture2D(s_t0, tc);
		else
			col = texture2D(s_t0, tc);

	#ifdef MASK
		if (col.a < float(MASK))
			discard;
	#endif

		col = fog4blend(col * vc * e_colourident * e_vlscale);

		if (gl_mono == 1.0) {
			float bw = (col.r + col.g + col.b) / 3.0;
			col.rgb = vec3(bw, bw, bw) * 1.5;
		}

		gl_FragColor = col;
	}
#endif
