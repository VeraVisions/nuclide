/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

void
drawpic_flip(vector pos, string mat, vector size, vector color, float alpha)
{
	drawsubpic(pos, size, mat, [1,0], [-1,1], color, alpha, 0);
}

void
Background_WON(void)
{
	drawpic([g_menuofs[0],g_menuofs[1]], g_bmp[SPLASH],
		[640,480], [1,1,1], 1.0f);

	/* just some silly widescreen extension hack that could apply to some games */
#if 0
	drawpic_flip([g_menuofs[0] - 640,g_menuofs[1]], g_bmp[SPLASH],
		[640,480], [1,1,1], 1.0f);
	drawpic_flip([g_menuofs[0] + 640,g_menuofs[1]], g_bmp[SPLASH],
		[640,480], [1,1,1], 1.0f);
#endif
}

typedef struct
{
	string strMat;
	vector vecSize;
	vector vecPos;
} backResource_t;

backResource_t g_back800[] = 
{
	{"resource/background/800_1_a_loading",[256,256,0],[0,0,0]},
	{"resource/background/800_1_b_loading",[256,256,0],[256,0,0]},
	{"resource/background/800_1_c_loading",[256,256,0],[512,0,0]},
	{"resource/background/800_1_d_loading",[32,256,0],[768,0,0]},
	{"resource/background/800_2_a_loading",[256,256,0],[0,256,0]},
	{"resource/background/800_2_b_loading",[256,256,0],[256,256,0]},
	{"resource/background/800_2_c_loading",[256,256,0],[512,256,0]},
	{"resource/background/800_2_d_loading",[32,256,0],[768,256,0]},
	{"resource/background/800_3_a_loading",[256,88,0],[0,512,0]},
	{"resource/background/800_3_b_loading",[256,88,0],[256,512,0]},
	{"resource/background/800_3_c_loading",[256,88,0],[512,512,0]},
	{"resource/background/800_3_d_loading",[32,88,0],[768,512,0]}
};

void
Background_Steam(void)
{
	for (int i = 0; i < g_back800.length; i++) {
		vector pos = [0.0f, 0.0f, 0.0f];
		vector size = [0.0f, 0.0f, 0.0f];
		
		/* scale down 800x600 to 640x480 */
		size = g_back800[i].vecSize * 0.8f;
		pos[0] = g_menuofs[0] + (g_back800[i].vecPos[0] * 0.8f);
		pos[1] = g_menuofs[1] + (g_back800[i].vecPos[1] * 0.8f);

		drawpic(pos, \
		g_back800[i].strMat, \
		size, \
		[1,1,1], \
		1.0f);
	}
}
