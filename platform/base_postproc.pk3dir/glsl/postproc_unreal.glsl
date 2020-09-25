//
// Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

!!samps screen=0
!!ver 120

#include "sys/defs.h"
varying vec2 texcoord;

#ifdef VERTEX_SHADER
void main()
{
	texcoord = v_texcoord.xy;
	texcoord.y = 1.0 - texcoord.y;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
uniform vec2 e_sourcesize;

// from https://github.com/hughsk/glsl-dither/blob/master/4x4.glsl
vec3 p_dither(vec2 position, vec3 col)
{
  float brightness = col.r + col.g + col.b / 3.0;
 
  int x = int(mod(position.x, 4.0));
  int y = int(mod(position.y, 4.0));
  int index = x + y * 4;
  float limit = 0.0;

  if (x < 8) {
    if (index == 0) limit = 0.0625;
    if (index == 1) limit = 0.5625;
    if (index == 2) limit = 0.1875;
    if (index == 3) limit = 0.6875;
    if (index == 4) limit = 0.8125;
    if (index == 5) limit = 0.3125;
    if (index == 6) limit = 0.9375;
    if (index == 7) limit = 0.4375;
    if (index == 8) limit = 0.25;
    if (index == 9) limit = 0.75;
    if (index == 10) limit = 0.125;
    if (index == 11) limit = 0.625;
    if (index == 12) limit = 1.0;
    if (index == 13) limit = 0.5;
    if (index == 14) limit = 0.875;
    if (index == 15) limit = 0.375;
  }

  return col * (brightness < limit ? 0.0 : 1.0);
}

vec3 p_gamma(vec3 col)
{
	float gamma = 0.75f;
	col.r = pow(col.r, 1.0 / gamma);
	col.g = pow(col.g, 1.0 / gamma);
	col.b = pow(col.b, 1.0 / gamma); 
	return col;
}

void main(void)
{
	vec2 pos = vec2(gl_FragCoord.x, gl_FragCoord.y);
	vec3 col = texture2D(s_screen, texcoord).rgb;

	col = p_gamma(col);

	// dither me
	col = mix(col, p_dither(pos, col), 0.5f);

	// 16-bit ify
	col.rgb = floor(col.rgb * vec3(32,64,32))/vec3(32,64,32);
	gl_FragColor = vec4(col, 1.0);
}
#endif
