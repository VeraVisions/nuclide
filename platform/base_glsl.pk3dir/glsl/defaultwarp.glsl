!!ver 100 450
!!permu FOG
!!samps diffuse lightmap
!!cvardf gl_mono=0
!!cvardf gl_stipplealpha=0

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 tc;

#ifdef LIT
varying vec2 lm0;
#endif

#ifdef VERTEX_SHADER
	void main ()
	{
		tc = v_texcoord.st;
	#ifdef FLOW
		tc.s += e_time * -0.5;
	#endif
	#ifdef LIT
		lm0 = v_lmcoord;
	#endif
		gl_Position = ftetransform();
	}
#endif

#ifdef FRAGMENT_SHADER
#ifndef ALPHA
	#define USEALPHA 1.0
#else
	#define USEALPHA float(ALPHA)
#endif

	void main ()
	{
		vec2 ntc;
		ntc.s = tc.s + sin(tc.t+e_time)*0.125;
		ntc.t = tc.t + sin(tc.s+e_time)*0.125;
		vec4 diffuse_f = texture2D(s_diffuse, ntc);

		diffuse_f *= e_colourident;

		// awful stipple alpha code
		if (gl_stipplealpha == 1.0) {
			float alpha = USEALPHA * e_colourident.a;
			int x = int(mod(gl_FragCoord.x, 2.0));
			int y = int(mod(gl_FragCoord.y, 2.0));

			if (alpha <= 0.0) {
					discard;
			} else if (alpha <= 0.25) {
				diffuse_f.a = 1.0f;
				if (x + y == 2)
					discard;
				if (x + y == 1)
					discard;
			} else if (alpha <= 0.5) {
				diffuse_f.a = 1.0f;
				if (x + y == 2)
					discard;
				if (x + y == 0)
					discard;
			} else if (alpha < 1.0) {
				diffuse_f.a = 1.0f;
				if (x + y == 2)
					discard;
			}
		} else {
	#ifdef LIT
		diffuse_f.rgb *= (texture2D(s_lightmap, lm0) * e_lmscale).rgb;
	#endif
		}

		if (gl_mono == 1.0) {
			float bw = (diffuse_f.r + diffuse_f.g + diffuse_f.b) / 3.0;
			diffuse_f.rgb = vec3(bw, bw, bw);
		}

		gl_FragColor = fog4(diffuse_f);
	}
#endif
